import 'package:ping_go/src/core/error/result.dart';
import '../repositories/user_repository.dart';

/// Use Case: Logout de Usuario
/// 
/// Encapsula la lógica de negocio para cerrar sesión.
/// 
/// RESPONSABILIDADES:
/// - Limpiar sesión local
/// - Notificar al servidor (si es necesario)
class LogoutUser {
  final UserRepository repository;

  LogoutUser(this.repository);

  /// Ejecutar el caso de uso
  Future<Result<void>> call() async {
    return await repository.logout();
  }
}
