import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/trip_request_service.dart';
import '../../../../global/services/osm_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../widgets/dialogs/custom_dialog.dart';
import 'select_destination_screen.dart';
import '../../services/trip_request_service.dart';
import 'client_trip_summary_screen.dart';

class TripStatusScreen extends StatefulWidget {
  final int solicitudId;
  final SimpleLocation origin;
  final SimpleLocation destination;
  final List<LatLng>? routePoints;

  const TripStatusScreen({
    super.key,
    required this.solicitudId,
    required this.origin,
    required this.destination,
    this.routePoints,
  });

  @override
  State<TripStatusScreen> createState() => _TripStatusScreenState();
}

class _TripStatusScreenState extends State<TripStatusScreen> {
  final MapController _mapController = MapController();
  Timer? _pollTimer;
  Map<String, dynamic>? _trip;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Real-time user location
  LatLng? _currentUserLocation;
  StreamSubscription<Position>? _positionStream;
  
  // State tracking for notifications
  String? _lastStatus;
  bool _driverArrivedNotified = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _startLocationStream();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  void _startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (mounted) {
        setState(() {
          _currentUserLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });
    
    // Get initial position
    Geolocator.getCurrentPosition().then((position) {
      if (mounted) {
        setState(() {
          _currentUserLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  /// Get profile image URL with proper base URL prefix
  String? _getProfileImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    final url = AppConfig.resolveImageUrl(relativePath);
    return url.isNotEmpty ? url : null;
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await TripRequestService.getTripStatus(solicitudId: widget.solicitudId);
      if (response['success'] == true) {
        final newTrip = response['trip'];
        final newStatus = newTrip['estado'];
        
        // Check for status changes
        if (_lastStatus != newStatus) {
           if (newStatus == 'en_sitio' && !_driverArrivedNotified) {
             _driverArrivedNotified = true;
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('¡Tu conductor ha llegado al punto de encuentro!'),
                   backgroundColor: Color(0xFFFFD700),
                   duration: Duration(seconds: 5),
                   behavior: SnackBarBehavior.floating,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                 ),
               );
             }
           } else if (newStatus == 'completada') {
             // Navigate to summary
             _pollTimer?.cancel();
             if (mounted) {
               Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(builder: (context) => ClientTripSummaryScreen(
                   solicitudId: widget.solicitudId,
                   tripData: newTrip, // Pass available data, screen will fetch more
                 )),
               );
             }
             return;
           }
           _lastStatus = newStatus;
        }

        // Only update state if data changed to prevent image flickering/reloading
        bool shouldUpdate = false;
        
        if (_trip == null) {
          shouldUpdate = true;
        } else {
          // Compare critical fields
          final oldDriver = _trip!['conductor'];
          final newDriver = newTrip['conductor'];
          
          final oldLat = oldDriver?['ubicacion']?['latitud'];
          final oldLng = oldDriver?['ubicacion']?['longitud'];
          final newLat = newDriver?['ubicacion']?['latitud'];
          final newLng = newDriver?['ubicacion']?['longitud'];
          
          if (_trip!['estado'] != newTrip['estado'] ||
              oldLat != newLat ||
              oldLng != newLng ||
              oldDriver?['foto'] != newDriver?['foto']) {
            shouldUpdate = true;
          }
        }

        if (shouldUpdate) {
          setState(() {
            _trip = newTrip;
            _isLoading = false;
          });
          // Fit bounds to show driver, user location and destination
          _fitMapBounds();
        } else if (_isLoading) {
           setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error desconocido';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
          setState(() {
            _errorMessage = e.toString();
            _isLoading = false;
          });
      }
    }
  }

  void _fitMapBounds() {
    if (_trip == null) return;
    
    final status = _trip!['estado'];
    List<LatLng> points = [];
    
    // Logic for bounding box based on status
    if (status == 'en_transito' || status == 'recogido') {
      // In trip: Focus on Driver + Destination
      points.add(widget.destination.toLatLng());
      if (_trip!['conductor'] != null) {
         final dLat = _trip!['conductor']['ubicacion']['latitud'];
         final dLng = _trip!['conductor']['ubicacion']['longitud'];
         if (dLat != null && dLng != null) points.add(LatLng(dLat, dLng));
      }
    } else if (status == 'en_sitio') {
      // Arrived: Focus tightly on Pickup (Meeting point)
      points.add(widget.origin.toLatLng());
      // Add driver too to show he is there
       if (_trip!['conductor'] != null) {
         final dLat = _trip!['conductor']['ubicacion']['latitud'];
         final dLng = _trip!['conductor']['ubicacion']['longitud'];
         if (dLat != null && dLng != null) points.add(LatLng(dLat, dLng));
      }
    } else {
      // Approaching: Focus on Driver + Pickup
      points.add(widget.origin.toLatLng());
      if (_trip!['conductor'] != null) {
         final dLat = _trip!['conductor']['ubicacion']['latitud'];
         final dLng = _trip!['conductor']['ubicacion']['longitud'];
         if (dLat != null && dLng != null) points.add(LatLng(dLat, dLng));
      }
    }
    
    // Always include user location if available? Maybe not if we want to focus on the action.
    // If user is far from pickup, we might want to show them relative to pickup.
    if (_currentUserLocation != null && status != 'en_transito') {
      points.add(_currentUserLocation!);
    }
    
    if (points.length >= 1) { // 1 point is enough to center, 2 for bounds
      if (points.length == 1) {
         _mapController.move(points.first, 16);
      } else {
        double minLat = points.map((p) => p.latitude).reduce(math.min);
        double maxLat = points.map((p) => p.latitude).reduce(math.max);
        double minLng = points.map((p) => p.longitude).reduce(math.min);
        double maxLng = points.map((p) => p.longitude).reduce(math.max);
        
        final bounds = LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        );
        
        try {
          _mapController.fitCamera(CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(80), // More padding for panels
          ));
        } catch (_) {}
      }
    }
  }

  String _getVehicleAsset() {
    if (_trip == null || _trip!['conductor'] == null) {
      return 'assets/images/car_top_view.png';
    }
    
    final vehicleType = _trip!['conductor']['vehiculo']?['tipo']?.toString().toLowerCase() ?? '';
    
    if (vehicleType.contains('moto')) {
      return 'assets/images/moto_top_view.png';
    }
    return 'assets/images/car_top_view.png';
  }
  
  // Determina si se puede salir directamente o se debe confirmar cancelación
  bool get _shouldInterceptBack {
    if (_trip == null) return false;
    return _canCancel(_trip!['estado']);
  }

  @override
  Widget build(BuildContext context) {
    return  PopScope(
      canPop: !_shouldInterceptBack,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        // Show cancel dialog when trying to go back if trip is active
        _showCancelDialog(isBackNavigation: true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Estado del viaje',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () {
              if (_shouldInterceptBack) {
                _showCancelDialog(isBackNavigation: true);
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            // Dark themed map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.origin.toLatLng(),
                initialZoom: 14,
                backgroundColor: const Color(0xFF1A1A1A),
              ),
              children: [
                TileLayer(
                  urlTemplate: OsmService.getTileUrl(),
                  userAgentPackageName: 'com.example.ping_go',
                  // Carto dark tiles ya tienen tema oscuro nativo
                ),
                
                // Route polyline
                if (widget.routePoints != null && widget.routePoints!.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.routePoints!,
                        color: const Color(0xFFFFD700),
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                
                // Markers
                MarkerLayer(
                  markers: [
                    // User current real-time location
                    if (_currentUserLocation != null)
                      Marker(
                        point: _currentUserLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_pin_circle,
                              color: Colors.blue,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    
                    // Meeting point (origin/pickup)
                    Marker(
                      point: widget.origin.toLatLng(),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.my_location,
                            color: Colors.green,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    
                    // Destination
                    Marker(
                      point: widget.destination.toLatLng(),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.flag,
                            color: Color(0xFFFFD700),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    
                    // Driver location with vehicle icon
                    if (_trip != null && _trip!['conductor'] != null)
                      Marker(
                        point: LatLng(
                          _trip!['conductor']['ubicacion']['latitud'] ?? 0.0,
                          _trip!['conductor']['ubicacion']['longitud'] ?? 0.0,
                        ),
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          _getVehicleAsset(),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                color: Colors.black,
                                size: 36,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Loading indicator
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                ),
              ),

            // Bottom info card with glassmorphism
            if (_trip != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildInfoCard(),
              ),

            // Recenter button
            Positioned(
              bottom: _trip != null ? 280 : 24,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'recenter_btn',
                mini: true,
                onPressed: _fitMapBounds,
                backgroundColor: const Color(0xFF1E1E1E),
                child: const Icon(Icons.my_location, color: Color(0xFFFFD700)),
              ),
            ),

            // Error message
            if (_errorMessage != null)
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: SafeArea(
            top: false,
            child: _trip!['conductor'] != null
                ? _buildDriverInfo()
                : _buildSearchingState(),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(
          color: Color(0xFFFFD700),
          strokeWidth: 3,
        ),
        const SizedBox(height: 20),
        const Text(
          'Buscando conductor cercano...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Esto puede tomar unos segundos',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDriverInfo() {
    final conductor = _trip!['conductor'];
    final profileUrl = _getProfileImageUrl(conductor['foto']);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        
        // Status badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: _getStatusColor(_trip!['estado']).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(_trip!['estado']),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getStatusIcon(_trip!['estado']),
                color: _getStatusColor(_trip!['estado']),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(_trip!['estado']),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getStatusColor(_trip!['estado']),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Driver info row
        Row(
          children: [
            // Profile picture with robust error handling
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 2,
                ),
                color: Colors.grey[800],
              ),
              child: ClipOval(
                child: profileUrl != null
                    ? Image.network(
                        profileUrl,
                        key: ValueKey(profileUrl),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFFFFD700).withOpacity(0.5),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('DEBUG TripStatus: Image load error: $error');
                          return const Center(
                            child: Icon(Icons.person, color: Colors.white54, size: 32),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.person, color: Colors.white54, size: 32),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Name and rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conductor['nombre'] ?? 'Conductor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${conductor['calificacion'] ?? '5.0'}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          conductor['vehiculo']?['placa'] ?? conductor['placa'] ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // ETA or Distance to Destination
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildEtaOrDistanceDisplay(conductor),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Vehicle info
        if (conductor['vehiculo'] != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVehicleInfo(
                  Icons.directions_car,
                  conductor['vehiculo']['marca'] ?? '-',
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildVehicleInfo(
                  Icons.model_training,
                  conductor['vehiculo']['modelo'] ?? '-',
                ),
                Container(width: 1, height: 24, color: Colors.white24),
                _buildVehicleInfo(
                  Icons.palette,
                  conductor['vehiculo']['color'] ?? '-',
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 20),
        
        // Cancel button (only if trip not started)
        if (_canCancel(_trip!['estado']))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(), // Standard call
              icon: const Icon(Icons.close, size: 20),
              label: const Text('Cancelar viaje'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEtaOrDistanceDisplay(Map<String, dynamic> conductor) {
    if (_trip!['estado'] == 'en_transito' || _trip!['estado'] == 'recogido') {
      // Show distance to destination
      // Calculate locally if driver location is available
      final dLat = conductor['ubicacion']['latitud'];
      final dLng = conductor['ubicacion']['longitud'];
      
      String displayValue = '--';
      String unit = 'km';
      
      if (dLat != null && dLng != null) {
        final distanceInMeters = const Distance().as(
          LengthUnit.Meter,
          LatLng(dLat, dLng),
          widget.destination.toLatLng(),
        );
        
        if (distanceInMeters < 1000) {
          displayValue = distanceInMeters.toInt().toString();
          unit = 'm';
        } else {
          displayValue = (distanceInMeters / 1000).toStringAsFixed(1);
          unit = 'km';
        }
      }
      
       return Column(
        children: [
          Text(
            displayValue,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 12,
            ),
          ),
          const Text(
            'destino',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      );
    }
    
    // Default: ETA to pickup
    return Column(
      children: [
        Text(
          '${conductor['eta_minutos'] ?? '-'}',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const Text(
          'min',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ],
    );
  }

  void _showCancelDialog({bool isBackNavigation = false}) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.warning,
        title: '¿Cancelar viaje?',
        message: '¿Estás seguro de que deseas cancelar la solicitud? Esta acción no se puede deshacer.',
        primaryButtonText: 'No, mantener viaje',
        secondaryButtonText: 'Sí, cancelar',
        onPrimaryPressed: () => Navigator.of(context).pop(), // Close dialog
        onSecondaryPressed: () {
          Navigator.of(context).pop(); // Close dialog first
          _cancelTrip();
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'conductor_asignado':
      case 'aceptada': // Handle 'aceptada' same as assigned
        return Colors.blue;
      case 'en_sitio':
        return const Color(0xFFFFD700);
      case 'en_transito':
      case 'recogido':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'conductor_asignado':
      case 'aceptada':
        return Icons.navigation;
      case 'en_sitio':
        return Icons.place;
      case 'en_transito':
      case 'recogido':
        return Icons.local_taxi;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'conductor_asignado':
      case 'aceptada':
        return 'Conductor en camino';
      case 'en_sitio':
        return '¡Tu conductor ha llegado!';
      case 'en_transito':
      case 'recogido':
        return 'En viaje hacia tu destino';
      default:
        return 'Estado: ${status ?? 'desconocido'}';
    }
  }

  bool _canCancel(String? status) {
    return status == 'conductor_asignado' || 
           status == 'en_sitio' || 
           status == 'pendiente' || 
           status == 'aceptada';
  }

  Future<void> _cancelTrip() async {
    try {
      final canceled = await TripRequestService.cancelTripRequest(_trip!['id']);
      if (canceled) {
        if (mounted) {
           // Show success dialog or snackbar
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Solicitud cancelada'),
               backgroundColor: Colors.green,
             ),
           );
           
           // Navigate back to home or previous screen
           Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => CustomDialog(
            type: DialogType.error,
            title: 'Error',
            message: 'No se pudo cancelar el viaje: $e',
            primaryButtonText: 'Entendido',
          ),
        );
      }
    }
  }
}
