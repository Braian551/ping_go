import '../../../../core/error/result.dart';
import '../entities/conductor_profile.dart';
import '../repositories/conductor_repository.dart';

/// Caso de uso: Actualizar vehículo del conductor
class UpdateVehicle {
  final ConductorRepository repository;

  UpdateVehicle(this.repository);

  Future<Result<Vehicle>> call(
    int conductorId,
    Vehicle vehicle,
  ) async {
    // Aquí podrías agregar validaciones de negocio
    // Por ejemplo: verificar que la placa sea única, validar año del vehículo, etc.
    
    return await repository.updateVehicle(conductorId, vehicle);
  }
}
