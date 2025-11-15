import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use Case: Actualizar Perfil de Usuario
/// 
/// Encapsula la lógica de negocio para actualizar el perfil.
/// 
/// RESPONSABILIDADES:
/// - Validar datos de entrada
/// - Invocar el repositorio para actualizar
/// - Retornar el perfil actualizado o un error
class UpdateUserProfile {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  /// Ejecutar el caso de uso
  /// 
  /// [userId] ID del usuario (requerido)
  /// [nombre] Nuevo nombre (opcional)
  /// [apellido] Nuevo apellido (opcional)
  /// [telefono] Nuevo teléfono (opcional)
  /// 
  /// Al menos un campo debe ser proporcionado para actualizar
  Future<Result<User>> call({
    required int userId,
    String? nombre,
    String? apellido,
    String? telefono,
  }) async {
    // Validación: userId debe ser positivo
    if (userId <= 0) {
      return Error(ValidationFailure('ID de usuario inválido'));
    }

    // Validación: al menos un campo debe ser proporcionado
    if (nombre == null && apellido == null && telefono == null) {
      return Error(
        ValidationFailure(
          'Debe proporcionar al menos un campo para actualizar',
        ),
      );
    }

    // Validar que los campos no estén vacíos si se proporcionan
    if (nombre != null && nombre.trim().isEmpty) {
      return Error(ValidationFailure('El nombre no puede estar vacío'));
    }

    if (apellido != null && apellido.trim().isEmpty) {
      return Error(ValidationFailure('El apellido no puede estar vacío'));
    }

    if (telefono != null && telefono.trim().isEmpty) {
      return Error(ValidationFailure('El teléfono no puede estar vacío'));
    }

    return await repository.updateProfile(
      userId: userId,
      nombre: nombre?.trim(),
      apellido: apellido?.trim(),
      telefono: telefono?.trim(),
    );
  }
}
