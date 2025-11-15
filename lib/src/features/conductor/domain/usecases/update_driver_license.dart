import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart';
import '../entities/conductor_profile.dart';
import '../repositories/conductor_repository.dart';

/// Caso de uso: Actualizar licencia de conducir
class UpdateDriverLicense {
  final ConductorRepository repository;

  UpdateDriverLicense(this.repository);

  Future<Result<DriverLicense>> call(
    int conductorId,
    DriverLicense license,
  ) async {
    // Validaciones de negocio
    if (license.isExpired) {
      return const Error(
        ValidationFailure('La licencia está vencida'),
      );
    }

    return await repository.updateLicense(conductorId, license);
  }
}
