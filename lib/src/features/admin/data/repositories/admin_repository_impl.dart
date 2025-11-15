import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import 'package:ping_go/src/core/error/exceptions.dart';
import '../../domain/entities/admin.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

/// Implementación del repositorio de administración
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<SystemStats>> getSystemStats() async {
    try {
      final stats = await remoteDataSource.getSystemStats();
      return Success(stats);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al obtener estadísticas: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getPendingDrivers() async {
    try {
      final drivers = await remoteDataSource.getPendingDrivers();
      return Success(drivers);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al obtener conductores: $e'));
    }
  }

  @override
  Future<Result<void>> approveDriver(int conductorId) async {
    try {
      await remoteDataSource.approveDriver(conductorId);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al aprobar conductor: $e'));
    }
  }

  @override
  Future<Result<void>> rejectDriver(int conductorId, String motivo) async {
    try {
      await remoteDataSource.rejectDriver(conductorId, motivo);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al rechazar conductor: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getAllUsers({int? page, int? limit}) async {
    try {
      final users = await remoteDataSource.getAllUsers(page, limit);
      return Success(users);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al obtener usuarios: $e'));
    }
  }

  @override
  Future<Result<void>> suspendUser(int userId, String motivo) async {
    try {
      await remoteDataSource.suspendUser(userId, motivo);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al suspender usuario: $e'));
    }
  }

  @override
  Future<Result<void>> activateUser(int userId) async {
    try {
      await remoteDataSource.activateUser(userId);
      return const Success(null);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Error(ConnectionFailure(e.message));
    } catch (e) {
      return Error(UnknownFailure('Error al activar usuario: $e'));
    }
  }
}
