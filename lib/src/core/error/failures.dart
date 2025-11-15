/// Clases de Failure para el manejo de errores en la arquitectura limpia
/// Parte de la arquitectura limpia (Clean Architecture)

/// Clase base para todos los failures
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Failure para errores del servidor
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de conexión de red
class ConnectionFailure extends Failure {
  const ConnectionFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de autorización
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para recursos no encontrados
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de caché
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de ubicación/GPS
class LocationFailure extends Failure {
  const LocationFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de permisos
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de archivo
class FileFailure extends Failure {
  const FileFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de timeout
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores desconocidos
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de red genéricos
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de validación de entrada
class InputValidationFailure extends Failure {
  const InputValidationFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de sesión expirada
class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de límite de tasa (rate limiting)
class RateLimitFailure extends Failure {
  const RateLimitFailure(String message, {String? code}) : super(message, code: code);
}

/// Failure para errores de mantenimiento del sistema
class MaintenanceFailure extends Failure {
  const MaintenanceFailure(String message, {String? code}) : super(message, code: code);
}