import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../global/config/api_config.dart';

class DatabaseProvider with ChangeNotifier {
  // Cambiado: ahora usa API REST en lugar de conexión MySQL directa
  bool _isConnected = false;
  String _errorMessage = '';

  bool get isConnected => _isConnected;
  String get errorMessage => _errorMessage;

  Future<void> initializeDatabase() async {
    try {
      // Verificar conexión con el backend de Railway
      // Try several candidate endpoints to help when backend path differs
      // ApiConfig.baseUrl ya incluye /ping_go/backend-deploy
      final candidates = <String>[
        ApiConfig.verifySystemUrl, // http://10.0.2.2/ping_go/backend-deploy/verify_system_json.php
        'http://10.0.2.2/ping_go/backend-deploy/verify_system_json.php',
        'http://localhost/ping_go/backend-deploy/verify_system_json.php',
        'http://127.0.0.1/ping_go/backend-deploy/verify_system_json.php',
      ];

      http.Response? response;
      String? usedUrl;

      for (final url in candidates) {
        try {
          debugPrint('Intentando verificar backend en: $url');
          response = await http
              .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
              .timeout(const Duration(seconds: 10));
          usedUrl = url;
          if (response.statusCode == 200) break; // success
          // if 404 continue to next candidate
        } catch (err) {
          // Timeout or network error -> keep trying
          debugPrint('Error al solicitar $url: $err');
          response = null;
          usedUrl = url;
        }
      }

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['database'] == 'connected') {
          _isConnected = true;
          _errorMessage = '';
          print(' Conexión con backend verificada correctamente');
        } else {
          throw Exception('Backend respondió pero base de datos no conectada');
        }
      } else {
        // If we finished trying all candidates and nothing worked, provide clearer message
        final tried = candidates.join('\n');
        final code = response != null ? response.statusCode.toString() : 'no-response';
        throw Exception('Error HTTP: $code. Se intentaron las siguientes URLs:\n$tried\n' +
          'Asegúrate que Laragon está ejecutando el backend en esa ruta o actualiza ApiConfig.baseUrl. Última URL probada: $usedUrl');
      }

      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _errorMessage = 'Error al conectar con el backend: $e';
      print(' Error al conectar con backend: $e');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> closeConnection() async {
    // Para API REST, no hay conexión que cerrar
    _isConnected = false;
    _errorMessage = '';
    notifyListeners();
  }
}