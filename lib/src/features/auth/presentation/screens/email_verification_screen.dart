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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            _countdownTimer?.cancel();
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            const Text(
              'Verifica tu correo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Hemos enviado un código de 6 dígitos a\n${widget.email}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            if (_codeController != null)
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _codeController!,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  activeFillColor: const Color(0xFF1A1A1A),
                  inactiveFillColor: const Color(0xFF1A1A1A),
                  selectedFillColor: const Color(0xFF1A1A1A),
                  activeColor: const Color(0xFFFFFF00),
                  inactiveColor: Colors.white30,
                  selectedColor: const Color(0xFFFFFF00),
                ),
                enableActiveFill: true,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onCompleted: (code) {
                  if (mounted && !_isLoading && !_isDisposed && !_isVerifying) {
                    _verifyCode();
                  }
                },
                onChanged: (value) {},
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_isLoading || _isResending || _isVerifying) ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFFF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isVerifying
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      )
                    : _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
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

            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: (_resendCountdown > 0 || _isResending || _isVerifying) ? null : _resendCode,
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
                          fontSize: 14,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            if (_verificationCode.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Para desarrollo:',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Código: $_verificationCode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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