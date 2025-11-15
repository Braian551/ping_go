import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import 'package:ping_go/src/core/error/exceptions.dart';
import 'package:ping_go/src/features/user/domain/entities/user.dart';
import 'package:ping_go/src/features/user/domain/entities/auth_session.dart';
import 'package:ping_go/src/features/user/domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';
import '../models/user_model.dart';

/// Implementación del Repositorio de Usuarios
/// 
/// RESPONSABILIDADES:
/// - Coordinar datasources (remoto y local)
/// - Convertir Models -> Entities
/// - Convertir Exceptions -> Failures
/// - Implementar lógica de caché si es necesaria
/// - Manejar errores de forma funcional (Result<T>)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
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
  }) async {
    try {
      // Llamar al datasource remoto
      final responseData = await remoteDataSource.register(
        nombre: nombre,
        apellido: apellido,
        email: email,
        telefono: telefono,
        password: password,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
        ciudad: ciudad,
        departamento: departamento,
        pais: pais,
      );

      // Extraer datos del usuario y ubicación de la respuesta
      final userData = responseData['data']?['user'] ?? responseData['user'];
      final locationData = responseData['data']?['location'] ?? responseData['location'];

      if (userData == null) {
        return Error(
          ServerFailure('Respuesta del servidor inválida: falta usuario'),
        );
      }

      // Convertir a modelo
      final userMap = userData as Map<String, dynamic>;
      if (locationData != null) {
        userMap['location'] = locationData;
      }

      final userModel = UserModel.fromJson(userMap);

      // Crear sesión
      final session = AuthSession(
        user: userModel,
        loginAt: DateTime.now(),
      );

      // Guardar sesión localmente
      await _saveSessionToLocal(session);

      return Success(session);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } on ValidationException catch (e) {
      return Error(ValidationFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Llamar al datasource remoto
      final responseData = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Extraer usuario de la respuesta
      final userData = responseData['data']?['user'] ?? responseData['user'];

      if (userData == null) {
        return Error(
          ServerFailure('Respuesta del servidor inválida: falta usuario'),
        );
      }

      // Convertir a modelo
      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

      // Crear sesión (extraer token si existe)
      final token = responseData['data']?['token'] ?? responseData['token'];

      final session = AuthSession(
        user: userModel,
        token: token as String?,
        loginAt: DateTime.now(),
      );

      return Success(session);
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      // Limpiar sesión local
      await localDataSource.clearSession();

      // TODO: Notificar al servidor si se implementa invalidación de tokens

      return Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al cerrar sesión: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> getProfile({int? userId, String? email}) async {
    try {
      // Llamar al datasource remoto
      final responseData = await remoteDataSource.getProfile(
        userId: userId,
        email: email,
      );

      // Extraer usuario y ubicación
      final userData = responseData['data']?['user'] ?? responseData['user'];
      final locationData = responseData['data']?['location'] ?? responseData['location'];

      if (userData == null) {
        return Error(
          ServerFailure('Respuesta del servidor inválida: falta usuario'),
        );
      }

      // Convertir a modelo
      final userMap = userData as Map<String, dynamic>;
      if (locationData != null) {
        userMap['location'] = locationData;
      }

      final userModel = UserModel.fromJson(userMap);

      return Success(userModel);
    } on NotFoundException catch (e) {
      return Error(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    required int userId,
    String? nombre,
    String? apellido,
    String? telefono,
  }) async {
    try {
      // Llamar al datasource remoto
      final responseData = await remoteDataSource.updateProfile(
        userId: userId,
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
      );

      // Extraer usuario actualizado
      final userData = responseData['data']?['user'] ?? responseData['user'];

      if (userData == null) {
        return Error(
          ServerFailure('Respuesta del servidor inválida: falta usuario'),
        );
      }

      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

      return Success(userModel);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Result<UserLocation>> updateLocation({
    required int userId,
    String? direccion,
    double? latitud,
    double? longitud,
    String? ciudad,
    String? departamento,
    String? pais,
  }) async {
    try {
      // Llamar al datasource remoto
      final responseData = await remoteDataSource.updateLocation(
        userId: userId,
        direccion: direccion,
        latitud: latitud,
        longitud: longitud,
        ciudad: ciudad,
        departamento: departamento,
        pais: pais,
      );

      // Extraer ubicación actualizada
      final locationData = responseData['data']?['location'] ?? 
                          responseData['location'];

      if (locationData == null) {
        return Error(
          ServerFailure('Respuesta del servidor inválida: falta ubicación'),
        );
      }

      final locationModel = UserLocationModel.fromJson(
        locationData as Map<String, dynamic>,
      );

      return Success(locationModel);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> checkUserExists(String email) async {
    try {
      final responseData = await remoteDataSource.checkUserExists(email);
      final exists = responseData['exists'] == true;
      return Success(exists);
    } catch (e) {
      // Si hay error, asumimos que no existe
      return Success(false);
    }
  }

  @override
  Future<Result<AuthSession?>> getSavedSession() async {
    try {
      final sessionData = await localDataSource.getSavedSession();

      if (sessionData == null) {
        return Success(null);
      }

      // Convertir a modelo
      final sessionModel = AuthSessionModel.fromJson(sessionData);

      return Success(sessionModel);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al obtener sesión: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> saveSession(AuthSession session) async {
    try {
      await _saveSessionToLocal(session);
      return Success(null);
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al guardar sesión: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> clearSession() async {
    return await logout();
  }

  /// Helper privado para guardar sesión
  Future<void> _saveSessionToLocal(AuthSession session) async {
    final sessionModel = AuthSessionModel.fromEntity(session);
    await localDataSource.saveSession(sessionModel.toJson());
  }
}
