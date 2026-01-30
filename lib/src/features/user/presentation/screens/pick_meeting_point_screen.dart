import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../global/services/osm_service.dart';

class PickMeetingPointScreen extends StatefulWidget {
  final LatLng initialLocation;
  
  const PickMeetingPointScreen({
    super.key,
    required this.initialLocation,
  });

  @override
  State<PickMeetingPointScreen> createState() => _PickMeetingPointScreenState();
}

class _PickMeetingPointScreenState extends State<PickMeetingPointScreen> {
  late MapController _mapController;
  late LatLng _currentCenter;
  bool _isLoadingAddress = false;
  String _currentAddress = 'Cargando ubicación...';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentCenter = widget.initialLocation;
    _getAddress(_currentCenter);
  }

  Future<void> _getAddress(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      final place = await OsmService.reverseGeocode(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentAddress = place?.displayName ?? 'Ubicación seleccionada';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _currentAddress = 'Ubicación desconocida');
      }
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    // Solo actualizamos si el movimiento fue por gesto del usuario o animación final
    // Evitamos llamar a geocoding en cada frame, solo actualizamos coordenadas visuales si se mostraran
    _currentCenter = camera.center;
  }

  void _onMapMoveEnd(MapEvent event) {
    // Al terminar de mover el mapa, buscamos la dirección
    _getAddress(_mapController.camera.center);
    _currentCenter = _mapController.camera.center;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation,
              initialZoom: 17,
              onPositionChanged: _onMapPositionChanged,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
                   _onMapMoveEnd(event);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.ping_go.app',
              ),
            ],
          ),
          
          // Botón Atrás
          Positioned(
            top: 50,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),

          // Pin Central Fijo
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40), // Ajuste visual para que la punta del pin quede en el centro
              child: Icon(
                Icons.location_on,
                size: 50,
                color: const Color(0xFFFFD700),
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),
          
          // Etiqueta "Punto de encuentro"
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 85),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Punto de encuentro',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Panel Inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF161616),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Text(
                    'Confirma tu ubicación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location, color: Color(0xFFFFD700)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isLoadingAddress 
                            ? Row(
                                children: [
                                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2)),
                                  const SizedBox(width: 10),
                                  Text('Localizando...', style: TextStyle(color: Colors.grey[400])),
                                ],
                              ) 
                            : Text(
                                _currentAddress,
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                         // Retornamos la nueva ubicación y dirección
                         Navigator.pop(context, {
                           'latitude': _currentCenter.latitude,
                           'longitude': _currentCenter.longitude,
                           'address': _currentAddress,
                         });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Confirmar Punto de Encuentro',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
