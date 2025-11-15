import '../../../../core/error/result.dart';
import '../entities/conductor_profile.dart';
import '../repositories/conductor_repository.dart';

/// Caso de uso: Actualizar perfil del conductor
/// 
/// Encapsula la lógica de negocio para actualizar el perfil.
/// Puede incluir validaciones de negocio antes de persistir.
class UpdateConductorProfile {
  final ConductorRepository repository;

  UpdateConductorProfile(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Validaciones de negocio que podrían agregarse:
  /// - Verificar que el conductor tiene permisos
  /// - Validar formato de teléfono
  /// - Validar que la dirección sea válida
  Future<Result<ConductorProfile>> call(
    int conductorId,
    Map<String, dynamic> profileData,
  ) async {
    // Aquí podrías agregar validaciones de negocio
    // Por ejemplo: validar formato de teléfono, etc.
    
    return await repository.updateProfile(conductorId, profileData);
  }
}
