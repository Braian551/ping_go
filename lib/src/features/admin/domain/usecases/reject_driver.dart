import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import '../repositories/admin_repository.dart';

/// Use Case: Rechazar Conductor
class RejectDriver {
  final AdminRepository repository;

  RejectDriver(this.repository);

  Future<Result<void>> call(int conductorId, String motivo) async {
    if (conductorId <= 0) {
      return Error(ValidationFailure('ID de conductor inválido'));
    }

    if (motivo.trim().isEmpty) {
      return Error(ValidationFailure('Debe proporcionar un motivo'));
    }

    return await repository.rejectDriver(conductorId, motivo);
  }
}
