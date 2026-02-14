import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../global/services/osm_service.dart';
import '../../services/conductor_service.dart';
import 'trip_summary_screen.dart';
import '../../../../core/config/app_config.dart';
import '../../../user/services/trip_request_service.dart';
import '../../../../routes/route_names.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DriverTripScreen extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final Position conductorLocation;
  final int conductorId;
  final String? vehicleType;

  const DriverTripScreen({
    super.key, 
    required this.tripData,
    required this.conductorLocation,
    required this.conductorId,
    this.vehicleType,
  });

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen> {
  // Helper to get solicitud ID regardless of the key name (id or solicitud_id)
  int get _solicitudId {
    final id = widget.tripData['solicitud_id'] ?? widget.tripData['id'];
    if (id == null) return 0;
    return int.tryParse(id.toString()) ?? 0;
  }

  final MapController _mapController = MapController();
  
  // State
  OsmRoute? _route;
  bool _isLoadingRoute = true;
  bool _isAdvancing = false;
  String _currentStatus = 'En camino'; // 'En camino', 'Llegué', 'En viaje', 'Finalizado'
  
  // Tracking
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _accumulatedDistanceKm = 0.0;
  double _currentHeading = 0.0;
  DateTime? _tripStartTime;
  Timer? _durationTimer;
  Duration _tripDuration = Duration.zero;
  Timer? _statusPollTimer;

  @override
  void initState() {
    super.initState();
    
    // Recovery: Map backend status to frontend status
    final backendStatus = widget.tripData['estado'];
    if (backendStatus == 'en_sitio') {
      _currentStatus = 'Llegué';
    } else if (backendStatus == 'en_transito' || backendStatus == 'recogido') {
      _currentStatus = 'En viaje';
      _restoreTripMetrics(); // Restore duration and distance
    } else {
      _currentStatus = 'En camino';
    }

    _loadCurrentRoute();
    _startLocationTracking();
    _startStatusPolling();
  }

  Future<void> _restoreTripMetrics() async {
    // 1. Restore Duration from backend timestamp
    final recogidoEn = widget.tripData['recogido_en'];
    if (recogidoEn != null) {
      try {
        DateTime startTime;
        if (recogidoEn is DateTime) {
          startTime = recogidoEn;
        } else {
          // Expected format: "YYYY-MM-DD HH:MM:SS"
          startTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(recogidoEn.toString());
        }
        
        // Adjust for local time if necessary (assuming DB is UTC or same as device)
        // For now, simple parse
        _tripStartTime = startTime;
        
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _tripDuration = DateTime.now().difference(_tripStartTime!);
            });
          }
        });
      } catch (e) {
        print('Error parsing recogido_en: $e');
        _startTripTimer(); // Fallback to now
      }
    } else {
      _startTripTimer(); // Fallback if no timestamp
    }

    // 2. Restore Distance from local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = 'trip_dist_${_solicitudId}';
      final savedDist = prefs.getDouble(savedKey);
      if (savedDist != null) {
        setState(() {
          _accumulatedDistanceKm = savedDist;
        });
      }
    } catch (e) {
      print('Error restoring distance: $e');
    }
  }

  Future<void> _saveDistance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = 'trip_dist_${_solicitudId}';
      await prefs.setDouble(savedKey, _accumulatedDistanceKm);
    } catch (e) {
      print('Error saving distance: $e');
    }
  }

  Future<void> _clearPersistedMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = 'trip_dist_${_solicitudId}';
      await prefs.remove(savedKey);
    } catch (e) {
      print('Error clearing distance: $e');
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    _statusPollTimer?.cancel();
    super.dispose();
  }

  void _startLocationTracking() {
    final locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters for smoother rotation
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _updateTripMetrics(position);

      // Update heading if speed is sufficient (> 1 m/s approx 3.6 km/h) to avoid noise
      if (position.speed > 1.0) {
        _currentHeading = position.heading;
      }

      _updateMapPosition(position);
    });
  }

  void _updateTripMetrics(Position newPos) {
    if (_currentStatus != 'En viaje') return; // Only track metrics during the trip itself

    if (_lastPosition != null) {
      final dist = Geolocator.distanceBetween(
        _lastPosition!.latitude, _lastPosition!.longitude,
        newPos.latitude, newPos.longitude
      );
      final newDistKm = dist / 1000;
      _accumulatedDistanceKm += newDistKm; 
      
      // Save periodically (every time distance changes significantly or just every update)
      if (newDistKm > 0.001) { // > 1 meter change
        _saveDistance();
      }
    }
    _lastPosition = newPos;
  }

  void _updateMapPosition(Position pos) {
     // Optional: Keep camera centered or just update driver marker
     // We will update the marker via setState or ValueNotifier if we want smooth animation
     // For now, simple setState to refresh UI
     if (mounted) setState(() {});
  }

  void _startStatusPolling() {
    _statusPollTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
       final solicitudId = _solicitudId;
       try {
         final response = await TripRequestService.getTripStatus(solicitudId: solicitudId);
         if (response['success'] == true) {
           final status = response['trip']['estado'];
           if (status == 'cancelada' && mounted) {
             _statusPollTimer?.cancel();
             _positionStream?.cancel();
             _durationTimer?.cancel();
             
             showDialog(
               context: context,
               barrierDismissible: false,
               builder: (ctx) => AlertDialog(
                 backgroundColor: const Color(0xFF1E1E1E),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 title: const Text('Viaje cancelado', style: TextStyle(color: Colors.white)),
                 content: const Text('El cliente ha cancelado la solicitud de viaje.', style: TextStyle(color: Colors.grey)),
                 actions: [
                   TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          RouteNames.conductorHome, 
                          (route) => false,
                          arguments: {'conductor_user': widget.tripData['conductor_user'] ?? widget.tripData}
                        );
                      },
                     child: const Text('Entendido', style: TextStyle(color: Color(0xFFFFD700))),
                   ),
                 ],
               ),
             );
           }
         }
       } catch (e) {
         print('Error polling trip status: $e');
       }
    });
  }
  
  void _startTripTimer() {
    _tripStartTime = DateTime.now();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _tripDuration = DateTime.now().difference(_tripStartTime!);
        });
      }
    });
  }

  Future<void> _loadCurrentRoute() async {
    setState(() => _isLoadingRoute = true);
    
    // Determine start position (GPS if available, else initial location)
    final startPos = _lastPosition != null 
        ? LatLng(_lastPosition!.latitude, _lastPosition!.longitude)
        : LatLng(widget.conductorLocation.latitude, widget.conductorLocation.longitude);
    
    LatLng targetPos;
    if (_currentStatus == 'En viaje') {
      // Phase 2: Going to Destination (Dropoff)
      targetPos = LatLng(
        double.tryParse(widget.tripData['latitud_destino']?.toString() ?? '') ?? 0.0, 
        double.tryParse(widget.tripData['longitud_destino']?.toString() ?? '') ?? 0.0
      );
    } else {
      // Phase 1: Going to Pickup (Client)
      targetPos = LatLng(
        double.tryParse(widget.tripData['latitud_recogida']?.toString() ?? '') ?? 0.0, 
        double.tryParse(widget.tripData['longitud_recogida']?.toString() ?? '') ?? 0.0
      );
    }

    try {
      final route = await OsmService.getRoute([startPos, targetPos]);
      setState(() {
        _route = route;
        _isLoadingRoute = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _fitMapBounds(startPos, targetPos);
      });
    } catch (e) {
      print('Error loading current route: $e');
      setState(() => _isLoadingRoute = false);
    }
  }

  void _fitMapBounds(LatLng p1, LatLng p2) {
    // Basic check to see if the controller is ready
    if (!_mapController.mapEventStream.isBroadcast) return;
    
    // Safety check: if points are identical, fitCamera with bounds will crash (zero area)
    if (p1.latitude == p2.latitude && p1.longitude == p2.longitude) {
      _mapController.move(p1, 15);
      return;
    }

    try {
      // Validate coordinates are finite
      if (!p1.latitude.isFinite || !p1.longitude.isFinite || 
          !p2.latitude.isFinite || !p2.longitude.isFinite) {
        print('DriverTripScreen: Latitude or longitude is not finite');
        return;
      }

      final bounds = LatLngBounds.fromPoints([p1, p2]);
      
      // Ensure bounds have a non-zero area to avoid infinite zoom
      if (bounds.north == bounds.south && bounds.east == bounds.west) {
        _mapController.move(p1, 15);
        return;
      }

      _mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ));
    } catch (e) {
      print('DriverTripScreen: Error fitting map bounds: $e');
      _mapController.move(p1, 15);
    }
  }
  
  void _openExternalNavigation() async {
    _openNavigation('google'); // Default to Google
  }
  
  void _openNavigation(String app) async {
    double lat, lng;
    // Determine destination based on trip status
     if (_currentStatus == 'En camino' || _currentStatus == 'Llegué') {
        // Phase 1: Going to Pickup (Client)
        lat = double.tryParse(widget.tripData['latitud_recogida']?.toString() ?? '') ?? 0.0;
        lng = double.tryParse(widget.tripData['longitud_recogida']?.toString() ?? '') ?? 0.0;
     } else {
        // Phase 2: Going to Destination (Dropoff)
        lat = double.tryParse(widget.tripData['latitud_destino']?.toString() ?? '') ?? 0.0;
        lng = double.tryParse(widget.tripData['longitud_destino']?.toString() ?? '') ?? 0.0;
     }

    Uri url;
    if (app == 'waze') {
      // Waze: Trigger navigation directly
      url = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
    } else {
      // Google Maps: Trigger 'Navigation Mode' directly (not just search)
      // Note: 'google.navigation:q=' forces turn-by-turn navigation on Android
      url = Uri.parse('google.navigation:q=$lat,$lng&mode=d'); 
    }
    
    try {
      // Try launching the native app in external mode
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      
      if (!launched) {
        throw 'Native app not found';
      }
    } catch (e) {
      print('Native navigation failed: $e. Falling back to web.');
      
      // Fallback: Google Maps Web Directions
      // Using 'dir' action ensures a route is calculated, not just a pin drop
      final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
      
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar viaje', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro que deseas cancelar este viaje?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelTrip();
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTrip() async {
    final solicitudId = _solicitudId;
    
    final success = await ConductorService.updateTripStatus(
      solicitudId: solicitudId, 
      estado: 'cancelada',
      conductorId: widget.conductorId,
    );

    if (success) {
      await _clearPersistedMetrics();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          RouteNames.conductorHome, 
          (route) => false,
          arguments: {'conductor_user': widget.tripData['conductor_user'] ?? widget.tripData}
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viaje cancelado exitosamente'), backgroundColor: Colors.orange),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cancelar el viaje'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _advanceState() async {
    if (_isAdvancing) return;
    
    setState(() => _isAdvancing = true);
    
    String nextState = '';
    String backendState = '';

    if (_currentStatus == 'En camino') {
      nextState = 'Llegué'; 
      backendState = 'en_sitio';
    } else if (_currentStatus == 'Llegué') {
      nextState = 'En viaje';
      backendState = 'en_progreso';
    } else if (_currentStatus == 'En viaje') {
       backendState = 'completada';
    }

    if (backendState.isEmpty) {
        // Case for 'Finalizado' or invalid
        if (_currentStatus == 'Finalizado') {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            RouteNames.conductorHome, 
            (route) => false,
            arguments: {'conductor_user': widget.tripData['conductor_user'] ?? widget.tripData}
          );
        }
        setState(() => _isAdvancing = false);
        return;
    }

    // Attempt update
    final solicitudId = _solicitudId;
    
    double? finalDist;
    int? finalDur;
    
    if (backendState == 'completada') {
       finalDist = _accumulatedDistanceKm;
       finalDur = _tripDuration.inSeconds;
    }

    final success = await ConductorService.updateTripStatus(
      solicitudId: solicitudId, 
      estado: backendState,
      conductorId: widget.conductorId,
      distanciaKm: finalDist,
      duracionSegundos: finalDur,
    );
    
    if (success) {
        if (backendState == 'completada') {
            await _clearPersistedMetrics();
            _durationTimer?.cancel();
            _positionStream?.cancel();
            
            // Capture final metrics before navigation
            final finalDistVal = _accumulatedDistanceKm;
            final finalDurSeconds = _tripDuration.inSeconds;

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripSummaryScreen(
                    tripData: widget.tripData, 
                    realDistanceKm: finalDistVal, 
                    realDurationSeconds: finalDurSeconds,
                    conductorId: widget.conductorId,
                  ),
                ),
              ).then((_) {
                 if (mounted) Navigator.pop(context);
              });
            }
        } else {
            setState(() {
                _currentStatus = nextState;
                _isAdvancing = false;
                if (nextState == 'En viaje') {
                    _startTripTimer();
                    _lastPosition = null; // Reset for calculation
                    _loadCurrentRoute();
                }
            });
        }
    } else {
        setState(() => _isAdvancing = false);
        if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error actualizando estado')),
            );
        }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.conductorLocation.latitude, widget.conductorLocation.longitude),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                 userAgentPackageName: 'com.ping_go.app',
              ),
              if (_route != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route!.geometry,
                      strokeWidth: 5,
                      color: const Color(0xFFFFD700),
                    ),
                  ],
                ),
               MarkerLayer(
                markers: [
                  // Driver Marker (Real-time) - Car Icon
                  Marker(
                    point: _lastPosition != null 
                        ? LatLng(_lastPosition!.latitude, _lastPosition!.longitude)
                        : LatLng(widget.conductorLocation.latitude, widget.conductorLocation.longitude),
                    width: 50,
                    height: 50,
                    child: Transform.rotate(
                      angle: (_currentHeading * 3.14159 / 180), // Degrees to radians
                      child: Image.asset(
                        _getVehicleAsset(),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if car asset not found
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.local_taxi, color: Colors.black, size: 30),
                          );
                        },
                      ),
                    ),
                  ),
                  // Target Marker (Pickup or Destination)
                  Marker(
                    point: (_currentStatus == 'En viaje')
                        ? LatLng(
                            double.tryParse(widget.tripData['latitud_destino']?.toString() ?? '') ?? 0.0, 
                            double.tryParse(widget.tripData['longitud_destino']?.toString() ?? '') ?? 0.0
                          )
                        : LatLng(
                            double.tryParse(widget.tripData['latitud_recogida']?.toString() ?? '') ?? 0.0, 
                            double.tryParse(widget.tripData['longitud_recogida']?.toString() ?? '') ?? 0.0
                          ),
                    child: Icon(
                      (_currentStatus == 'En viaje') ? Icons.flag : Icons.location_on, 
                      color: (_currentStatus == 'En viaje') ? Colors.red : Colors.white, 
                      size: 30
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Header
           SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _showCancelDialog,
                ),
              ),
            ),
          ),

          // Bottom Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                       CircleAvatar(
                        radius: 25,
                        backgroundImage: (widget.tripData['cliente_foto'] != null)
                            ? NetworkImage(AppConfig.resolveImageUrl(widget.tripData['cliente_foto']))
                            : null,
                        child: (widget.tripData['cliente_foto'] == null) 
                          ? const Icon(Icons.person) : null,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${widget.tripData['cliente_nombre']}',
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  (double.tryParse(widget.tripData['cliente_calificacion']?.toString() ?? '5.0') ?? 5.0).toStringAsFixed(1),
                                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                               _currentStatus == 'En camino' ? 'Recogiendo cliente' : 'Llevando a destino',
                              style: TextStyle(color: Colors.grey[400], fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Metrics (Dynamic based on status)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_currentStatus == 'En camino' && _route != null) ...[
                            Text(
                              '${_route!.distanceKm.toStringAsFixed(1)} km',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${(_route!.durationMinutes * 1.2).ceil()} min', // Simple traffic factor
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ] else if (_currentStatus == 'En viaje') ...[
                             Text(
                              '${_accumulatedDistanceKm.toStringAsFixed(1)} km',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _formatDuration(_tripDuration),
                               style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ]
                        ],
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Navigation Button (Always Visible)
                      IconButton(
                        onPressed: _openExternalNavigation,
                        icon: const Icon(Icons.navigation, color: Color(0xFFFFD700), size: 32),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navigation Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openNavigation('google'),
                          icon: const Icon(Icons.navigation, size: 20),
                          label: const Text('Google Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFFFD700)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openNavigation('waze'),
                          icon: const Icon(Icons.explore, size: 20),
                          label: const Text('Waze'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFFFD700)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isAdvancing ? null : _advanceState,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isAdvancing
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : Text(
                            _getButtonText(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStatus) {
      case 'En camino': return 'Llegué al punto';
      case 'Llegué': return 'Iniciar Viaje';
      case 'En viaje': return 'Finalizar Viaje';
      default: return 'Cerrar';
    }
  }
  
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
    } else {
      return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}';
    }
  }
  String _getVehicleAsset() {
    final type = widget.vehicleType?.toLowerCase() ?? '';
    // Check for motorcycle keywords
    if (type.contains('moto') || type.contains('motor')) {
      return 'assets/images/moto_top_view.png';
    }
    // Default to car
    return 'assets/images/car_top_view.png';
  }
}
