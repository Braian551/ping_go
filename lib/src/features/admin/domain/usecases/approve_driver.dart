import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import '../repositories/admin_repository.dart';

/// Use Case: Aprobar Conductor
class ApproveDriver {
  final AdminRepository repository;

  ApproveDriver(this.repository);

  Future<Result<void>> call(int conductorId) async {
    if (conductorId <= 0) {
      return Error(ValidationFailure('ID de conductor inválido'));
    }

    return await repository.approveDriver(conductorId);
  }
}
