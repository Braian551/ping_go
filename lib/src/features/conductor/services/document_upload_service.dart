import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';

/// Servicio para subida de documentos del conductor
class DocumentUploadService {
  /// URL base del microservicio de conductores
  static String get baseUrl => AppConfig.conductorServiceUrl;

  /// Subir un documento individual
  static Future<String?> uploadDocument({
    required int conductorId,
    required String tipoDocumento,
    required String imagePath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_document.php'),
      );

      request.fields['conductor_id'] = conductorId.toString();
      request.fields['tipo_documento'] = tipoDocumento;
      request.files.add(
        await http.MultipartFile.fromPath(
          'documento',
          imagePath,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload document response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['file_url'];
        }
      }
      return null;
    } catch (e) {
      print('Error subiendo documento: $e');
      return null;
    }
  }

  /// Subir múltiples documentos del vehículo
  static Future<Map<String, String?>> uploadMultipleDocuments({
    required int conductorId,
    required Map<String, String> documents,
  }) async {
    final results = <String, String?>{};

    try {
      for (final entry in documents.entries) {
        final documentType = entry.key;
        final imagePath = entry.value;

        final url = await uploadDocument(
          conductorId: conductorId,
          tipoDocumento: documentType,
          imagePath: imagePath,
        );

        results[documentType] = url;
      }

      return results;
    } catch (e) {
      print('Error subiendo múltiples documentos: $e');
      return results;
    }
  }

  /// Subir foto de licencia
  static Future<String?> uploadLicensePhoto({
    required int conductorId,
    required String imagePath,
  }) async {
    return await uploadDocument(
      conductorId: conductorId,
      tipoDocumento: 'licencia',
      imagePath: imagePath,
    );
  }

  /// Subir foto del vehículo
  static Future<String?> uploadVehiclePhoto({
    required int conductorId,
    required String imagePath,
  }) async {
    return await uploadDocument(
      conductorId: conductorId,
      tipoDocumento: 'vehiculo',
      imagePath: imagePath,
    );
  }

  /// Subir documento de SOAT
  static Future<String?> uploadSOAT({
    required int conductorId,
    required String imagePath,
  }) async {
    return await uploadDocument(
      conductorId: conductorId,
      tipoDocumento: 'soat',
      imagePath: imagePath,
    );
  }

  /// Subir documento de tecnomecánica
  static Future<String?> uploadTecnomecanica({
    required int conductorId,
    required String imagePath,
  }) async {
    return await uploadDocument(
      conductorId: conductorId,
      tipoDocumento: 'tecnomecanica',
      imagePath: imagePath,
    );
  }

  /// Subir tarjeta de propiedad
  static Future<String?> uploadTarjetaPropiedad({
    required int conductorId,
    required String imagePath,
  }) async {
    return await uploadDocument(
      conductorId: conductorId,
      tipoDocumento: 'tarjeta_propiedad',
      imagePath: imagePath,
    );
  }
}