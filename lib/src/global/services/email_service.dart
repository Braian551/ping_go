// lib/src/global/services/email_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

class EmailService {
  // Usar URL de producción o local según configuración
  static String get _apiUrl {
    // En desarrollo puedes usar localhost, en producción usa tu servidor
    return AppConstants.emailApiUrl;
  }

  /// Genera un código de verificación de 6 dígitos
  static String generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Envía un código de verificación por correo usando el backend PHP
  static Future<bool> sendVerificationCode({
    required String email,
    required String code,
    required String userName,
  }) async {
    try {
      print('Enviando código de verificación a: $email');
      
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

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        print('Error del servidor: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error enviando correo: $e');
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
    print('🔧 MODO DESARROLLO - Código de verificación para $email: $code');
    print('📧 En producción, este código se enviaría por email real');
    return true;
  }

  /// Método de conveniencia que usa el servicio real o mock según la configuración
  static Future<bool> sendVerificationCodeWithFallback({
    required String email,
    required String code,
    required String userName,
    bool? useMock, // Si es null, usa la configuración de AppConstants
  }) async {
    final shouldUseMock = useMock ?? AppConstants.useEmailMock;
    
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
