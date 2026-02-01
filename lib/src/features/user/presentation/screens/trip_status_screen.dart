import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/trip_request_service.dart';
import '../../../../global/services/osm_service.dart';
import 'select_destination_screen.dart';

class TripStatusScreen extends StatefulWidget {
  final int solicitudId;
  final SimpleLocation origin;
  final SimpleLocation destination;
  final List<LatLng>? routePoints;

  const TripStatusScreen({super.key, required this.solicitudId, required this.origin, required this.destination, this.routePoints});

  @override
  State<TripStatusScreen> createState() => _TripStatusScreenState();
}

class _TripStatusScreenState extends State<TripStatusScreen> {
  MapController _mapController = MapController();
  Timer? _pollTimer;
  Map<String, dynamic>? _trip;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final response = await TripRequestService.getTripStatus(solicitudId: widget.solicitudId);
      if (response['success'] == true) {
        setState(() {
          _trip = response['trip'];
          _isLoading = false;
        });
        // Fit bounds to show driver and origin/destination
        if (_trip != null && _trip!['conductor'] != null) {
          final driverLat = _trip!['conductor']['ubicacion']['latitud'];
          final driverLng = _trip!['conductor']['ubicacion']['longitud'];
          final bounds = LatLngBounds(
            LatLng(widget.origin.latitude, widget.origin.longitude),
            LatLng(driverLat, driverLng),
          );
          final camera = CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(40),
          );
          _mapController.fitCamera(camera);
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Error desconocido';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del viaje'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.origin.toLatLng(),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: OsmService.getTileUrl(),
                userAgentPackageName: 'com.example.ping_go',
              ),
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
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.origin.toLatLng(),
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.circle, color: Colors.green),
                  ),
                  Marker(
                    point: widget.destination.toLatLng(),
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.location_on, color: Colors.red),
                  ),
                  if (_trip != null && _trip!['conductor'] != null)
                    Marker(
                      point: LatLng(_trip!['conductor']['ubicacion']['latitud'], _trip!['conductor']['ubicacion']['longitud']),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.directions_car, color: Colors.blue),
                    ),
                ],
              )
            ],
          ),

          if (_isLoading) Center(child: CircularProgressIndicator(color: Colors.black)),

          if (_trip != null)
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_trip != null && _trip!['conductor'] != null) ...[
                      // Status Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _getStatusColor(_trip!['estado']),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(_trip!['estado']),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Driver Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: _trip!['conductor']['foto'] != null 
                              ? NetworkImage(_trip!['conductor']['foto']) 
                              : null,
                            child: _trip!['conductor']['foto'] == null ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_trip!['conductor']['nombre'] ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    Text(' ${_trip!['conductor']['calificacion'] ?? '5.0'}'),
                                    const SizedBox(width: 10),
                                    Text('• ${_trip!['conductor']['placa'] ?? ''}', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${_trip!['conductor']['eta_minutos'] ?? '-'} min',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const Text('ETA', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Cancel Button (Only if not already in trip)
                      if (_canCancel(_trip!['estado']))
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            final should = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cancelar viaje'),
                                content: const Text('¿Deseas cancelar la solicitud?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Si')),
                                ],
                              ),
                            );
                            if (should == true) {
                               _cancelTrip();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Cancelar viaje'),
                        ),
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(strokeWidth: 2),
                            SizedBox(width: 16),
                            Text('Buscando conductor cercano...'),
                          ],
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),

          if (_errorMessage != null)
            Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'conductor_asignado': return Colors.blue.shade100;
      case 'en_sitio': return const Color(0xFFFFD700); // Yellow
      case 'en_transito':
      case 'recogido': return Colors.green.shade100;
      default: return Colors.grey.shade200;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'conductor_asignado': return 'Conductor en camino';
      case 'en_sitio': return '¡Tu conductor ha llegado!';
      case 'en_transito':
      case 'recogido': return 'En viaje hacia tu destino';
      default: return 'Estado: $status';
    }
  }
  
  bool _canCancel(String? status) {
    // Can cancel if driver hasn't picked up yet
    return status == 'conductor_asignado' || status == 'en_sitio' || status == 'pendiente';
  }
  
  Future<void> _cancelTrip() async {
    try {
        final canceled = await TripRequestService.cancelTripRequest(_trip!['id']);
        if (canceled) {
            if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud cancelada')));
            Navigator.pop(context);
            }
        }
    } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cancelando: $e')));
    }
  }
}
