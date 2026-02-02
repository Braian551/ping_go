import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

class TripRequestService {
  static String get baseUrl => AppConfig.baseUrl;

  /// Crear una nueva solicitud de viaje
  static Future<Map<String, dynamic>> createTripRequest({
    required int userId,
    required double latitudOrigen,
    required double longitudOrigen,
    required String direccionOrigen,
    required double latitudDestino,
    required double longitudDestino,
    required String direccionDestino,
    required String tipoServicio, // 'viaje' o 'paquete'
    required String tipoVehiculo, // 'moto', 'carro', 'moto_carga', 'carro_carga'
    required double distanciaKm,
    required int duracionMinutos,
    required double precioEstimado,
  }) async {
    try {
      final url = '$baseUrl/user/create_trip_request.php';
      print('📍 Enviando solicitud a: $url');
      
      final requestBody = {
        'usuario_id': userId,
        'latitud_origen': latitudOrigen,
        'longitud_origen': longitudOrigen,
        'direccion_origen': direccionOrigen,
        'latitud_destino': latitudDestino,
        'longitud_destino': longitudDestino,
        'direccion_destino': direccionDestino,
        'tipo_servicio': tipoServicio,
        'tipo_vehiculo': tipoVehiculo,
        'distancia_km': distanciaKm,
        'duracion_minutos': duracionMinutos,
        'precio_estimado': precioEstimado,
      };
      
      print('📦 Datos enviados: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
        },
      );

      print('📥 Respuesta recibida - Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Solicitud creada exitosamente');
          return data;
        } else {
          final errorMsg = data['message'] ?? 'Error al crear solicitud';
          print('❌ Error del servidor: $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg = 'Error del servidor: ${response.statusCode} - ${response.body}';
        print('❌ $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Error en createTripRequest: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('Connection')) {
        throw Exception('No se pudo conectar al servidor. Verifica tu conexión.');
      }
      throw Exception('Error al crear solicitud de viaje: $e');
    }
  }

  /// Buscar conductores cercanos disponibles
  static Future<List<Map<String, dynamic>>> findNearbyDrivers({
    required double latitude,
    required double longitude,
    required String vehicleType,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/find_nearby_drivers.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitud': latitude,
          'longitud': longitude,
          'tipo_vehiculo': vehicleType,
          'radio_km': radiusKm,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['conductores'] ?? []);
        } else {
          return [];
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error buscando conductores cercanos: $e');
      return [];
    }
  }

  /// Cancelar solicitud de viaje
  static Future<bool> cancelTripRequest(int solicitudId) async {
    try {
      print('🚫 Cancelando solicitud ID: $solicitudId');
      
      final url = '$baseUrl/user/cancel_trip_request.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al cancelar');
        },
      );

      print('📥 Respuesta de cancelación - Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('✅ Solicitud cancelada exitosamente');
          return true;
        } else {
          print('❌ Error al cancelar: ${data['message']}');
          throw Exception(data['message'] ?? 'Error al cancelar la solicitud');
        }
      } else {
        print('❌ Error del servidor: ${response.statusCode}');
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error cancelando solicitud: $e');
      rethrow;
    }
  }

  /// Obtener estado de la solicitud
  static Future<Map<String, dynamic>?> getTripRequestStatus(int solicitudId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/get_trip_status.php?solicitud_id=$solicitudId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['solicitud'];
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo estado de solicitud: $e');
      return null;
    }
  }

  /// Obtener estado completo del viaje con info del conductor
  static Future<Map<String, dynamic>> getTripStatus({
    required int solicitudId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/get_trip_status.php?solicitud_id=$solicitudId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error al obtener estado: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error obteniendo estado: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Cancelar solicitud con parámetros completos
  static Future<Map<String, dynamic>> cancelTripRequestWithReason({
    required int solicitudId,
    required int clienteId,
    String motivo = 'Cliente canceló',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/cancel_trip_request.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
          'cliente_id': clienteId,
          'motivo': motivo,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error cancelando solicitud: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  /// Asignar conductor a una solicitud
  static Future<Map<String, dynamic>> assignDriver({
    required int solicitudId,
    required int conductorId,
    bool autoAccept = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/assign_driver.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
          'conductor_id': conductorId,
          'auto_accept': autoAccept,
        }),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Error al asignar conductor');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error assignDriver: $e');
      rethrow;
    }
  }

  /// Obtener tarifas públicas de vehículos
  static Future<List<Map<String, dynamic>>> getPublicRates() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trips/get_public_rates.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error obteniendo tarifas: $e');
      return [];
    }
  }
  static Future<Map<String, dynamic>> getTripSummary(int solicitudId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/get_trip_summary.php?solicitud_id=$solicitudId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error getting summary: $e');
      return {};
    }
  }

  /// Calificar un viaje completado
  static Future<Map<String, dynamic>> rateTrip({
    required int solicitudId,
    required int usuarioId,
    required int calificacion,
    String comentario = '',
  }) async {
    try {
      print('⭐ Enviando calificación: $calificacion para solicitud $solicitudId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/user/rate_trip.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
          'usuario_id': usuarioId,
          'calificacion': calificacion,
          'comentario': comentario,
        }),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Tiempo de espera agotado');
      });

      print('📥 Respuesta rating - Status: ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error enviando calificación: $e');
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
  /// Obtener historial de viajes del usuario
  static Future<List<Map<String, dynamic>>> getUserHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/get_user_history.php?usuario_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['historial'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting history: $e');
      return [];
    }
  }

  /// Obtener estadísticas del usuario (viajes, etc.)
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/get_user_stats.php?usuario_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['stats'] ?? {};
        }
      }
      return {};
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }
}
