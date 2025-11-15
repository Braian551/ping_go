import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../global/services/osm_service.dart';
import '../../../../global/services/auth/user_service.dart';
import '../../services/trip_request_service.dart';
import 'select_destination_screen.dart';

/// Modelo para cotización del viaje
class TripQuote {
  final double distanceKm;
  final int durationMinutes;
  final double basePrice;
  final double distancePrice;
  final double timePrice;
  final double surchargePrice;
  final double totalPrice;
  final String periodType;
  final double surchargePercentage;

  TripQuote({
    required this.distanceKm,
    required this.durationMinutes,
    required this.basePrice,
    required this.distancePrice,
    required this.timePrice,
    required this.surchargePrice,
    required this.totalPrice,
    required this.periodType,
    required this.surchargePercentage,
  });

  String get formattedTotal => '\$${totalPrice.toStringAsFixed(0)}';
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
  String get formattedDuration => '$durationMinutes min';
}

/// Pantalla simplificada de preview del viaje
class TripPreviewScreen extends StatefulWidget {
  final SimpleLocation origin;
  final SimpleLocation destination;
  final String vehicleType;

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

  OsmRoute? _route;
  TripQuote? _quote;
  bool _isLoading = true;
  String? _errorMessage;
  late String _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _selectedVehicleType = widget.vehicleType;
    _loadRouteAndQuote();
  }

  Future<void> _loadRouteAndQuote() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener ruta usando OSM
      final route = await OsmService.getRoute([
        widget.origin.toLatLng(),
        widget.destination.toLatLng(),
      ]);

      if (route == null) {
        throw Exception('No se pudo calcular la ruta');
      }

      setState(() {
        _route = route;
        _isLoading = false;
      });

      // Ajustar el mapa para mostrar la ruta completa
      _fitMapToRoute();

      // Calcular cotización
      final quote = _calculateQuote(route);
      setState(() {
        _quote = quote;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fitMapToRoute() async {
    if (_route == null) return;

    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (var point in _route!.geometry) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    final camera = CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.only(
        top: 100,
        bottom: 300,
        left: 50,
        right: 50,
      ),
    );

    _mapController.fitCamera(camera);
  }

  TripQuote _calculateQuote(OsmRoute route) {
    final hour = DateTime.now().hour;
    final distanceKm = route.distanceKm;
    final durationMinutes = route.durationMinutes.ceil();

    final config = _getVehicleConfig(_selectedVehicleType);

    final basePrice = config['tarifa_base']!;
    final distancePrice = distanceKm * config['costo_por_km']!;
    final timePrice = durationMinutes * config['costo_por_minuto']!;

    String periodType = 'normal';
    double surchargePercentage = 0.0;

    if ((hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)) {
      periodType = 'hora_pico';
      surchargePercentage = config['recargo_hora_pico']!;
    } else if (hour >= 22 || hour <= 6) {
      periodType = 'nocturno';
      surchargePercentage = config['recargo_nocturno']!;
    }

    final subtotal = basePrice + distancePrice + timePrice;
    final surchargePrice = subtotal * (surchargePercentage / 100);
    final total = subtotal + surchargePrice;
    final finalTotal = total < config['tarifa_minima']! ? config['tarifa_minima']! : total;

    return TripQuote(
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      basePrice: basePrice,
      distancePrice: distancePrice,
      timePrice: timePrice,
      surchargePrice: surchargePrice,
      totalPrice: finalTotal,
      periodType: periodType,
      surchargePercentage: surchargePercentage,
    );
  }

  Map<String, double> _getVehicleConfig(String vehicleType) {
    switch (vehicleType) {
      case 'moto':
        return {
          'tarifa_base': 4000.0,
          'costo_por_km': 2000.0,
          'costo_por_minuto': 250.0,
          'tarifa_minima': 6000.0,
          'recargo_hora_pico': 15.0,
          'recargo_nocturno': 20.0,
        };
      case 'carro':
        return {
          'tarifa_base': 6000.0,
          'costo_por_km': 3000.0,
          'costo_por_minuto': 400.0,
          'tarifa_minima': 9000.0,
          'recargo_hora_pico': 20.0,
          'recargo_nocturno': 25.0,
        };
      case 'moto_carga':
        return {
          'tarifa_base': 5000.0,
          'costo_por_km': 2500.0,
          'costo_por_minuto': 300.0,
          'tarifa_minima': 7500.0,
          'recargo_hora_pico': 15.0,
          'recargo_nocturno': 20.0,
        };
      case 'carro_carga':
        return {
          'tarifa_base': 8000.0,
          'costo_por_km': 3500.0,
          'costo_por_minuto': 450.0,
          'tarifa_minima': 12000.0,
          'recargo_hora_pico': 20.0,
          'recargo_nocturno': 25.0,
        };
      default:
        return {
          'tarifa_base': 4000.0,
          'costo_por_km': 2000.0,
          'costo_por_minuto': 250.0,
          'tarifa_minima': 6000.0,
          'recargo_hora_pico': 15.0,
          'recargo_nocturno': 20.0,
        };
    }
  }

  String _getVehicleName(String type) {
    switch (type) {
      case 'moto': return 'Moto';
      case 'carro': return 'Carro';
      case 'moto_carga': return 'Moto Carga';
      case 'carro_carga': return 'Carro Carga';
      default: return 'Vehículo';
    }
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'moto': return Icons.two_wheeler;
      case 'carro': return Icons.directions_car;
      case 'moto_carga': return Icons.delivery_dining;
      case 'carro_carga': return Icons.local_shipping;
      default: return Icons.two_wheeler;
    }
  }

  String _getVehicleDescription(String vehicleType) {
    switch (vehicleType) {
      case 'moto':
        return 'Rápido y económico';
      case 'carro':
        return 'Cómodo y espacioso';
      case 'moto_carga':
        return 'Para paquetes pequeños';
      case 'carro_carga':
        return 'Para mudanzas y carga';
      default:
        return 'Vehículo seleccionado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Mapa
          _buildMap(),

          // Panel superior con información
          _buildTopPanel(),

          // Panel inferior con detalles
          if (_quote != null) _buildBottomPanel(),

          // Indicador de carga
          if (_isLoading) _buildLoadingOverlay(),

          // Mensaje de error
          if (_errorMessage != null) _buildErrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.origin.toLatLng(),
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        // Tiles de OSM
        TileLayer(
          urlTemplate: OsmService.getTileUrl(),
          userAgentPackageName: 'com.example.ping_go',
        ),

        // Línea de ruta simple
        if (_route != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route!.geometry,
                strokeWidth: 6,
                color: const Color(0xFFFFD700),
                borderStrokeWidth: 0,
              ),
            ],
          ),

        // Marcadores simples con colores amarillo y negro
        MarkerLayer(
          markers: [
            // Origen
            Marker(
              point: widget.origin.toLatLng(),
              width: 40,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.black, width: 3),
                  ),
                ),
                child: const Icon(
                  Icons.circle,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ),

            // Destino
            Marker(
              point: widget.destination.toLatLng(),
              width: 40,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.black, width: 3),
                  ),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopPanel() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0x33FFD700),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con botón de regresar
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x26FFD700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFFFFD700)),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_quote != null)
                    Expanded(
                      child: Text(
                        '${_quote!.formattedDistance} • ${_quote!.formattedDuration}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Información de ubicaciones con colores amarillo y negro
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFD700),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0x33FFD700),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Origen
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.circle,
                            color: Colors.black,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.origin.address,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Línea divisoria
                    Container(
                      height: 1,
                      color: const Color(0x33FFD700),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    const SizedBox(height: 8),

                    // Destino
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD700),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.destination.address,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Información del vehículo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFD700),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getVehicleIcon(_selectedVehicleType),
                      size: 24,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getVehicleName(_selectedVehicleType),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getVehicleDescription(_selectedVehicleType),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _quote!.formattedTotal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón de solicitar viaje
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _confirmTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Solicitar viaje',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: const Color(0xB3000000),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFFD700),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: const Color(0xB3000000),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Volver',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _loadRouteAndQuote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmTrip() async {
    if (_quote == null || _route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo calcular el viaje'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    try {
      // Obtener usuario de la sesión
      final session = await UserService.getSavedSession();
      if (session == null) {
        throw Exception('No hay sesión activa. Por favor inicia sesión.');
      }

      final userId = session['id'] as int?;
      if (userId == null) {
        throw Exception('Usuario no válido. Por favor inicia sesión nuevamente.');
      }

      // Crear solicitud de viaje
      final response = await TripRequestService.createTripRequest(
        userId: userId,
        latitudOrigen: widget.origin.latitude,
        longitudOrigen: widget.origin.longitude,
        direccionOrigen: widget.origin.address,
        latitudDestino: widget.destination.latitude,
        longitudDestino: widget.destination.longitude,
        direccionDestino: widget.destination.address,
        tipoServicio: 'viaje',
        tipoVehiculo: _selectedVehicleType,
        distanciaKm: _quote!.distanceKm,
        duracionMinutos: _quote!.durationMinutes,
        precioEstimado: _quote!.totalPrice,
      );

      // Cerrar diálogo de carga
      if (mounted) Navigator.of(context).pop();

      if (response['success'] == true) {
        final conductoresEncontrados = response['conductores_encontrados'] ?? 0;

        // Mostrar mensaje de "próximamente disponible" en lugar de navegar
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.black,
                title: const Text(
                  'Funcionalidad en desarrollo',
                  style: TextStyle(color: Color(0xFFFFFF00), fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'La búsqueda de conductores estará disponible próximamente.',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.of(context).pop(); // Volver a la pantalla anterior
                    },
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(color: Color(0xFFFFFF00)),
                    ),
                  ),
                ],
              );
            },
          );
        }

        // Mostrar mensaje informativo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                conductoresEncontrados > 0
                    ? 'Buscando entre $conductoresEncontrados ${conductoresEncontrados == 1 ? "conductor disponible" : "conductores disponibles"}'
                    : 'Buscando conductores disponibles...',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar viaje: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
