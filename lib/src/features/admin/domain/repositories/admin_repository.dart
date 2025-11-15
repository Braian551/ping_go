import 'package:ping_go/src/core/error/result.dart';
import '../entities/admin.dart';

/// Contrato abstracto del repositorio de administración
abstract class AdminRepository {
  /// Obtener estadísticas del sistema
  Future<Result<SystemStats>> getSystemStats();

  /// Obtener conductores pendientes de verificación
  Future<Result<List<Map<String, dynamic>>>> getPendingDrivers();

  /// Aprobar conductor
  Future<Result<void>> approveDriver(int conductorId);

  /// Rechazar conductor
  Future<Result<void>> rejectDriver(int conductorId, String motivo);

  /// Obtener todos los usuarios
  Future<Result<List<Map<String, dynamic>>>> getAllUsers({int? page, int? limit});

  /// Suspender usuario
  Future<Result<void>> suspendUser(int userId, String motivo);

  /// Activar usuario
  Future<Result<void>> activateUser(int userId);
}
