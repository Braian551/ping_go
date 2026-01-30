import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/trip_request_service.dart';
import 'trip_status_screen.dart';
import 'select_destination_screen.dart';

class SearchingDriverScreen extends StatefulWidget {
  final int solicitudId;
  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final String pickupAddress;
  final String destinationAddress;

  const SearchingDriverScreen({
    Key? key,
    required this.solicitudId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupAddress,
    required this.destinationAddress,
  }) : super(key: key);

  @override
  State<SearchingDriverScreen> createState() => _SearchingDriverScreenState();
}

class _SearchingDriverScreenState extends State<SearchingDriverScreen> with TickerProviderStateMixin {
  late AnimationController _rippleController;
  Timer? _searchTimer;
  Timer? _pollingTimer;
  String _statusText = "Buscando conductor cercano...";
  double _radius = 100.0;
  int _secondsElapsed = 0;
  bool _driverFound = false;

  @override
  void initState() {
    super.initState();
    _startRippleAnimation();
    _startSearchTimer();
    _startPolling();
  }

  void _startRippleAnimation() {
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _startSearchTimer() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_driverFound) {
        setState(() {
          _secondsElapsed++;
          if (_secondsElapsed % 5 == 0) {
            _radius += 30;
            if (_secondsElapsed > 10 && _secondsElapsed <= 25) {
              _statusText = "Ampliando zona de búsqueda...";
            } else if (_secondsElapsed > 25) {
              _statusText = "Contactando más conductores...";
            }
          }
        });
      }
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await TripRequestService.getTripStatus(solicitudId: widget.solicitudId);
        if (status['success'] == true && status['trip'] != null) {
          final tripData = status['trip'];
          final conductor = tripData['conductor'];
          final estado = tripData['estado'];
          
          // Check if driver was assigned
          if (conductor != null && estado != 'pendiente') {
            _driverFound = true;
            _pollingTimer?.cancel();
            _searchTimer?.cancel();
            
            if (mounted) {
              // Navigate to trip status/tracking screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TripStatusScreen(
                    solicitudId: widget.solicitudId,
                    origin: SimpleLocation(
                      latitude: widget.pickupLocation.latitude,
                      longitude: widget.pickupLocation.longitude,
                      address: widget.pickupAddress,
                    ),
                    destination: SimpleLocation(
                      latitude: widget.destinationLocation.latitude,
                      longitude: widget.destinationLocation.longitude,
                      address: widget.destinationAddress,
                    ),
                  ),
                ),
              );
            }
          } else if (estado == 'cancelada') {
            _pollingTimer?.cancel();
            _searchTimer?.cancel();
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Solicitud cancelada'), backgroundColor: Colors.red),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Polling error: $e');
      }
    });
  }

  Future<void> _cancelRequest() async {
    try {
      final result = await TripRequestService.cancelTripRequest(widget.solicitudId);
      if (result && mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cancelar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _searchTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background (Dark Mode)
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.pickupLocation,
              initialZoom: 15.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.pickupLocation,
                    width: 200,
                    height: 200,
                    child: _buildRippleMarker(),
                  ),
                ],
              ),
            ],
          ),

          // 2. Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // 3. Status Info & Actions
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => _showCancelDialog(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Buscando...",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Bottom Content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161616),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, -5))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Pulse(
                        infinite: true,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD700).withOpacity(0.15),
                            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.local_taxi, color: Color(0xFFFFD700), size: 35),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tiempo: ${_formatTime(_secondsElapsed)}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRadiusIndicator(),
                      const SizedBox(height: 30),
                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _showCancelDialog,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.withOpacity(0.7)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "Cancelar Solicitud",
                            style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusIndicator() {
    final radiusKm = (_radius / 100).clamp(1, 10);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.radar, color: Colors.grey[500], size: 16),
        const SizedBox(width: 6),
        Text(
          'Radio: ~${radiusKm.toStringAsFixed(0)} km',
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar solicitud', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro que deseas cancelar esta solicitud?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelRequest();
            },
            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildRippleMarker() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Expanding Circles
            ...List.generate(3, (index) {
              final delay = index * 0.3;
              final value = (_rippleController.value + delay) % 1.0;
              final size = 40.0 + (value * (_radius * 0.8));
              final opacity = (1.0 - value).clamp(0.0, 1.0);
              
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withOpacity(opacity * 0.4),
                ),
              );
            }),
            // Center Pin
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_pin_circle, color: Colors.black, size: 24),
            ),
          ],
        );
      },
    );
  }
}
