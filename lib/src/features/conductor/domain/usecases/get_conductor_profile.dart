import '../../../../core/error/result.dart';
import '../entities/conductor_profile.dart';
import '../repositories/conductor_repository.dart';

/// Caso de uso: Obtener perfil del conductor
/// 
/// Encapsula la lógica de negocio para obtener el perfil de un conductor.
/// Sigue el principio de responsabilidad única (SRP).
/// 
/// NOTA PARA MIGRACIÓN A MICROSERVICIOS:
/// - Este use case puede invocar múltiples repositorios si es necesario
/// - Por ejemplo, podría consultar el servicio de conductores Y el servicio de pagos
/// - Facilita la orquestación de llamadas a diferentes microservicios
class GetConductorProfile {
  final ConductorRepository repository;

  GetConductorProfile(this.repository);

  /// Ejecuta el caso de uso
  /// 
  /// Parámetros:
  /// - [conductorId]: ID del conductor a consultar
  /// 
  /// Retorna:
  /// - Success<ConductorProfile>: Si se encontró el perfil
  /// - Error: Si ocurrió un error (network, servidor, etc.)
  Future<Result<ConductorProfile>> call(int conductorId) async {
    return await repository.getProfile(conductorId);
  }
}
