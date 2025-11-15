/// Clase Result para el manejo de resultados exitosos y fallidos
/// Parte de la arquitectura limpia (Clean Architecture)
/// Implementa el patrón Result para evitar el uso de excepciones en el dominio

import 'failures.dart';

/// Clase sellada (sealed class) para representar resultados de operaciones
/// Puede ser Success (éxito) o Error (fallo)
abstract class Result<T> {
  const Result();

  /// Crea un resultado exitoso
  factory Result.success(T data) = Success<T>;

  /// Crea un resultado de error
  factory Result.failure(Failure failure) = Error<T>;

  /// Verifica si el resultado es exitoso
  bool get isSuccess => this is Success<T>;

  /// Verifica si el resultado es un error
  bool get isError => this is Error<T>;

  /// Obtiene los datos si es exitoso, null si es error
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// Obtiene el failure si es error, null si es exitoso
  Failure? get failure => isError ? (this as Error<T>).failure : null;

  /// Ejecuta una función si el resultado es exitoso
  Result<T> onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback(data!);
    }
    return this;
  }

  /// Ejecuta una función si el resultado es un error
  Result<T> onError(void Function(Failure failure) callback) {
    if (isError) {
      callback(failure!);
    }
    return this;
  }

  /// Transforma el resultado exitoso usando una función mapper
  Result<R> map<R>(R Function(T data) mapper) {
    return isSuccess ? Result.success(mapper(data!)) : Result.failure(failure!);
  }

  /// Transforma el resultado usando funciones diferentes para éxito y error
  Result<R> fold<R>(
    R Function(T data) onSuccess,
    R Function(Failure failure) onError,
  ) {
    return isSuccess ? Result.success(onSuccess(data!)) : Result.failure(failure!);
  }

  /// Convierte el resultado a otro tipo manteniendo el estado de éxito/error
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return isSuccess ? mapper(data!) : Result.failure(failure!);
  }

  /// Obtiene el valor o lanza una excepción si es error
  T getOrThrow() {
    if (isSuccess) {
      return data!;
    } else {
      throw Exception('Result is error: ${failure!.message}');
    }
  }

  /// Obtiene el valor o un valor por defecto si es error
  T getOrDefault(T defaultValue) {
    return isSuccess ? data! : defaultValue;
  }

  /// Obtiene el valor o ejecuta una función para obtener un valor por defecto
  T getOrElse(T Function() defaultValue) {
    return isSuccess ? data! : defaultValue();
  }

  /// Ejecuta una función dependiendo del tipo de resultado (Success o Error)
  /// Similar al pattern matching en tipos sealed
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    if (isSuccess) {
      return success(data!);
    } else {
      return error(failure!);
    }
  }

  @override
  String toString() {
    return isSuccess
        ? 'Success($data)'
        : 'Error(${failure!.message})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Result<T> &&
        other.isSuccess == isSuccess &&
        ((isSuccess && other.data == data) ||
         (!isSuccess && other.failure == failure));
  }

  @override
  int get hashCode => isSuccess ? data.hashCode : failure.hashCode;
}

/// Clase que representa un resultado exitoso
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Success<T> && other.data == data);
  }

  @override
  int get hashCode => data.hashCode;
}

/// Clase que representa un resultado de error
class Error<T> extends Result<T> {
  final Failure failure;

  const Error(this.failure);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Error<T> && other.failure == failure);
  }

  @override
  int get hashCode => failure.hashCode;
}

/// Extensiones útiles para trabajar con Results
extension ResultExtensions<T> on Result<T> {
  /// Convierte un Result a un Future<Result>
  Future<Result<T>> toFuture() async => this;

  /// Ejecuta una función async si el resultado es exitoso
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) mapper) async {
    if (isSuccess) {
      try {
        final result = await mapper(data!);
        return Result.success(result);
      } catch (e) {
        return Result.failure(UnknownFailure('Async operation failed: $e'));
      }
    } else {
      return Result.failure(failure!);
    }
  }

  /// Ejecuta una función async que retorna Result si el resultado es exitoso
  Future<Result<R>> flatMapAsync<R>(Future<Result<R>> Function(T data) mapper) async {
    if (isSuccess) {
      try {
        return await mapper(data!);
      } catch (e) {
        return Result.failure(UnknownFailure('Async operation failed: $e'));
      }
    } else {
      return Result.failure(failure!);
    }
  }
}

/// Funciones de utilidad para crear Results comunes
class Results {
  /// Resultado exitoso sin datos (Unit)
  static Result<void> success() => const Success(null);

  /// Resultado exitoso con datos
  static Result<T> successData<T>(T data) => Success(data);

  /// Resultado de error genérico
  static Result<T> failure<T>(String message, {String? code}) =>
      Error(UnknownFailure(message, code: code));

  /// Resultado de error de servidor
  static Result<T> serverFailure<T>(String message, {String? code}) =>
      Error(ServerFailure(message, code: code));

  /// Resultado de error de red
  static Result<T> networkFailure<T>(String message, {String? code}) =>
      Error(NetworkFailure(message, code: code));

  /// Resultado de error de autenticación
  static Result<T> authFailure<T>(String message, {String? code}) =>
      Error(AuthFailure(message, code: code));

  /// Resultado de error de validación
  static Result<T> validationFailure<T>(String message, {String? code}) =>
      Error(ValidationFailure(message, code: code));

  /// Resultado de error de caché
  static Result<T> cacheFailure<T>(String message, {String? code}) =>
      Error(CacheFailure(message, code: code));
}