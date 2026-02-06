import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/conductor_profile_model.dart';
import '../models/driver_license_model.dart';
import '../models/vehicle_model.dart';

/// Servicio para operaciones del perfil del conductor
class ConductorProfileService {
  /// URL base del microservicio de conductores
  static String get baseUrl => AppConfig.conductorServiceUrl;

  /// Obtener perfil del conductor
  static Future<ConductorProfileModel?> getProfile(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_profile.php?conductor_id=$conductorId'),
        headers: {'Accept': 'application/json'},
      );

      print('Conductor profile response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return ConductorProfileModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error obteniendo perfil del conductor: $e');
      return null;
    }
  }

  /// Actualizar licencia de conducción
  static Future<Map<String, dynamic>> updateLicense({
    required int conductorId,
    required DriverLicenseModel license,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_license.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'license': license.toJson(),
        }),
      );

      print('Update license response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error del servidor'};
    } catch (e) {
      print('Error actualizando licencia: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Actualizar vehículo
  static Future<Map<String, dynamic>> updateVehicle({
    required int conductorId,
    required VehicleModel vehicle,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_vehicle.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
          'vehicle': vehicle.toJson(),
        }),
      );

      print('Update vehicle response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error del servidor'};
    } catch (e) {
      print('Error actualizando vehículo: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Subir documento
  static Future<Map<String, dynamic>> uploadDocument({
    required int conductorId,
    required String documentType,
    required File imageFile,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_document.php'),
      );

      request.fields['conductor_id'] = conductorId.toString();
      request.fields['document_type'] = documentType;
      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload document response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error del servidor'};
    } catch (e) {
      print('Error subiendo documento: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Actualizar perfil completo
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_profile.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('Update profile response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error del servidor'};
    } catch (e) {
      print('Error actualizando perfil: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Enviar perfil para verificación
  static Future<Map<String, dynamic>> submitForVerification(int conductorId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/submit_for_verification.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'conductor_id': conductorId,
        }),
      );

      print('Submit for verification response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Error del servidor'};
    } catch (e) {
      print('Error enviando para verificación: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Obtener estado de verificación
  static Future<Map<String, dynamic>> getVerificationStatus(int conductorId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_verification_status.php?conductor_id=$conductorId'),
        headers: {'Accept': 'application/json'},
      );

      print('Verification status response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data;
        }
      }
      return {'success': false};
    } catch (e) {
      print('Error obteniendo estado de verificación: $e');
      return {'success': false};
    }
  }
}