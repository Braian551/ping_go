import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ping_go/src/core/config/app_config.dart';

class AdminService {
  static String get _baseUrl => AppConfig.adminServiceUrl;

  /// Obtiene estadísticas del dashboard
  static Future<Map<String, dynamic>> getDashboardStats({
    required int adminId,
  }) async {
    try {
      print('AdminService: Obteniendo estadísticas para admin_id: $adminId');
      
      final uri = Uri.parse('$_baseUrl/dashboard_stats.php').replace(
        queryParameters: {'admin_id': adminId.toString()},
      );
      
      print('AdminService: URL completa: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado');
        },
      );

      print('AdminService: Status Code: ${response.statusCode}');
      print('AdminService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Acceso denegado. Solo administradores pueden acceder.'
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Solicitud inválida'
        };
      }

      return {
        'success': false,
        'message': 'Error del servidor: ${response.statusCode}'
      };
    } catch (e) {
      print('AdminService Error en getDashboardStats: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }

  /// Obtiene lista de usuarios con filtros y paginación
  static Future<Map<String, dynamic>> getUsers({
    required int adminId,
    int page = 1,
    int perPage = 20,
    String? search,
    String? tipoUsuario,
    bool? esActivo,
  }) async {
    try {
      // Construir query parameters
      final queryParams = {
        'admin_id': adminId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (tipoUsuario != null) {
        queryParams['tipo_usuario'] = tipoUsuario;
      }

      if (esActivo != null) {
        queryParams['es_activo'] = esActivo ? '1' : '0';
      }

      final uri = Uri.parse('$_baseUrl/user_management.php')
          .replace(queryParameters: queryParams);

      print('AdminService.getUsers - URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: No se pudo conectar con el servidor');
        },
      );

      print('AdminService.getUsers - Status: ${response.statusCode}');
      print('AdminService.getUsers - Body preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Acceso denegado. Solo administradores pueden ver usuarios.'
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Solicitud inválida'
        };
      }

      return {
        'success': false,
        'message': 'Error del servidor: ${response.statusCode}'
      };
    } catch (e, stackTrace) {
      print('AdminService.getUsers - Exception: $e');
      print('AdminService.getUsers - StackTrace: $stackTrace');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}'
      };
    }
  }

  /// Actualiza un usuario
  static Future<Map<String, dynamic>> updateUser({
    required int adminId,
    required int userId,
    String? nombre,
    String? apellido,
    String? telefono,
    String? tipoUsuario,
    bool? esActivo,
    bool? esVerificado,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'admin_id': adminId,
        'user_id': userId,
      };

      if (nombre != null) requestData['nombre'] = nombre;
      if (apellido != null) requestData['apellido'] = apellido;
      if (telefono != null) requestData['telefono'] = telefono;
      if (tipoUsuario != null) requestData['tipo_usuario'] = tipoUsuario;
      if (esActivo != null) requestData['es_activo'] = esActivo ? 1 : 0;
      if (esVerificado != null) requestData['es_verificado'] = esVerificado ? 1 : 0;

      final response = await http.put(
        Uri.parse('$_baseUrl/user_management.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      return {'success': false, 'message': 'Error al actualizar usuario'};
    } catch (e) {
      print('Error en updateUser: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Desactiva un usuario
  static Future<Map<String, dynamic>> deleteUser({
    required int adminId,
    required int userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/user_management.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'admin_id': adminId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      return {'success': false, 'message': 'Error al eliminar usuario'};
    } catch (e) {
      print('Error en deleteUser: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Obtiene logs de auditoría
  static Future<Map<String, dynamic>> getAuditLogs({
    required int adminId,
    int page = 1,
    int perPage = 50,
    String? accion,
    int? usuarioId,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    try {
      final queryParams = {
        'admin_id': adminId.toString(),
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (accion != null) queryParams['accion'] = accion;
      if (usuarioId != null) queryParams['usuario_id'] = usuarioId.toString();
      if (fechaDesde != null) queryParams['fecha_desde'] = fechaDesde;
      if (fechaHasta != null) queryParams['fecha_hasta'] = fechaHasta;

      final uri = Uri.parse('$_baseUrl/audit_logs.php')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      return {'success': false, 'message': 'Error al obtener logs'};
    } catch (e) {
      print('Error en getAuditLogs: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Obtiene configuraciones de la app
  static Future<Map<String, dynamic>> getAppConfig({
    int? adminId,
    bool publicOnly = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (publicOnly) {
        queryParams['public'] = '1';
      } else if (adminId != null) {
        queryParams['admin_id'] = adminId.toString();
      }

      final uri = Uri.parse('$_baseUrl/app_config.php')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      return {'success': false, 'message': 'Error al obtener configuración'};
    } catch (e) {
      print('Error en getAppConfig: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Actualiza una configuración de la app
  static Future<Map<String, dynamic>> updateAppConfig({
    required int adminId,
    required String clave,
    required String valor,
    String? tipo,
    String? categoria,
    String? descripcion,
    bool? esPublica,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'admin_id': adminId,
        'clave': clave,
        'valor': valor,
      };

      if (tipo != null) requestData['tipo'] = tipo;
      if (categoria != null) requestData['categoria'] = categoria;
      if (descripcion != null) requestData['descripcion'] = descripcion;
      if (esPublica != null) requestData['es_publica'] = esPublica ? '1' : '0';

      final response = await http.put(
        Uri.parse('$_baseUrl/app_config.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }

      return {'success': false, 'message': 'Error al actualizar configuración'};
    } catch (e) {
      print('Error en updateAppConfig: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Obtener conductores pendientes de aprobación
  static Future<Map<String, dynamic>> getPendingConductors() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_pending_conductors.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en getPendingConductors: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Aprobar conductor
  static Future<Map<String, dynamic>> approveConductor({
    required int conductorId,
    required int adminId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/approve_conductor.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'admin_id': adminId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en approveConductor: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Rechazar conductor
  static Future<Map<String, dynamic>> rejectConductor({
    required int conductorId,
    required String motivo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reject_conductor.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'motivo': motivo, 
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en rejectConductor: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Obtener tarifas
  static Future<Map<String, dynamic>> getRates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/manage_rates.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en getRates: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Actualizar tarifa
  static Future<Map<String, dynamic>> updateRate({
    required String tipoVehiculo,
    required double base,
    required double km,
    required double min,
    required double comision,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/manage_rates.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'tipo_vehiculo': tipoVehiculo,
          'tarifa_base': base,
          'tarifa_km': km,
          'tarifa_min': min,
          'comision': comision,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en updateRate: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Resetear tarifas a COP
  static Future<Map<String, dynamic>> resetRates() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/force_update_rates.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en resetRates: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
  /// Obtener conductores con deuda
  static Future<Map<String, dynamic>> getDriversWithDebt() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_drivers_with_debt.php'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en getDriversWithDebt: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Cobrar comisión
  static Future<Map<String, dynamic>> collectCommission({
    required int conductorId,
    double? amount,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'conductor_id': conductorId,
      };
      
      if (amount != null) {
        body['monto'] = amount;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/collect_commission.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error ${response.statusCode}'};
    } catch (e) {
      print('Error en collectCommission: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getCommissionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_commission_history.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
