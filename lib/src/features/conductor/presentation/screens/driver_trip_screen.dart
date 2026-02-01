import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../global/services/osm_service.dart';
import '../../services/conductor_service.dart';
import 'trip_summary_screen.dart';

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
  final MapController _mapController = MapController();
  
  // State
  OsmRoute? _route;
  bool _isLoadingRoute = true;
  String _currentStatus = 'En camino'; // 'En camino', 'Llegué', 'En viaje', 'Finalizado'
  
  // Tracking
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  double _accumulatedDistanceKm = 0.0;
  double _currentHeading = 0.0;
  DateTime? _tripStartTime;
  Timer? _durationTimer;
  Duration _tripDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadRouteToClient();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _durationTimer?.cancel();
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
      _accumulatedDistanceKm += (dist / 1000); // Convert to km
    }
    _lastPosition = newPos;
  }

  void _updateMapPosition(Position pos) {
     // Optional: Keep camera centered or just update driver marker
     // We will update the marker via setState or ValueNotifier if we want smooth animation
     // For now, simple setState to refresh UI
     if (mounted) setState(() {});
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

  Future<void> _loadRouteToClient() async {
    // Route from Driver -> Client (Pickup)
    final driverPos = LatLng(widget.conductorLocation.latitude, widget.conductorLocation.longitude);
    final clientPos = LatLng(
      double.parse(widget.tripData['latitud_recogida'].toString()), 
      double.parse(widget.tripData['longitud_recogida'].toString())
    );

    try {
      final route = await OsmService.getRoute([driverPos, clientPos]);
      setState(() {
        _route = route;
        _isLoadingRoute = false;
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _fitMapBounds(driverPos, clientPos);
      });
    } catch (e) {
      print('Error loading route: $e');
      setState(() => _isLoadingRoute = false);
    }
  }

  void _fitMapBounds(LatLng p1, LatLng p2) {
    if (!_mapController.mapEventStream.isBroadcast) return; // Simple check
    
    final bounds = LatLngBounds.fromPoints([p1, p2]);
    _mapController.fitCamera(CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    ));
  }
  
  void _openExternalNavigation() async {
    _openNavigation('google'); // Default to Google
  }
  
  void _openNavigation(String app) async {
    double lat, lng;
    // Determine destination based on trip status
    if (_currentStatus == 'En camino' || _currentStatus == 'Llegué') {
       // Phase 1: Going to Pickup (Client)
       lat = double.parse(widget.tripData['latitud_recogida'].toString());
       lng = double.parse(widget.tripData['longitud_recogida'].toString());
    } else {
       // Phase 2: Going to Destination (Dropoff)
       lat = double.parse(widget.tripData['latitud_destino'].toString());
       lng = double.parse(widget.tripData['longitud_destino'].toString());
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

  Future<void> _advanceState() async {
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
        if (_currentStatus == 'Finalizado') Navigator.pop(context);
        return;
    }

    // Attempt update
    final solicitudId = int.parse(widget.tripData['solicitud_id'].toString());
    final success = await ConductorService.updateTripStatus(
      solicitudId: solicitudId, 
      estado: backendState,
      conductorId: widget.conductorId,
    );
    
    if (success) {
        if (backendState == 'completada') {
            _durationTimer?.cancel();
            _positionStream?.cancel();
            
            // Capture final metrics before navigation
            final finalDist = _accumulatedDistanceKm;
            final finalDurSeconds = _tripDuration.inSeconds;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TripSummaryScreen(
                  tripData: widget.tripData, 
                  realDistanceKm: finalDist, 
                  realDurationSeconds: finalDurSeconds,
                  conductorId: widget.conductorId,
                ),
              ),
            );
        } else {
            setState(() {
                _currentStatus = nextState;
                if (nextState == 'En viaje') {
                    _startTripTimer();
                    _lastPosition = null; // Reset for calculation
                    _loadRouteToDestination();
                }
            });
        }
    } else {
        if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error actualizando estado')),
            );
        }
    }
  }

  Future<void> _loadRouteToDestination() async {
     setState(() => _isLoadingRoute = true);
     
     // Use current driver position (GPS) instead of pickup point
     LatLng startPos;
     if (_lastPosition != null) {
       startPos = LatLng(_lastPosition!.latitude, _lastPosition!.longitude);
     } else {
       startPos = LatLng(widget.conductorLocation.latitude, widget.conductorLocation.longitude);
     }
     
     final endPos = LatLng(
      double.parse(widget.tripData['latitud_destino'].toString()), 
      double.parse(widget.tripData['longitud_destino'].toString())
    );

     try {
      final route = await OsmService.getRoute([startPos, endPos]);
      setState(() {
        _route = route;
        _isLoadingRoute = false;
      });
       WidgetsBinding.instance.addPostFrameCallback((_) {
         _fitMapBounds(startPos, endPos);
      });
    } catch (e) {
      print('Error loading route to destination: $e');
      setState(() => _isLoadingRoute = false);
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
                            double.parse(widget.tripData['latitud_destino'].toString()), 
                            double.parse(widget.tripData['longitud_destino'].toString())
                          )
                        : LatLng(
                            double.parse(widget.tripData['latitud_recogida'].toString()), 
                            double.parse(widget.tripData['longitud_recogida'].toString())
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
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
                            ? NetworkImage(widget.tripData['cliente_foto'])
                            : null,
                        child: (widget.tripData['cliente_foto'] == null) 
                          ? const Icon(Icons.person) : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.tripData['cliente_nombre']}',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                             _currentStatus == 'En camino' ? 'Recogiendo cliente' : 'Llevando a destino',
                            style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(),
                      
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
                      onPressed: _advanceState,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
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
