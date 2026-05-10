import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../global/services/auth/user_service.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/admin/presentation/screens/admin_home_screen.dart';
import '../features/conductor/presentation/screens/conductor_home_screen.dart';
import '../features/user/presentation/screens/home_user.dart';
import '../routes/route_names.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/user/services/trip_request_service.dart';
import '../features/conductor/services/conductor_service.dart';
import '../features/user/presentation/screens/trip_status_screen.dart';
import '../features/conductor/presentation/screens/driver_trip_screen.dart';
import '../features/user/presentation/screens/select_destination_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Iniciar animación
    _controller.repeat(reverse: true);

    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      // Pequeño delay para asegurar que las animaciones se vean un poco
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Primero verificar si es la primera vez que abre la app
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (!mounted) return;

      // Si no ha completado el onboarding, mostrar pantalla introductoria
      if (!onboardingCompleted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
        return;
      }

      // Verificar si hay una sesión guardada localmente
      final session = await UserService.getSavedSession();

      if (!mounted) return;

      if (session != null && session['email'] != null && session['id'] != null) {
        // --- VERIFICACIÓN ADICIONAL CON BACKEND ---
        // Intentar obtener el perfil actual para asegurar que la sesión es válida en el servidor
        final profile = await UserService.getProfile(userId: session['id']);
        
        if (!mounted) return;
        
        if (profile == null || profile['success'] == false) {
          print('AuthWrapper: Sesión local no válida en servidor. Cerrando sesión.');
          await UserService.clearSession();
          Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
          return;
        }
        
        // Actualizar sesión local con datos frescos del perfil si es necesario
        final userData = profile['user'] ?? session;
        final String tipoUsuario = userData['tipo_usuario'] ?? 'cliente';
        final int userId = int.tryParse(userData['id']?.toString() ?? '0') ?? 0;

        // --- RECUPERACIÓN DE SESIÓN (VIAJES ACTIVOS) ---
        if (tipoUsuario == 'conductor') {
          final activeTrip = await ConductorService.getActiveTrip(userId);
          if (activeTrip != null && mounted) {
            Position? position;
            try {
              position = await Geolocator.getCurrentPosition();
            } catch (e) {
              print('AuthWrapper: Error recuperando ubicación: $e');
            }

            if (position != null && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DriverTripScreen(
                    tripData: activeTrip,
                    conductorLocation: position!,
                    conductorId: userId,
                    vehicleType: activeTrip['vehiculo_tipo'],
                  ),
                ),
              );
              return;
            }
          }
        } else if (tipoUsuario == 'cliente') {
          final activeTrip = await TripRequestService.getActiveTrip(userId);
          if (activeTrip != null && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TripStatusScreen(
                  solicitudId: int.tryParse(activeTrip['id']?.toString() ?? '') ?? 0,
                  origin: SimpleLocation(
                    latitude: double.tryParse(activeTrip['latitud_recogida']?.toString() ?? '') ?? 0.0,
                    longitude: double.tryParse(activeTrip['longitud_recogida']?.toString() ?? '') ?? 0.0,
                    address: activeTrip['direccion_recogida'] ?? '',
                  ),
                  destination: SimpleLocation(
                    latitude: double.tryParse(activeTrip['latitud_destino']?.toString() ?? '') ?? 0.0,
                    longitude: double.tryParse(activeTrip['longitud_destino']?.toString() ?? '') ?? 0.0,
                    address: activeTrip['direccion_destino'] ?? '',
                  ),
                ),
              ),
            );
            return;
          }
        }
        // --- FIN RECUPERACIÓN DE SESIÓN ---

        // Redirección normal si no hay viaje activo
        if (tipoUsuario == 'administrador') {
          Navigator.of(context).pushReplacementNamed(
            RouteNames.adminHome,
            arguments: {'admin_user': session},
          );
        } else if (tipoUsuario == 'conductor') {
          Navigator.of(context).pushReplacementNamed(
            RouteNames.conductorHome,
            arguments: {'conductor_user': session},
          );
        } else {
          // Cliente
          Navigator.of(context).pushReplacementNamed(
            RouteNames.home,
            arguments: {'email': session['email'], 'user': session},
          );
        }
      } else {
        // No hay sesión, mostrar welcome
        Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
      }
    } catch (e) {
      // En caso de error, mostrar welcome por defecto
      print('Error en _checkSession: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.welcome);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo con efecto de pulso y glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow exterior pulsante
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: size.width * 0.32,
                            height: size.width * 0.32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFFF00).withOpacity(0.3),
                                  const Color(0xFFFFFF00).withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Círculo de fondo con sombra
                        Container(
                          width: size.width * 0.28,
                          height: size.width * 0.28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFFF00).withOpacity(0.15),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.85],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFFF00).withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFFF00),
                                    Color(0xFFFFDD00),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Indicador de carga
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFFF00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
