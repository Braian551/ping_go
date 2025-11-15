import '../../../../core/error/result.dart';
import '../../../../core/error/failures.dart';
import '../repositories/conductor_repository.dart';

/// Caso de uso: Enviar perfil para aprobación
/// 
/// Verifica que el perfil esté completo antes de enviar para aprobación.
/// Este es un buen ejemplo de lógica de negocio en el dominio.
class SubmitProfileForApproval {
  final ConductorRepository repository;

  SubmitProfileForApproval(this.repository);

  Future<Result<bool>> call(int conductorId) async {
    // Primero verificamos que el perfil esté completo
    final profileResult = await repository.getProfile(conductorId);

    return await profileResult.when(
      success: (profile) async {
        if (!profile.isProfileComplete) {
          return const Error(
            ValidationFailure(
              'El perfil debe estar completo antes de enviar para aprobación',
            ),
          );
        }

        return await repository.submitForApproval(conductorId);
      },
      error: (failure) => Error(failure),
    );
  }
}
