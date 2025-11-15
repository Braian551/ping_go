// lib/src/features/auth/presentation/screens/email_auth_screen.dart
import 'package:flutter/material.dart';
import 'package:ping_go/src/routes/route_names.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Título
            const Text(
              'Ingresa tu correo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Subtítulo
            const Text(
              'Te enviaremos un enlace de verificación',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 40),

            // Formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo de email simplificado
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.email_rounded,
                        color: const Color(0xFFFFFF00),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFFFF00), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Por favor ingresa tu correo electrónico';

                      // Una expresión regular tolerante pero segura para direcciones de correo comunes
                      final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}");
                      if (!emailRegex.hasMatch(email)) return 'Por favor ingresa un correo válido';

                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // Botón de continuar simplificado
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Ocultar teclado y usar email recortado para evitar espacios accidentales
                        FocusScope.of(context).unfocus();
                        final email = _emailController.text.trim();

                        // Log de depuración para confirmar toque del botón y valor recortado
                        // (Aparecerá en consola al ejecutar flutter run)
                        try {
                          // ignore: avoid_print
                          print('EmailAuth: Continue tapped with email="$email"');
                        } catch (_) {}

                        if (!_formKey.currentState!.validate()) {
                          // Si la validación falla, mostrar un mensaje en línea
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Revisa tu correo e intenta de nuevo'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          return;
                        }

                        // Proporcionar retroalimentación rápida y navegar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Redirigiendo...'),
                            duration: Duration(milliseconds: 350),
                          ),
                        );

                        Navigator.pushNamed(
                          context,
                          RouteNames.emailVerification,
                          arguments: {
                            'email': email,
                            'userName': email.split('@')[0],
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFF00),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
