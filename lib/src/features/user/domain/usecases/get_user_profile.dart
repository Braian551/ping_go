import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use Case: Obtener Perfil de Usuario
/// 
/// Encapsula la lógica de negocio para obtener el perfil de un usuario.
/// 
/// RESPONSABILIDADES:
/// - Validar parámetros de entrada
/// - Invocar el repositorio para obtener el perfil
/// - Retornar el perfil o un error
class GetUserProfile {
  final UserRepository repository;

  GetUserProfile(this.repository);

  /// Ejecutar el caso de uso
  /// 
  /// [userId] ID del usuario (opcional si hay email)
  /// [email] Email del usuario (opcional si hay userId)
  /// 
  /// Al menos uno de los dos parámetros debe ser proporcionado
  Future<Result<User>> call({int? userId, String? email}) async {
    // Validación: al menos uno debe estar presente
    if (userId == null && (email == null || email.trim().isEmpty)) {
      return Error(
        ValidationFailure(
          'Debe proporcionar userId o email',
        ),
      );
    }

    // Validar email si se proporciona
    if (email != null && email.isNotEmpty && !_isValidEmail(email)) {
      return Error(ValidationFailure('El email no es válido'));
    }

    return await repository.getProfile(
      userId: userId,
      email: email?.trim().toLowerCase(),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
