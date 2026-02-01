import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/app_config.dart';

/// Servicio para operaciones de conductor
/// 
/// NOTA: Este servicio es redundante con ConductorRemoteDataSource.
/// Se mantiene por compatibilidad, pero debería migrarse a usar
/// el patrón de Clean Architecture (Repository -> DataSource)
class ConductorService {
  /// URL base del microservicio de conductores
  static String get baseUrl => AppConfig.conductorServiceUrl;

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
          return data['data'] as Map<String, dynamic>;
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
      final url = '$baseUrl/get_historial.php?conductor_id=$conductorId&page=$page&limit=$limit';
      print('DEBUG: getHistorialViajes URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      print('DEBUG: getHistorialViajes status: ${response.statusCode}');
      print('DEBUG: getHistorialViajes body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
        return {'success': false, 'viajes': [], 'total': 0, 'message': data['message'] ?? 'Error desconocido'};
      }
      return {'success': false, 'viajes': [], 'total': 0, 'message': 'Error del servidor: ${response.statusCode}'};
    } catch (e) {
      print('Error obteniendo historial de viajes: $e');
      return {'success': false, 'viajes': [], 'total': 0, 'message': e.toString()};
    }
  }

  /// Obtener estadísticas del conductor
  static Future<Map<String, dynamic>> getEstadisticas(int conductorId) async {
    try {
      final url = '$baseUrl/get_estadisticas.php?conductor_id=$conductorId';
      print('DEBUG: getEstadisticas URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      print('DEBUG: getEstadisticas status: ${response.statusCode}');
      print('DEBUG: getEstadisticas body: ${response.body}');

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
        if (data['success'] == true) {
          return true;
        } else {
          // Lanzar excepción con el mensaje del servidor
          throw Exception(data['message'] ?? 'Error desconocido del servidor');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error actualizando disponibilidad: $e');
      rethrow; // Re-lanzar la excepción para que el provider la maneje
    }
  }

  /// Aceptar una solicitud de viaje
  static Future<Map<String, dynamic>> aceptarSolicitud({
    required int conductorId,
    required int solicitudId,
  }) async {
    try {
      // FIX: Changed url from aceptar_solicitud.php to accept_assignment.php
      final response = await http.post(
        Uri.parse('$baseUrl/accept_assignment.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'solicitud_id': solicitudId,
        }),
      );

      print('Accept response (${response.statusCode}): ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return data;
      }
      // Return actual error message from server
      return {'success': false, 'message': data['message'] ?? 'Error del servidor (${response.statusCode})'};
    } catch (e) {
      print('Error aceptando solicitud: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Rechazar una asignación
  static Future<bool> rejectAssignment({
    required int conductorId,
    required int solicitudId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reject_assignment.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'solicitud_id': solicitudId,
        }),
      );

      print('Reject response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error rechazando solicitud: $e');
      return false;
    }
  }

  /// Obtener lista de solicitudes disponibles (incluyendo rechazadas si siguen activas)
  static Future<List<Map<String, dynamic>>> getAvailableRequests(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_available_requests.php?conductor_id=$conductorId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['requests'] != null) {
          return List<Map<String, dynamic>>.from(data['requests']);
        }
      }
      return [];
    } catch (e) {
      print('Error buscando solicitudes disponibles: $e');
      return [];
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

  /// Enviar solicitud de verificación de conductor
  static Future<Map<String, dynamic>> submitVerification({
    required int usuarioId,
    required String numeroLicencia,
    required String vencimientoLicencia,
    required String tipoVehiculo,
    required String placaVehiculo,
    String? marcaVehiculo,
    String? modeloVehiculo,
    String? anoVehiculo,
    String? colorVehiculo,
    String? aseguradora,
    String? numeroPolizaSeguro,
    String? vencimientoSeguro,
  }) async {
    try {
      final body = {
        'usuario_id': usuarioId,
        'numero_licencia': numeroLicencia,
        'vencimiento_licencia': vencimientoLicencia,
        'tipo_vehiculo': tipoVehiculo,
        'placa_vehiculo': placaVehiculo,
        if (marcaVehiculo != null) 'marca_vehiculo': marcaVehiculo,
        if (modeloVehiculo != null) 'modelo_vehiculo': modeloVehiculo,
        if (anoVehiculo != null) 'ano_vehiculo': anoVehiculo,
        if (colorVehiculo != null) 'color_vehiculo': colorVehiculo,
        if (aseguradora != null) 'aseguradora': aseguradora,
        if (numeroPolizaSeguro != null) 'numero_poliza_seguro': numeroPolizaSeguro,
        if (vencimientoSeguro != null) 'vencimiento_seguro': vencimientoSeguro,
      };

      print('Enviando solicitud de conductor: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/submit_verification.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      
      print('Respuesta submitVerification (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
         try {
           final errorData = jsonDecode(response.body);
           return {'success': false, 'message': errorData['message'] ?? 'Error del servidor'};
         } catch (_) {
           return {'success': false, 'message': 'Error ${response.statusCode}'};
         }
      }
    } catch (e) {
      print('Error enviando verificación: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Obtener perfil de conductor (estado de solicitud)
  static Future<Map<String, dynamic>> getConductorProfile(int usuarioId) async {
    try {
      print('Consultando perfil conductor para usuario: $usuarioId');
      final response = await http.get(
        Uri.parse('$baseUrl/get_profile.php?usuario_id=$usuarioId'),
        headers: {'Accept': 'application/json'},
      );

      print('Respuesta getConductorProfile (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error obteniendo perfil conductor: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
  /// Subir documento de conductor
  static Future<bool> uploadDocument({
    required int conductorId,
    required String filePath,
    required String type, // 'licencia_frente' or 'licencia_reverso'
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/upload_documents.php');
      final request = http.MultipartRequest('POST', uri);
      
      request.fields['conductor_id'] = conductorId.toString();
      request.fields['type'] = type;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Respuesta uploadDocument ($type): ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error subiendo documento $type: $e');
      return false;
    }
  }
  
  /// Buscar solicitudes pendientes
  static Future<Map<String, dynamic>?> getPendingAssignments(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_pending_assignments.php?conductor_id=$conductorId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['hay_solicitud'] == true) {
          return data['solicitud'];
        }
      }
      return null;
    } catch (e) {
      print('Error buscando asignaciones: $e');
      return null;
    }
  }

  /// Actualizar estado del viaje (llegado, iniciado, finalizado)
  static Future<bool> updateTripStatus({
    required int solicitudId,
    required String estado, // 'en_sitio', 'en_progreso', 'completada'
    int? conductorId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/trips/update_trip_status.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
          'estado': estado,
          if (conductorId != null) 'conductor_id': conductorId,
        }),
      );

      print('UpdateTripStatus Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      print('UpdateTripStatus Failed: Status ${response.statusCode}, Body: ${response.body}');
      return false;
    } catch (e) {
      print('Error actualizando estado viaje: $e');
      return false;
    }
  }

  /// Obtener resumen final del viaje y cálculo de tarifa
  static Future<Map<String, dynamic>?> getTripSummary({
    required int solicitudId,
    required int conductorId,
    required double distanciaKm,
    required int duracionSegundos,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/trips/get_trip_summary.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
          'conductor_id': conductorId,
          'distancia_real': distanciaKm,
          'duracion_real': duracionSegundos,
        }),
      );

      print('TripSummary Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo resumen de viaje: $e');
      return null;
    }
  }
}
