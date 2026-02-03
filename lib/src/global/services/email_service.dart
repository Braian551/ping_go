// lib/src/global/services/email_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

/// Servicio para envío de correos electrónicos
/// 
/// NOTA: email_service.php ahora está en el microservicio de auth
/// URL: AppConfig.authServiceUrl/email_service.php
class EmailService {
  /// URL del servicio de email
  /// Archivo movido a auth/ microservicio
  static String get _apiUrl {
    return '${AppConfig.authServiceUrl}/email_service.php';
  }

  /// Genera un código de verificación de 6 dígitos
  static String generateVerificationCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  /// Envía un código de verificación por correo usando el backend PHP
  static Future<bool> sendVerificationCode({
    required String email,
    required String code,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'code': code,
          'userName': userName,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Simula el envío de correo para desarrollo (sin API real)
  static Future<bool> sendVerificationCodeMock({
    required String email,
    required String code,
    required String userName,
  }) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 2));
    
    // Para desarrollo, siempre retorna true
    // En producción, reemplaza con tu servicio real de correo
    return true;
  }

  /// Método de conveniencia que usa el servicio real o mock según la configuración
  static Future<bool> sendVerificationCodeWithFallback({
    required String email,
    required String code,
    required String userName,
    bool? useMock,
  }) async {
    // Si useMock es explícitamente true, usar mock. 
    // De lo contrario, intentar usar el servicio real.
    final shouldUseMock = useMock ?? false;
    
    if (shouldUseMock) {
      return await sendVerificationCodeMock(
        email: email,
        code: code,
        userName: userName,
      );
    } else {
      return await sendVerificationCode(
        email: email,
        code: code,
        userName: userName,
      );
    }
  }
}
