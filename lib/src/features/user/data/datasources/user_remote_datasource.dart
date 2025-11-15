/// Contrato para el Datasource Remoto de Usuarios
/// 
/// Define las operaciones de comunicación con el backend (API).
/// Esta es una interfaz abstracta que será implementada con HTTP.
/// 
/// RESPONSABILIDADES:
/// - Definir firma de métodos para comunicación con API
/// - No contiene lógica de negocio
/// - Trabaja con Map<String, dynamic> (JSON crudo)
abstract class UserRemoteDataSource {
  /// Registrar usuario en el backend
  /// 
  /// Retorna JSON con datos del usuario creado y ubicación
  /// Lanza [ServerException] si hay error del servidor
  /// Lanza [NetworkException] si no hay conexión
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String password,
    String? direccion,
    double? latitud,
    double? longitud,
    String? ciudad,
    String? departamento,
    String? pais,
  });

  /// Login en el backend
  /// 
  /// Retorna JSON con datos del usuario y token (si aplica)
  /// Lanza [ServerException] si credenciales son inválidas
  /// Lanza [NetworkException] si no hay conexión
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  /// Obtener perfil del usuario
  /// 
  /// Retorna JSON con datos del usuario y ubicación principal
  /// Lanza [ServerException] si el usuario no existe
  /// Lanza [NetworkException] si no hay conexión
  Future<Map<String, dynamic>> getProfile({int? userId, String? email});

  /// Actualizar perfil del usuario
  /// 
  /// Retorna JSON con el perfil actualizado
  /// Lanza [ServerException] si hay error al actualizar
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? nombre,
    String? apellido,
    String? telefono,
  });

  /// Actualizar ubicación del usuario
  /// 
  /// Retorna JSON con la ubicación actualizada
  /// Lanza [ServerException] si hay error al actualizar
  Future<Map<String, dynamic>> updateLocation({
    required int userId,
    String? direccion,
    double? latitud,
    double? longitud,
    String? ciudad,
    String? departamento,
    String? pais,
  });

  /// Verificar si un usuario existe
  /// 
  /// Retorna JSON con campo 'exists': true/false
  Future<Map<String, dynamic>> checkUserExists(String email);
}
