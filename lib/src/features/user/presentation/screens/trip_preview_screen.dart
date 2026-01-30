import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../../../global/services/osm_service.dart';
import '../../../../global/services/auth/user_service.dart';
import '../../services/trip_request_service.dart';
import 'select_destination_screen.dart';
import 'trip_status_screen.dart';
import 'pick_meeting_point_screen.dart';
import 'searching_driver_screen.dart';

/// Modelo optimizado para cotización
class VehicleQuote {
  final String vehicleType;
  final double price;
  final double distanceKm;
  final int durationMinutes;
  final Map<String, dynamic> rawRate;

  VehicleQuote({
    required this.vehicleType,
    required this.price,
    required this.distanceKm,
    required this.durationMinutes,
    required this.rawRate,
  });

  String get formattedPrice => '\$${NumberFormat("#,##0", "es_CO").format(price)}';
}

class TripPreviewScreen extends StatefulWidget {
  final SimpleLocation origin;
  final SimpleLocation destination;
  final String vehicleType; // Pre-selección (opcional)

  const TripPreviewScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.vehicleType,
  });

  @override
  State<TripPreviewScreen> createState() => _TripPreviewScreenState();
}

class _TripPreviewScreenState extends State<TripPreviewScreen> {
  final MapController _mapController = MapController();
  
  // Estado
  OsmRoute? _route;
  List<VehicleQuote> _quotes = [];
  bool _isLoading = true;
  String? _errorMessage;
  late String _selectedVehicleType;
  
  // Tarifas crudas desde DB
  List<Map<String, dynamic>> _rates = [];

  @override
  void initState() {
    super.initState();
    _selectedVehicleType = widget.vehicleType;
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Cargar tarifas y ruta en paralelo
      final futures = await Future.wait([
        TripRequestService.getPublicRates(),
        OsmService.getRoute([
          widget.origin.toLatLng(),
          widget.destination.toLatLng(),
        ]),
      ]);

      final rates = futures[0] as List<Map<String, dynamic>>;
      final route = futures[1] as OsmRoute?;

      if (rates.isEmpty) throw Exception('No se pudieron cargar las tarifas.');
      if (route == null) throw Exception('No se pudo trazar la ruta.');

      _rates = rates;
      _route = route;
      
      // 2. Calcular cotizaciones para todos los vehículos disponibles
      _calculateAllQuotes();

      // 3. Ajustar mapa
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToRoute();
      });

    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateAllQuotes() {
    if (_route == null) return;

    final distanceKm = _route!.distanceKm;
    
    // Calculamos duración con un factor de tráfico muy simple (+20%)
    final durationMin = (_route!.durationMinutes * 1.2).ceil();
    
    final quotes = <VehicleQuote>[];

    // Hora actual para recargos
    final hour = DateTime.now().hour;
    bool isPeak = (hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19);
    bool isNight = (hour >= 22 || hour <= 6);

    for (var rate in _rates) {
      final type = rate['tipo_vehiculo'].toString();
      final base = double.tryParse(rate['tarifa_base'].toString()) ?? 0;
      final perKm = double.tryParse(rate['tarifa_km'].toString()) ?? 0;
      final perMin = double.tryParse(rate['tarifa_min'].toString()) ?? 0;
      // Comision no se usa para el precio del cliente, solo interno
      
      // Recargos hardcoded por ahora, o podrían venir de DB si se agregan a la tabla tarifas
      double surchargePercent = 0.0;
      if (isPeak) surchargePercent = 0.15; // 15%
      if (isNight) surchargePercent = 0.20; // 20%

      double price = base + (distanceKm * perKm) + (durationMin * perMin);
      
      // Aplicar recargo
      price += (price * surchargePercent);

      // Redondear a la centena más cercana (ej: 12340 -> 12300 o 12400) para precios "limpios" en COP
      price = (price / 100).round() * 100.0;

      quotes.add(VehicleQuote(
        vehicleType: type,
        price: price,
        distanceKm: distanceKm,
        durationMinutes: durationMin,
        rawRate: rate,
      ));
    }

    setState(() {
      _quotes = quotes;
      // Si el tipo seleccionado no existe en las nuevas quotes, seleccionar el primero
      if (!_quotes.any((q) => q.vehicleType == _selectedVehicleType) && _quotes.isNotEmpty) {
        _selectedVehicleType = _quotes.first.vehicleType;
      }
    });
  }

  Future<void> _fitMapToRoute() async {
    if (_route == null || _mapController.camera.zoom == 0) return; // Wait for map ready
    
    // Calcular bounds manualmente
    double minLat = 90.0, maxLat = -90.0, minLng = 180.0, maxLng = -180.0;
    
    // Incluir origen y destino
    final points = [..._route!.geometry, widget.origin.toLatLng(), widget.destination.toLatLng()];
    
    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController.fitCamera(CameraFit.bounds(
      bounds: LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
      padding: const EdgeInsets.only(top: 150, bottom: 350, left: 50, right: 50),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo base oscuro
      body: Stack(
        children: [
          _buildMap(),
          _buildTopOverlay(),
          if (!_isLoading && _quotes.isNotEmpty) _buildBottomPanel(),
          if (_isLoading) _buildLoading(),
          if (_errorMessage != null) _buildError(),
        ],
      ),
    );
  }

  // Mapa con estilo oscuro
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.origin.toLatLng(),
        initialZoom: 13,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
      ),
      children: [
        // Tiles oscuros (CartoDB Dark Matter)
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.ping_go.app',
        ),
        
        // Ruta
        if (_route != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route!.geometry,
                strokeWidth: 5,
                color: const Color(0xFFFFD700), // Amarillo característico
              ),
            ],
          ),

        // Marcadores
        MarkerLayer(
          markers: [
            _buildMarker(widget.origin.toLatLng(), Icons.circle, Colors.white), // Origen blanco
            _buildMarker(widget.destination.toLatLng(), Icons.location_on, const Color(0xFFFFD700)), // Destino amarillo
          ],
        ),
      ],
    );
  }

  Marker _buildMarker(LatLng point, IconData icon, Color color) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          boxShadow: [
             BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 2),
          ],
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Column(
          children: [
            // Botón atrás flotante
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  // Chip de info de ruta
                  if (_route != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                    ),
                    child: Text(
                      '${_route!.distanceKm.toStringAsFixed(1)} km • ${(_route!.durationMinutes * 1.2).ceil()} min',
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tarjeta de direcciones flotante
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _buildAddressRow(Icons.circle, Colors.white, widget.origin.address),
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(width: 2, height: 16, color: Colors.white.withOpacity(0.2)),
                    ),
                  ),
                  _buildAddressRow(Icons.location_on, const Color(0xFFFFD700), widget.destination.address),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16), // Icono más pequeño (estilo Uber)
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161616),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, -5))],
          ),
          child: Column(
            children: [
              // Handle de arrastre
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Título
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Elige tu viaje',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lista de vehículos
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quotes.length,
                  itemBuilder: (context, index) {
                    final quote = _quotes[index];
                    final isSelected = quote.vehicleType == _selectedVehicleType;
                    
                    return GestureDetector(
                      onTap: () => setState(() => _selectedVehicleType = quote.vehicleType),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFD700).withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Imagen vehículo (Icono por ahora)
                            Container(
                              width: 60,
                              height: 60,
                              // Aquí podrías usar Image.asset si tienes los assets
                              decoration: BoxDecoration(
                                // color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getVehicleIcon(quote.vehicleType),
                                color: isSelected ? const Color(0xFFFFD700) : Colors.grey[400],
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _capitalize(quote.vehicleType),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    // Hora de llegada estimada
                                    'Llega en 3-5 min', 
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Precio
                            Text(
                              quote.formattedPrice,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Botón Solicitar
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _requestTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Solicitar ${_capitalize(_selectedVehicleType)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Ups, algo salió mal',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Error desconocido',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _requestTrip() async {
    final selectedQuote = _quotes.firstWhere((q) => q.vehicleType == _selectedVehicleType);

    // 1. Navegar a pantalla de selección de punto de encuentro
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickMeetingPointScreen(
          initialLocation: widget.origin.toLatLng(), // Start at origin
        ),
      ),
    );

    // Si el usuario no confirmó (volvió atrás), cancelamos
    if (result == null) return;

    final newOriginLat = result['latitude'] as double;
    final newOriginLng = result['longitude'] as double;
    final newOriginAddress = result['address'] as String;

    // Mostrar loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
    );

    try {
      final session = await UserService.getSavedSession();
      if (session == null) throw Exception('No hay sesión activa.');

      final userId = session['id'] as int;

      final response = await TripRequestService.createTripRequest(
        userId: userId,
        latitudOrigen: newOriginLat, // Usamos la nueva ubicación confirmada
        longitudOrigen: newOriginLng,
        direccionOrigen: newOriginAddress,
        latitudDestino: widget.destination.latitude,
        longitudDestino: widget.destination.longitude,
        direccionDestino: widget.destination.address,
        tipoServicio: 'viaje',
        tipoVehiculo: _selectedVehicleType,
        distanciaKm: selectedQuote.distanceKm,
        duracionMinutos: selectedQuote.durationMinutes,
        precioEstimado: selectedQuote.price,
      );

      if (mounted) Navigator.pop(context); // Cerrar loader

      if (response['success'] == true) {
        final solicitudId = int.parse(response['solicitud_id'].toString());
        
        // Navegar a la pantalla de búsqueda con animación suave
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => SearchingDriverScreen(
              solicitudId:  solicitudId,
              pickupLocation: LatLng(newOriginLat, newOriginLng),
              destinationLocation: widget.destination.toLatLng(),
              pickupAddress: newOriginAddress,
              destinationAddress: widget.destination.address,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Helpers
  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motocicleta': return Icons.two_wheeler;
      case 'moto': return Icons.two_wheeler;
      case 'carro': return Icons.directions_car;
      case 'moto_carga': return Icons.delivery_dining;
      default: return Icons.directions_car;
    }
  }
}
