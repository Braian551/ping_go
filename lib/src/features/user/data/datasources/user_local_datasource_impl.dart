import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ping_go/src/core/error/exceptions.dart';
import 'user_local_datasource.dart';

/// Implementación del Datasource Local usando SharedPreferences
/// 
/// RESPONSABILIDADES:
/// - Guardar/recuperar sesiones usando SharedPreferences
/// - Serializar/deserializar JSON
/// - Manejar errores de almacenamiento local
class UserLocalDataSourceImpl implements UserLocalDataSource {
  static const String _sessionKey = 'pingo_user_session';
  static const String _userEmailKey = 'pingo_user_email';
  static const String _userIdKey = 'pingo_user_id';
  static const String _userTypeKey = 'pingo_user_type';

  final SharedPreferences sharedPreferences;

  UserLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveSession(Map<String, dynamic> sessionData) async {
    try {
      // Guardar sesión completa como JSON
      final sessionJson = jsonEncode(sessionData);
      await sharedPreferences.setString(_sessionKey, sessionJson);

      // También guardar campos individuales para compatibilidad
      // con código legacy (UserService)
      if (sessionData.containsKey('user')) {
        final user = sessionData['user'] as Map<String, dynamic>;
        
        if (user.containsKey('email')) {
          await sharedPreferences.setString(
            _userEmailKey,
            user['email'].toString(),
          );
        }
        
        if (user.containsKey('id')) {
          final userId = user['id'] is int 
              ? user['id'] 
              : int.tryParse(user['id'].toString()) ?? 0;
          await sharedPreferences.setInt(_userIdKey, userId);
        }
        
        if (user.containsKey('tipo_usuario')) {
          await sharedPreferences.setString(
            _userTypeKey,
            user['tipo_usuario'].toString(),
          );
        }
      }
    } catch (e) {
      throw CacheException('Error al guardar sesión: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getSavedSession() async {
    try {
      final sessionJson = sharedPreferences.getString(_sessionKey);
      
      if (sessionJson != null && sessionJson.isNotEmpty) {
        return jsonDecode(sessionJson) as Map<String, dynamic>;
      }

      // Si no hay sesión completa, intentar reconstruir desde campos individuales
      // (para compatibilidad con código legacy)
      final email = sharedPreferences.getString(_userEmailKey);
      final id = sharedPreferences.getInt(_userIdKey);
      final tipoUsuario = sharedPreferences.getString(_userTypeKey);

      if (email != null || id != null) {
        return {
          'user': {
            if (id != null) 'id': id,
            if (email != null) 'email': email,
            if (tipoUsuario != null) 'tipo_usuario': tipoUsuario,
          },
          'login_at': DateTime.now().toIso8601String(),
        };
      }

      return null;
    } catch (e) {
      throw CacheException('Error al obtener sesión: ${e.toString()}');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await Future.wait([
        sharedPreferences.remove(_sessionKey),
        sharedPreferences.remove(_userEmailKey),
        sharedPreferences.remove(_userIdKey),
        sharedPreferences.remove(_userTypeKey),
      ]);
    } catch (e) {
      throw CacheException('Error al limpiar sesión: ${e.toString()}');
    }
  }
}
