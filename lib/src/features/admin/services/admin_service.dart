import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

/// Servicio para operaciones de administrador
class AdminService {
  static String get baseUrl => AppConfig.adminServiceUrl;

  /// Obtener lista de banderas rojas (reportes)
  static Future<Map<String, dynamic>> getBanderas({
    bool soloPendientes = true,
    int limit = 50,
    int offset = 0,
    int? calificadoId,
  }) async {
    try {
      final queryParams = {
        'solo_pendientes': soloPendientes.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (calificadoId != null) {
        queryParams['calificado_id'] = calificadoId.toString();
      }
      
      final uri = Uri.parse('$baseUrl/get_banderas.php').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      print('getBanderas response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'data': [], 'message': 'Error del servidor: ${response.statusCode}'};
    } catch (e) {
      print('Error obteniendo banderas: $e');
      return {'success': false, 'data': [], 'message': e.toString()};
    }
  }

  /// Marcar una bandera como revisada
  static Future<bool> markBanderaRevisada(int calificacionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mark_bandera_revisada.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'calificacion_id': calificacionId}),
      );

      print('markBanderaRevisada response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error marcando bandera como revisada: $e');
      return false;
    }
  }
}
