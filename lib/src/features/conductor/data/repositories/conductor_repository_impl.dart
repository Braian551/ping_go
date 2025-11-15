import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import 'package:ping_go/src/features/conductor/domain/entities/conductor_profile.dart';
import 'package:ping_go/src/features/conductor/domain/repositories/conductor_repository.dart';

/// Implementación del Repositorio de Conductores
///
/// Esta implementación retorna errores indicando que la funcionalidad
/// está en desarrollo, según los requerimientos del proyecto.
class ConductorRepositoryImpl implements ConductorRepository {
  @override
  Future<Result<ConductorProfile>> getProfile(int conductorId) async {
    return const Error(
      ServerFailure('Funcionalidad de conductores en desarrollo'),
    );
  }

  @override
  Future<Result<ConductorProfile>> updateProfile(
    int conductorId,
    Map<String, dynamic> profileData,
  ) async {
    return const Error(
      ServerFailure('Funcionalidad de conductores en desarrollo'),
    );
  }

  @override
  Future<Result<DriverLicense>> updateLicense(
    int conductorId,
    DriverLicense license,
  ) async {
    return const Error(
      ServerFailure('Funcionalidad de conductores en desarrollo'),
    );
  }

  @override
  Future<Result<Vehicle>> updateVehicle(
    int conductorId,
    Vehicle vehicle,
  ) async {
    return const Error(
      ServerFailure('Funcionalidad de conductores en desarrollo'),
    );
  }

  @override
  Future<Result<bool>> submitForApproval(int conductorId) async {
    return const Error(
      ServerFailure('Funcionalidad de conductores en desarrollo'),
    );
  }
}