import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import '../../services/conductor_service.dart';
import '../widgets/conductor_app_bar.dart';
import '../widgets/conductor_bottom_nav.dart';
import '../views/conductor_dashboard_view.dart';
import '../views/conductor_map_view.dart';
import '../views/conductor_history_view.dart';
import '../views/conductor_profile_view.dart';
import '../../models/vehicle_model.dart';

class ConductorHomeScreen extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorHomeScreen({
    super.key,
    required this.conductorUser,
  });

  @override
  State<ConductorHomeScreen> createState() => _ConductorHomeScreenState();
}

class _ConductorHomeScreenState extends State<ConductorHomeScreen> {
  int _currentIndex = 0;
  late Map<String, dynamic> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.conductorUser;
    // Force refresh to get latest data (including profile image if not in session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
      _checkLocationPermissions();
    });
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationDialog(
          'Servicios de ubicación desactivados',
          'Por favor, activa el GPS para poder trabajar como conductor.',
          onAction: () => Geolocator.openLocationSettings(),
        );
      }
      return;
    }

    // 2. Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Es obligatorio permitir la ubicación para usar el modo conductor.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationDialog(
          'Permisos de ubicación denegados',
          'Has denegado permanentemente los permisos. Debes activarlos desde la configuración para poder recibir viajes.',
          onAction: () => Geolocator.openAppSettings(),
        );
      }
      return;
    }
  }

  void _showLocationDialog(String title, String message, {required VoidCallback onAction}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAction();
            },
            child: const Text('CONFIGURAR', style: TextStyle(color: Color(0xFFFFFF00))),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshUserData() async {
    try {
      final sess = await UserService.getSavedSession();
      if (sess != null) {
        final userId = sess['id'] as int?;
        final email = sess['email'] as String?;
        if (userId != null) {
          final profile = await UserService.getProfile(userId: userId, email: email);
          if (profile != null && profile['success'] == true) {
            Map<String, dynamic> updatedUser = Map<String, dynamic>.from(profile['user']);
            
            // Si es conductor, obtener info adicional (como tipo_vehiculo)
            if (updatedUser['tipo_usuario'] == 'conductor') {
              final condInfo = await ConductorService.getConductorInfo(userId);
              if (condInfo != null) {
                updatedUser.addAll(condInfo);
              }
            }

            if (mounted) {
              setState(() {
                // Combinar con los datos actuales para no perder nada
                _currentUser = {..._currentUser, ...updatedUser};
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: ConductorAppBar(conductorUser: _currentUser),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: ConductorBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    // Unique keys ensure animation works correctly when switching
    switch (_currentIndex) {
      case 0:
        return ConductorDashboardView(key: const ValueKey(0), conductorUser: _currentUser);
      case 1:
        return ConductorMapView(
          key: const ValueKey(1),
          vehicleType: _currentUser['tipo_vehiculo'] != null 
              ? VehicleType.fromString(_currentUser['tipo_vehiculo'].toString())
              : null,
        );
      case 2:
        return ConductorHistoryView(key: const ValueKey(2), conductorUser: _currentUser);
      case 3:
        return ConductorProfileView(
          key: const ValueKey(3), 
          conductorUser: _currentUser,
          onProfileUpdate: _refreshUserData,
        );
      default:
        return ConductorDashboardView(key: const ValueKey(0), conductorUser: _currentUser);
    }
  }
}