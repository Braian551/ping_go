// lib/src/features/auth/presentation/screens/email_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ping_go/src/global/services/email_service.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart'; // Importar UserService
import 'package:ping_go/src/routes/route_names.dart';
import 'package:ping_go/src/widgets/dialogs/dialog_helper.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';
import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String userName;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.userName,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  TextEditingController? _codeController;
  String _verificationCode = '';
  bool _isLoading = false;
  bool _isResending = false;
  bool _isVerifying = false; // Nuevo estado para verificación de usuario
  int _resendCountdown = 60;
  Timer? _countdownTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _sendVerificationCode();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _countdownTimer?.cancel();
    _codeController = null;
    super.dispose();
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel();
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isDisposed) {
        timer.cancel();
        return;
      }
      
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendVerificationCode() async {
    if (!mounted || _isDisposed) return;
    
    setState(() => _isLoading = true);
    
    try {
      _verificationCode = EmailService.generateVerificationCode();
      
      bool success = await EmailService.sendVerificationCodeWithFallback(
        email: widget.email,
        code: _verificationCode,
        userName: widget.userName,
      );

      if (!mounted || _isDisposed) return;
      
      setState(() => _isLoading = false);

      if (!success && mounted && !_isDisposed) {
        _showErrorDialog('Error al enviar el código de verificación');
      }
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() => _isLoading = false);
      _showErrorDialog('Error al enviar el código de verificación');
    }
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0 || !mounted || _isResending || _isDisposed) return;

    setState(() => _isResending = true);
    
    try {
      await _sendVerificationCode();
      
      if (!mounted || _isDisposed) return;
      
      setState(() {
        _isResending = false;
        _resendCountdown = 60;
      });
      
      _startResendCountdown();
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() => _isResending = false);
    }
  }

  Future<void> _verifyCode() async {
    if (!mounted || _isDisposed || _codeController == null) return;
    
    final inputCode = _codeController!.text.trim();
    
    if (inputCode == _verificationCode) {
      // Cancelar el timer antes de verificar
      _countdownTimer?.cancel();
      
      setState(() => _isVerifying = true);
      
      try {
        // Verificar si el usuario ya existe en la base de datos
        final bool userExists = await UserService.checkUserExists(widget.email);
        
        if (!mounted || _isDisposed) return;
        
        if (userExists) {
          // Usuario existe (puede ser admin, conductor o cliente) - redirigir al login
          print('EmailVerification: Usuario existe con email ${widget.email}, redirigiendo a login');
          
          if (mounted && !_isDisposed) {
            CustomSnackbar.showSuccess(
              context,
              message: '¡Correo verificado! Ya tienes una cuenta',
              duration: const Duration(milliseconds: 1200),
            );
            await Future.delayed(const Duration(milliseconds: 1200));
          }

          if (!mounted || _isDisposed) return;
          
          print('EmailVerification: Navegando a login con email: ${widget.email}');
          Navigator.pushReplacementNamed(
            context,
            RouteNames.login,
            arguments: {
              'email': widget.email,
              'prefilled': true,
            },
          );
        } else {
          // Usuario no existe - mostrar SnackBar breve y redirigir al registro
          print('EmailVerification: Usuario NO existe, redirigiendo a registro');
          
          if (mounted && !_isDisposed) {
            CustomSnackbar.showSuccess(
              context,
              message: '¡Código verificado! Completa tu registro',
              duration: const Duration(milliseconds: 1200),
            );
            await Future.delayed(const Duration(milliseconds: 1200));
          }

          if (!mounted || _isDisposed) return;
          Navigator.pushReplacementNamed(
            context,
            RouteNames.register,
            arguments: {
              'email': widget.email,
              'userName': widget.userName,
            },
          );
        }
      } catch (e) {
        if (!mounted || _isDisposed) return;
        
        print('EmailVerification: Error verificando usuario: $e');
        
        // Si hay error al verificar, mostrar warning y continuar con registro
        await DialogHelper.showWarning(
          context,
          title: 'Aviso',
          message: 'No pudimos verificar tu estado de usuario. Continuaremos con el registro.',
          primaryButtonText: 'Continuar',
        );
        
        if (!mounted || _isDisposed) return;
        
        Navigator.pushReplacementNamed(
          context,
          RouteNames.register,
          arguments: {
            'email': widget.email,
            'userName': widget.userName,
          },
        );
      } finally {
        if (!mounted || _isDisposed) return;
        setState(() => _isVerifying = false);
      }
    } else {
      // Código incorrecto
      await DialogHelper.showError(
        context,
        title: 'Código Incorrecto',
        message: 'El código de verificación que ingresaste no es válido. Por favor, verifica e intenta nuevamente.',
        primaryButtonText: 'Reintentar',
      );
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted || _isDisposed) return;
    
    DialogHelper.showError(
      context,
      title: 'Error',
      message: message,
      primaryButtonText: 'Entendido',
    );
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
                        onPressed: () {
                          _countdownTimer?.cancel();
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
            
                        const Text(
                          'Verifica tu correo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
            
                        const SizedBox(height: 16),
            
                        Text(
                          'Hemos enviado un código de 4 dígitos a\n${widget.email}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
            
                        const SizedBox(height: 50),
            
                        if (_codeController != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: PinCodeTextField(
                              appContext: context,
                              length: 4, // Changed to 4
                              controller: _codeController!,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.fade,
                              animationDuration: const Duration(milliseconds: 300),
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(16),
                                fieldHeight: 70, // Larger boxes
                                fieldWidth: 60,
                                activeFillColor: const Color(0xFF1A1A1A),
                                inactiveFillColor: const Color(0xFF111111),
                                selectedFillColor: const Color(0xFF1A1A1A),
                                activeColor: const Color(0xFFFFFF00), // Yellow border active
                                inactiveColor: Colors.white12, // Subtle border inactive
                                selectedColor: const Color(0xFFFFFF00),
                                borderWidth: 1.5,
                              ),
                              cursorColor: const Color(0xFFFFFF00),
                              enableActiveFill: true,
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              onCompleted: (code) {
                                if (mounted && !_isLoading && !_isDisposed && !_isVerifying) {
                                  _verifyCode();
                                }
                              },
                              onChanged: (value) {},
                            ),
                          ),
            
                        const SizedBox(height: 40),
            
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _isResending || _isVerifying) ? null : _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFF00),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Verificar',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: Colors.black,
                                        ),
                                      ),
                          ),
                        ),
            
                        const SizedBox(height: 24),
            
                        TextButton(
                          onPressed: (_resendCountdown > 0 || _isResending || _isVerifying) ? null : _resendCode,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFFFF00),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFFFF00),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _resendCountdown > 0
                                      ? 'Reenviar código en ${_resendCountdown}s'
                                      : 'Reenviar código',
                                  style: TextStyle(
                                    color: (_resendCountdown > 0 || _isVerifying)
                                        ? Colors.white54
                                        : const Color(0xFFFFFF00),
                                    fontSize: 15,
                                    fontWeight: _resendCountdown > 0 ? FontWeight.w400 : FontWeight.w600,
                                  ),
                                ),
                        ),
            
                        const SizedBox(height: 40),
            
                        if (_verificationCode.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Código para desarrollo:',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _verificationCode,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFF00),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}