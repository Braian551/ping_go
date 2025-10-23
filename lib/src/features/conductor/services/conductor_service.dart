import 'package:http/http.dart' as http;
import 'dart:convert';

class ConductorService {
  static const String baseUrl = 'http://10.0.2.2/pingo/backend/conductor';

  /// Obtener información completa del conductor
  static Future<Map<String, dynamic>?> getConductorInfo(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_info.php?conductor_id=$conductorId'),
        headers: {'Accept': 'application/json'},
      );

      print('Conductor info response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo información del conductor: $e');
      return null;
    }
  }

  /// Obtener viajes activos del conductor
  static Future<List<Map<String, dynamic>>> getViajesActivos(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_viajes_activos.php?conductor_id=$conductorId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['viajes'] != null) {
          return List<Map<String, dynamic>>.from(data['viajes']);
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo viajes activos: $e');
      return [];
    }
  }

  /// Obtener historial de viajes del conductor
  static Future<Map<String, dynamic>> getHistorialViajes({
    required int conductorId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_historial.php?conductor_id=$conductorId&page=$page&limit=$limit'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
      }
      return {'success': false, 'viajes': [], 'total': 0};
    } catch (e) {
      print('Error obteniendo historial de viajes: $e');
      return {'success': false, 'viajes': [], 'total': 0};
    }
  }

  /// Obtener estadísticas del conductor
  static Future<Map<String, dynamic>> getEstadisticas(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_estadisticas.php?conductor_id=$conductorId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['estadisticas'] ?? {};
        }
      }
      return {};
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  /// Actualizar estado de disponibilidad del conductor
  static Future<bool> actualizarDisponibilidad({
    required int conductorId,
    required bool disponible,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final body = {
        'conductor_id': conductorId,
        'disponible': disponible ? 1 : 0,
        if (latitud != null) 'latitud': latitud,
        if (longitud != null) 'longitud': longitud,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/actualizar_disponibilidad.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error actualizando disponibilidad: $e');
      return false;
    }
  }

  /// Aceptar una solicitud de viaje
  static Future<Map<String, dynamic>> aceptarSolicitud({
    required int conductorId,
    required int solicitudId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aceptar_solicitud.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'solicitud_id': solicitudId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error del servidor'};
    } catch (e) {
      print('Error aceptando solicitud: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Actualizar ubicación del conductor
  static Future<bool> actualizarUbicacion({
    required int conductorId,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/actualizar_ubicacion.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'latitud': latitud,
          'longitud': longitud,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error actualizando ubicación: $e');
      return false;
    }
  }

  /// Obtener ganancias del conductor
  static Future<Map<String, dynamic>> getGanancias({
    required int conductorId,
    String? fechaInicio,
    String? fechaFin,
  }) async {
    try {
      var uri = '$baseUrl/get_ganancias.php?conductor_id=$conductorId';
      if (fechaInicio != null) uri += '&fecha_inicio=$fechaInicio';
      if (fechaFin != null) uri += '&fecha_fin=$fechaFin';

      final response = await http.get(
        Uri.parse(uri),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
      }
      return {'success': false, 'ganancias': {}};
    } catch (e) {
      print('Error obteniendo ganancias: $e');
      return {'success': false, 'ganancias': {}};
    }
  }
}
