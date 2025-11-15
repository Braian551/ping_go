import 'package:ping_go/src/core/error/result.dart';
import '../entities/user.dart';
import '../entities/auth_session.dart';

/// Repositorio de Autenticación y Usuarios (Contrato del Dominio)
/// 
/// Define las operaciones disponibles para gestión de usuarios y autenticación.
/// Esta es una interfaz abstracta que será implementada en la capa de datos.
/// 
/// PRINCIPIOS:
/// - Contrato puro (no implementa nada)
/// - Retorna Result<T> para manejo funcional de errores
/// - Sin dependencias de frameworks (HTTP, BD, etc.)
/// - Parte del microservicio de usuarios
abstract class UserRepository {
  /// Registrar un nuevo usuario en el sistema
  /// 
  /// [nombre] Nombre del usuario
  /// [apellido] Apellido del usuario
  /// [email] Email (único en el sistema)
  /// [telefono] Teléfono de contacto
  /// [password] Contraseña (será hasheada en el backend)
  /// [direccion] Dirección opcional
  /// [latitud] Latitud de la ubicación
  /// [longitud] Longitud de la ubicación
  /// [ciudad] Ciudad
  /// [departamento] Departamento/Estado
  /// [pais] País (default: Colombia)
  /// 
  /// Retorna [Result<AuthSession>] con la sesión creada si es exitoso
  Future<Result<AuthSession>> register({
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

  /// Iniciar sesión con credenciales
  /// 
  /// [email] Email del usuario
  /// [password] Contraseña
  /// 
  /// Retorna [Result<AuthSession>] con la sesión activa si es exitoso
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  });

  /// Cerrar sesión del usuario actual
  /// 
  /// Retorna [Result<void>] indicando éxito o error
  Future<Result<void>> logout();

  /// Obtener perfil del usuario actual
  /// 
  /// [userId] ID del usuario (opcional si hay sesión activa)
  /// [email] Email del usuario (alternativo a userId)
  /// 
  /// Retorna [Result<User>] con los datos del usuario
  Future<Result<User>> getProfile({int? userId, String? email});

  /// Actualizar perfil del usuario
  /// 
  /// [userId] ID del usuario
  /// [nombre] Nuevo nombre (opcional)
  /// [apellido] Nuevo apellido (opcional)
  /// [telefono] Nuevo teléfono (opcional)
  /// 
  /// Retorna [Result<User>] con el perfil actualizado
  Future<Result<User>> updateProfile({
    required int userId,
    String? nombre,
    String? apellido,
    String? telefono,
  });

  /// Actualizar o crear ubicación principal del usuario
  /// 
  /// [userId] ID del usuario
  /// [direccion] Dirección
  /// [latitud] Latitud
  /// [longitud] Longitud
  /// [ciudad] Ciudad
  /// [departamento] Departamento
  /// [pais] País
  /// 
  /// Retorna [Result<UserLocation>] con la ubicación actualizada
  Future<Result<UserLocation>> updateLocation({
    required int userId,
    String? direccion,
    double? latitud,
    double? longitud,
    String? ciudad,
    String? departamento,
    String? pais,
  });

  /// Verificar si un usuario existe en el sistema
  /// 
  /// [email] Email a verificar
  /// 
  /// Retorna [Result<bool>] true si el usuario existe
  Future<Result<bool>> checkUserExists(String email);

  /// Obtener la sesión guardada localmente (si existe)
  /// 
  /// Retorna [Result<AuthSession?>] con la sesión si está guardada
  Future<Result<AuthSession?>> getSavedSession();

  /// Guardar sesión localmente
  /// 
  /// [session] Sesión a guardar
  /// 
  /// Retorna [Result<void>] indicando éxito o error
  Future<Result<void>> saveSession(AuthSession session);

  /// Limpiar sesión guardada localmente
  /// 
  /// Retorna [Result<void>] indicando éxito o error
  Future<Result<void>> clearSession();
}
