// lib/src/features/auth/presentation/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:ping_go/src/routes/route_names.dart';
import 'package:ping_go/src/widgets/entrance_fader.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // La sesión ahora es manejada exclusivamente por AuthWrapper
    // para evitar redirecciones inconsistentes.
  }

  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black, // Fallback
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2), // Slightly above center
                  radius: 1.2,
                  colors: [
                    const Color(0xFF1A1A1A), // Dark Grey center
                    Colors.black,            // Pure black edges
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          // 2. Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: size.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2), // Top spacing
                    
                    // Logo with Glow
                    EntranceFader(
                      delay: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFF00).withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFFFFF00).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                         child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFFFF00),
                                  Color(0xFFFFD700), // Gold/Yellow variation
                                ],
                              ).createShader(bounds);
                            },
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 100,
                              height: 100,
                            ),
                          ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // Title
                    EntranceFader(
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        'Bienvenido a Ping-Go',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    EntranceFader(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Movilidad y entregas rápidas a tu alcance.\nViaja seguro, llega tiempo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 3), // Middle spacing
                    
                    // Buttons Column
                    EntranceFader(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          // Google Button (Primary/White)
                          _buildModernButton(
                            icon: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                              height: 24,
                              width: 24,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.g_mobiledata, size: 28, color: Colors.black),
                            ),
                            text: 'Continuar con Google',
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            onPressed: () async {
                              // Integración de Google Sign-In
                              try {
                                // Mostrar indicador de carga si se desea (aquí bloqueamos UI con modal o similar)
                                // Por simplicidad, usaremos el mismo botón
                                
                                final result = await UserService.loginWithGoogle();
                                
                                if (!mounted) return;

                                if (result['success'] == true && result['user'] != null) {
                                  // Login exitoso
                                  final user = result['user'];
                                  final tipoUsuario = user['tipo_usuario'] ?? 'cliente';
                                  
                                  print('WelcomeScreen: Redirigiendo usuario tipo: $tipoUsuario');
                                  
                                  // Redirigir según el tipo de usuario
                                  if (tipoUsuario == 'administrador') {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      RouteNames.adminHome,
                                      (route) => false,
                                      arguments: {'admin_user': user},
                                    );
                                  } else if (tipoUsuario == 'conductor') {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      RouteNames.conductorHome,
                                      (route) => false,
                                      arguments: {'conductor_user': user},
                                    );
                                  } else {
                                    // Cliente
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      RouteNames.home,
                                      (route) => false,
                                      arguments: {'email': user['email'], 'user': user},
                                    );
                                  }
                                } else if (result['success'] == true) {
                                  // Caso extraño: éxito sin datos
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Error: No se recibieron datos de usuario')),
                                  );
                                } else {
                                  // Error
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Error al iniciar sesión con Google'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error inesperado: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Placeholder for other buttons (commented as per user preference)
                          /*
                          _buildModernButton(
                            icon: Icon(Icons.apple, color: Colors.white, size: 28),
                            text: 'Continuar con Apple',
                            backgroundColor: Color(0xFF1F1F1F),
                            textColor: Colors.white,
                            onPressed: () {},
                          ),
                           const SizedBox(height: 16),
                          */

                          // Email Button (Secondary/Outline)
                          _buildModernButton(
                            icon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFFFFFF00),
                              size: 24,
                            ),
                            text: 'Continuar con correo',
                            backgroundColor: Colors.transparent,
                            textColor: const Color(0xFFFFFF00),
                            borderColor: const Color(0xFFFFFF00),
                            onPressed: () {
                              Navigator.pushNamed(context, RouteNames.emailAuth);
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(flex: 1), // Bottom spacing
                    
                    // Terms
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Al continuar, aceptas nuestros ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: 'Términos de Servicio',
                              style: const TextStyle(
                                color: Color(0xFFFFFF00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' y '),
                            TextSpan(
                              text: 'Política de Privacidad',
                              style: const TextStyle(
                                color: Color(0xFFFFFF00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernButton({
    required Widget icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Taller, more clickable area
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Softer corners
            side: borderColor != null 
                ? BorderSide(color: borderColor, width: 1.5) 
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
