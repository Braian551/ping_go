/// Excepciones personalizadas para el manejo de errores en la aplicación
/// Parte de la arquitectura limpia (Clean Architecture)

/// Excepción base para errores de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Excepción para errores del servidor
class ServerException extends AppException {
  const ServerException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de red/conexión
class NetworkException extends AppException {
  const NetworkException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de autenticación
class AuthException extends AppException {
  const AuthException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de autorización
class UnauthorizedException extends AppException {
  const UnauthorizedException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para recursos no encontrados
class NotFoundException extends AppException {
  const NotFoundException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de validación
class ValidationException extends AppException {
  const ValidationException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de caché
class CacheException extends AppException {
  const CacheException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de base de datos
class DatabaseException extends AppException {
  const DatabaseException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de ubicación/GPS
class LocationException extends AppException {
  const LocationException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de permisos
class PermissionException extends AppException {
  const PermissionException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de archivo
class FileException extends AppException {
  const FileException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores de timeout
class TimeoutException extends AppException {
  const TimeoutException(String message, {String? code}) : super(message, code: code);
}

/// Excepción para errores desconocidos
class UnknownException extends AppException {
  const UnknownException(String message, {String? code}) : super(message, code: code);
}