/// Contrato para el Datasource Local de Usuarios
/// 
/// Define las operaciones de almacenamiento local (sesiones).
/// Esta es una interfaz abstracta que será implementada con SharedPreferences.
/// 
/// RESPONSABILIDADES:
/// - Definir firma de métodos para almacenamiento local
/// - Guardar y recuperar sesiones de usuario
/// - Trabajar con Map<String, dynamic> (JSON)
abstract class UserLocalDataSource {
  /// Guardar sesión del usuario localmente
  /// 
  /// [sessionData] JSON con datos de la sesión
  /// Lanza [CacheException] si hay error al guardar
  Future<void> saveSession(Map<String, dynamic> sessionData);

  /// Obtener sesión guardada localmente
  /// 
  /// Retorna JSON con datos de la sesión o null si no existe
  /// Lanza [CacheException] si hay error al leer
  Future<Map<String, dynamic>?> getSavedSession();

  /// Limpiar sesión guardada
  /// 
  /// Lanza [CacheException] si hay error al limpiar
  Future<void> clearSession();
}
