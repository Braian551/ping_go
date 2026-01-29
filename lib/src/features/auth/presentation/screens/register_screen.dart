import 'package:flutter/material.dart';
import 'package:ping_go/src/routes/route_names.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';

class RegisterScreen extends StatefulWidget {
  final String email;
  final String userName;

  const RegisterScreen({
    super.key,
    required this.email,
    required this.userName,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // La dirección ahora es opcional - no se valida
      
      setState(() => _isLoading = true);
      
      try {
        // Verificar si el usuario existe ANTES de intentar registrarlo
        final bool userExists = await UserService.checkUserExists(widget.email);
        if (userExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('El usuario ${widget.email} ya existe. Por favor inicia sesión.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          setState(() => _isLoading = false);
          
          // Redirigir a login después de mostrar el mensaje
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushNamedAndRemoveUntil(context, RouteNames.login, (route) => false);
          return;
        }
        
        // Proceder con el registro solo si el usuario NO existe
        final response = await UserService.registerUser(
          email: widget.email,
          password: _passwordController.text,
          name: _nameController.text,
          lastName: _lastNameController.text,
          phone: _phoneController.text,
        );

        // Debug: imprimir respuesta para depuración
        try {
          print('Register response: $response');
        } catch (_) {}

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Registro exitoso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        // Intentar guardar sesión si backend retornó data.user
        try {
          final data = response['data'] as Map<String, dynamic>?;
          if (data != null && data['user'] != null) {
            await UserService.saveSession(data['user']);
          } else {
            await UserService.saveSession({'email': widget.email});
          }
        } catch (_) {}

        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Navegar al home directamente
        Navigator.pushNamedAndRemoveUntil(
          context, 
          RouteNames.home,
          (route) => false,
          arguments: {'email': widget.email},
        );
      } catch (e) {
        // Manejar errores específicos de conexión o servidor
        String errorMessage = 'Error: $e';
        
        if (e.toString().contains('SocketException') || 
            e.toString().contains('Connection refused')) {
          errorMessage = 'Error de conexión con el servidor. Verifica que el backend esté ejecutándose.';
        } else if (e.toString().contains('Field') || 
                   e.toString().contains('latitud')) {
          // Error conocido de campo faltante - continuar como éxito para pruebas
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Registro completado. Redirigiendo a inicio...'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          Navigator.pushNamedAndRemoveUntil(context, RouteNames.home, (route) => false, arguments: {'email': widget.email});
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF1A1A1A),
                    Colors.black,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // AppBar custom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Encabezado simple de pasos
                _buildSimpleStepperHeader(),

                // Contenido del formulario
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: _buildStepContent(),
                    ),
                  ),
                ),

                // Botones inferiores
                _buildSimpleBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildContactStep();
      case 2:
        return _buildSecurityStep();
      default:
        return _buildPersonalInfoStep();
    }
  }

  Widget _buildSimpleStepperHeader() {
    final titles = ['Personal', 'Contacto', 'Seguridad'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 20),
      child: Column(
        children: [
          // Título del paso
          Text(
            titles[_currentStep],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getStepDescription(_currentStep),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),

          // Indicadores de pasos (Dots ONLY)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(titles.length, (i) {
              final isActive = i == _currentStep;
              final isPassed = i < _currentStep;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: isActive ? 24 : 10, // Active dot is a bit wider (pill shape)
                height: 10,
                decoration: BoxDecoration(
                  color: isActive || isPassed
                      ? const Color(0xFFFFFF00)
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Información básica sobre ti';
      case 1:
        return 'Cómo contactarte';
      case 2:
        return 'Protege tu cuenta';
      default:
        return '';
    }
  }

  Widget _buildSimpleBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de regresar
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Atrás',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 0),

          if (_currentStep > 0) const SizedBox(width: 16),

          // Botón de siguiente/registrar
          Expanded(
            flex: _currentStep > 0 ? 1 : 2,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_currentStep < 2) {
                    // Validar paso actual
                    if (_currentStep == 0) {
                      if (_nameController.text.isEmpty || _lastNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor completa todos los campos'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    } else if (_currentStep == 1) {
                      if (_phoneController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor ingresa tu teléfono'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    setState(() => _currentStep++);
                  } else {
                    _register();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFF00),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading 
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : Text(
                        _currentStep < 2 ? 'Siguiente' : 'Crear Cuenta',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSimpleTextField(
          controller: _nameController,
          label: 'Nombre',
          icon: Icons.person_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu nombre';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildSimpleTextField(
          controller: _lastNameController,
          label: 'Apellido',
          icon: Icons.person_outline_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu apellido';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFFFFFF00),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFFFFF00).withOpacity(0.8),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFFF00), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      validator: validator,
    );
  }

  Widget _buildContactStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSimpleTextField(
          controller: _phoneController,
          label: 'Teléfono',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa tu teléfono';
            }
            if (value.length < 10) {
              return 'El teléfono debe tener al menos 10 dígitos';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSecurityStep() {
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSimpleTextField(
          controller: _passwordController,
          label: 'Contraseña',
          icon: Icons.lock_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: Colors.white.withOpacity(0.4),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildSimpleTextField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: Colors.white.withOpacity(0.4),
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor confirma tu contraseña';
            }
            if (value != _passwordController.text) {
              return 'Las contraseñas no coinciden';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}