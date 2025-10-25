// lib/src/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:ping_go/src/routes/route_names.dart';
import 'package:ping_go/src/widgets/entrance_fader.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  final String? email;
  final bool? prefilled;

  const LoginScreen({
    super.key,
    this.email,
    this.prefilled = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String emailToUse = _emailController.text.trim();

        if (emailToUse.isEmpty) {
          final sess = await UserService.getSavedSession();
          if (sess != null && sess['email'] != null) {
            emailToUse = sess['email'] as String;
          } else {
            _showError('No se pudo determinar el email. Por favor, intenta iniciar sesión nuevamente.');
            return;
          }
        }

        if (emailToUse.isEmpty) {
          _showError('El email es requerido para iniciar sesión.');
          return;
        }

        final resp = await UserService.login(email: emailToUse, password: _passwordController.text);

        if (resp['success'] == true) {
          _showSuccess('¡Bienvenido de nuevo!');
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            // Determinar qué datos guardar en la sesión según el tipo de usuario
            final user = resp['data']?['user'];
            final admin = resp['data']?['admin'];
            final tipoUsuario = user?['tipo_usuario'] ?? admin?['tipo_usuario'] ?? 'cliente';
            
            if (tipoUsuario == 'administrador') {
              await UserService.saveSession(admin ?? {'email': emailToUse});
            } else {
              await UserService.saveSession(user ?? {'email': emailToUse});
            }
          } catch (_) {}

          if (mounted) {
            final user = resp['data']?['user'];
            final admin = resp['data']?['admin'];
            final tipoUsuario = user?['tipo_usuario'] ?? admin?['tipo_usuario'] ?? 'cliente';
            
            // Redirigir según el tipo de usuario
            if (tipoUsuario == 'administrador') {
              Navigator.pushReplacementNamed(
                context,
                RouteNames.adminHome,
                arguments: {'admin_user': admin},
              );
            } else if (tipoUsuario == 'conductor') {
              Navigator.pushReplacementNamed(
                context,
                RouteNames.conductorHome,
                arguments: {'conductor_user': user},
              );
            } else {
              // Cliente
              Navigator.pushReplacementNamed(
                context,
                RouteNames.home,
                arguments: {'email': emailToUse, 'user': user},
              );
            }
          }
        } else {
          final message = resp['message'] ?? 'Credenciales inválidas';

          // Mostrar mensaje específico según el error del backend
          if (message.contains('Email y password son requeridos')) {
            _showError('Por favor, completa todos los campos.');
          } else if (message.contains('Usuario no encontrado')) {
            _showError('No se encontró una cuenta con este email. Verifica que el email sea correcto.');
          } else if (message.contains('Contraseña incorrecta')) {
            _showError('La contraseña es incorrecta. Inténtalo de nuevo.');
          } else {
            _showError(message);
          }
        }
      } catch (e) {
        print('Error en login: $e');
        _showError('Error al iniciar sesión. Verifica tu conexión a internet.');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    CustomSnackbar.showError(
      context,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    CustomSnackbar.showSuccess(
      context,
      message: message,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EntranceFader(
          delay: const Duration(milliseconds: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              const Text(
                'Ingresa tu contraseña',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Confirma tu identidad para continuar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock, color: Color(0xFFFFFF00)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFFFF00)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _showError('Función en desarrollo');
                        },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Color(0xFFFFFF00),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFF00),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Continuar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}