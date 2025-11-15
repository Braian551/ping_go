import 'package:ping_go/src/core/error/result.dart';
import '../entities/auth_session.dart';
import '../repositories/user_repository.dart';

/// Use Case: Obtener Sesión Guardada
/// 
/// Encapsula la lógica de negocio para obtener una sesión guardada localmente.
/// Útil para "recordar sesión" o auto-login.
/// 
/// RESPONSABILIDADES:
/// - Obtener sesión del almacenamiento local
/// - Validar que la sesión siga siendo válida
/// - Retornar la sesión o null si no existe/expiró
class GetSavedSession {
  final UserRepository repository;

  GetSavedSession(this.repository);

  /// Ejecutar el caso de uso
  Future<Result<AuthSession?>> call() async {
    final result = await repository.getSavedSession();

    // Si obtuvimos una sesión exitosamente, validar que esté activa
    if (result is Success<AuthSession?> && result.data != null) {
      final session = result.data!;
      
      // Si la sesión expiró, limpiarla y retornar null
      if (!session.isValid) {
        await repository.clearSession();
        return Success(null);
      }
    }

    return result;
  }
}
