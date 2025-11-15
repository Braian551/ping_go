import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ping_go/src/core/config/app_config.dart';
import 'package:ping_go/src/core/error/exceptions.dart';
import '../models/admin_model.dart';

/// Interfaz abstracta para el datasource de admin
abstract class AdminRemoteDataSource {
  Future<SystemStatsModel> getSystemStats();
  Future<List<Map<String, dynamic>>> getPendingDrivers();
  Future<void> approveDriver(int conductorId);
  Future<void> rejectDriver(int conductorId, String motivo);
  Future<List<Map<String, dynamic>>> getAllUsers(int? page, int? limit);
  Future<void> suspendUser(int userId, String motivo);
  Future<void> activateUser(int userId);
}

/// Implementación del datasource de admin
class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AdminRemoteDataSourceImpl({
    required this.client,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? AppConfig.adminServiceUrl;

  @override
  Future<SystemStatsModel> getSystemStats() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/get_stats.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SystemStatsModel.fromJson(data['stats']);
        } else {
          throw ServerException(data['message'] ?? 'Error al obtener estadísticas');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingDrivers() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/get_pending_drivers.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['drivers'] ?? []);
        } else {
          throw ServerException(data['message'] ?? 'Error al obtener conductores');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> approveDriver(int conductorId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/approve_driver.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'conductor_id': conductorId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw ServerException(data['message'] ?? 'Error al aprobar conductor');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> rejectDriver(int conductorId, String motivo) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/reject_driver.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'conductor_id': conductorId,
          'motivo': motivo,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw ServerException(data['message'] ?? 'Error al rechazar conductor');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers(int? page, int? limit) async {
    try {
      final queryParams = StringBuffer();
      if (page != null) queryParams.write('page=$page');
      if (limit != null) queryParams.write('&limit=$limit');

      final response = await client.get(
        Uri.parse('$baseUrl/get_users.php?$queryParams'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['users'] ?? []);
        } else {
          throw ServerException(data['message'] ?? 'Error al obtener usuarios');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> suspendUser(int userId, String motivo) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/suspend_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'motivo': motivo}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw ServerException(data['message'] ?? 'Error al suspender usuario');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }

  @override
  Future<void> activateUser(int userId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/activate_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw ServerException(data['message'] ?? 'Error al activar usuario');
        }
      } else {
        throw ServerException('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Error de conexión: ${e.toString()}');
    }
  }
}
