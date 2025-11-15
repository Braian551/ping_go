import 'package:ping_go/src/core/error/result.dart';
import '../entities/admin.dart';
import '../repositories/admin_repository.dart';

/// Use Case: Obtener Estadísticas del Sistema
class GetSystemStats {
  final AdminRepository repository;

  GetSystemStats(this.repository);

  Future<Result<SystemStats>> call() async {
    return await repository.getSystemStats();
  }
}
