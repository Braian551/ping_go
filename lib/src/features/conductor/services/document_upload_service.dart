import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/app_config.dart';

/// Servicio para subir documentos del conductor
class DocumentUploadService {
  /// Sube un documento/foto al servidor
  /// 
  /// [conductorId] - ID del conductor
  /// [tipoDocumento] - Tipo: 'licencia', 'soat', 'tecnomecanica', 'tarjeta_propiedad', 'seguro'
  /// [imagePath] - Ruta local del archivo a subir
  /// 
  /// Retorna la URL relativa del documento subido o null si hay error
  static Future<String?> uploadDocument({
    required int conductorId,
    required String tipoDocumento,
    required String imagePath,
  }) async {
    debugPrint('Iniciando subida de documento: $tipoDocumento para conductor: $conductorId');
    debugPrint('Ruta del archivo: $imagePath');

    try {
      final file = File(imagePath);

      if (!await file.exists()) {
        debugPrint('Error: El archivo no existe: $imagePath');
        return null;
      }

      // Validar tamaño (max 5MB)
      final fileSize = await file.length();
      debugPrint('Tamaño del archivo: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

      if (fileSize > 5 * 1024 * 1024) {
        debugPrint('Error: El archivo excede 5MB');
        return null;
      }

      final uri = Uri.parse('${AppConfig.conductorServiceUrl}/upload_documents.php');
      debugPrint('URL del endpoint: $uri');

      final request = http.MultipartRequest('POST', uri);

      // Agregar campos
      request.fields['conductor_id'] = conductorId.toString();
      request.fields['tipo_documento'] = tipoDocumento;
      debugPrint('Campos enviados: conductor_id=$conductorId, tipo_documento=$tipoDocumento');

      // Agregar archivo
      final fileName = imagePath.split(Platform.pathSeparator).last;
      debugPrint('Nombre del archivo: $fileName');

      // Verificar nuevamente que el archivo existe justo antes de subirlo
      if (!await file.exists()) {
        debugPrint('El archivo dejó de existir antes de subirlo: $imagePath');
        return null;
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'documento',
        imagePath,
        filename: fileName,
      );
      request.files.add(multipartFile);
      debugPrint('Archivo agregado al request correctamente');

      // Enviar request
      debugPrint('Enviando request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final url = data['data']['url'];
          debugPrint('Documento subido exitosamente: $url');
          return url;
        } else {
          debugPrint('Error del servidor: ${data['message']}');
          return null;
        }
      } else {
        debugPrint('Error HTTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error al subir documento: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Sube múltiples documentos en lote
  /// 
  /// Retorna un Map con el tipo de documento y su URL
  static Future<Map<String, String?>> uploadMultipleDocuments({
    required int conductorId,
    Map<String, String>? documents,
  }) async {
    final results = <String, String?>{};

    if (documents == null || documents.isEmpty) {
      return results;
    }

    for (final entry in documents.entries) {
      final tipoDocumento = entry.key;
      final imagePath = entry.value;

      final url = await uploadDocument(
        conductorId: conductorId,
        tipoDocumento: tipoDocumento,
        imagePath: imagePath,
      );

      results[tipoDocumento] = url;
      
      // Pequeña pausa entre uploads para no saturar el servidor
      await Future.delayed(const Duration(milliseconds: 300));
    }

    return results;
  }

  /// Obtiene la URL completa del documento
  static String getDocumentUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http')) {
      return relativeUrl;
    }
    return '${AppConfig.baseUrl}/$relativeUrl';
  }

  /// Valida que el tipo de documento sea válido
  static bool isValidDocumentType(String tipo) {
    const validTypes = [
      'licencia',
      'soat',
      'tecnomecanica',
      'tarjeta_propiedad',
      'seguro',
    ];
    return validTypes.contains(tipo);
  }
}
