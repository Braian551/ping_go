import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../../global/services/auth/user_service.dart';
import '../../services/conductor_profile_service.dart';
import '../../models/conductor_profile_model.dart';
import '../../models/vehicle_model.dart';

class ConductorMapView extends StatefulWidget {
  const ConductorMapView({super.key});

  @override
  State<ConductorMapView> createState() => _ConductorMapViewState();
}

class _ConductorMapViewState extends State<ConductorMapView> {
  final MapController _mapController = MapController();
  
  // Estados para datos y UI
  LatLng? _currentPosition;
  double? _heading;
  VehicleType _vehicleType = VehicleType.carro; // Por defecto
  bool _isLoading = true;
  bool _isMapReady = false;

  // Streams
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // 1. Cargar tipo de vehículo del conductor
      await _loadVehicleInfo();

      // 2. Iniciar listeners de ubicación y brújula
      _startLocationStream();
      _startCompassStream();

      // 3. Obtener ubicación inicial para centrar el mapa
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        
        // Esperar a que el mapa se renderice para moverlo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(_currentPosition!, 15);
            _isMapReady = true;
          }
        });
      }
    } catch (e) {
      print('Error inicializando mapa: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback: intentar geolocator simple si falla algo
        _getCurrentLocation(); 
      }
    }
  }

  Future<void> _loadVehicleInfo() async {
    try {
      final session = await UserService.getSavedSession();
      if (session != null && session['id'] != null) {
        final conductorId = int.tryParse(session['id'].toString());
        if (conductorId != null) {
          final profile = await ConductorProfileService.getProfile(conductorId);
          if (profile?.vehiculo?.tipo != null) {
            if (mounted) {
              setState(() {
                _vehicleType = profile!.vehiculo!.tipo;
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error cargando información del vehículo: $e');
      // Mantener valor por defecto (carro)
    }
  }

  void _startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // Actualizar cada 5 metros
    );
    
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        // Opcional: Centrar mapa si el usuario quiere seguimiento automático (podría agregarse un botón de toggle)
      }
    });
  }

  void _startCompassStream() {
    _compassStream = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error obteniendo ubicación: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }

    if (_currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_disabled, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Esperando ubicación...',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
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
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition!,
            initialZoom: 16.0, // Zoom un poco más cercano para ver detalles
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.ping_go',
              // Filtro modo oscuro
              tileBuilder: (context, widget, tile) {
                return ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.grey, 
                    BlendMode.saturation,
                  ), 
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(
                      [
                        -1,  0,  0, 0, 255,
                         0, -1,  0, 0, 255,
                         0,  0, -1, 0, 255,
                         0,  0,  0, 1,   0,
                      ], 
                    ),
                    child: widget,
                  ),
                );
              },
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentPosition!,
                  width: 60,
                  height: 60,
                  child: Transform.rotate(
                    // Rotar según la brújula
                    // FontAwesome carSide/motorcycle apuntan a la derecha. 
                    // Restamos 90 grados (pi/2) para que apunten hacia arriba (Norte) cuando el heading es 0.
                    angle: ((_heading ?? 0) * (math.pi / 180)) - (math.pi / 2), 
                    child: Icon(
                      _vehicleType == VehicleType.carro 
                          ? FontAwesomeIcons.carSide 
                          : FontAwesomeIcons.motorcycle, 
                      color: const Color(0xFFFFD700),
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // Botón de recentrar
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            heroTag: 'recenter_map_btn',
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(_currentPosition!, 16);
              } else {
                _initializeData();
              }
            },
            backgroundColor: const Color(0xFF1E1E1E),
            child: const Icon(Icons.my_location, color: Color(0xFFFFD700)),
          ),
        ),
      ],
    );
  }
}
