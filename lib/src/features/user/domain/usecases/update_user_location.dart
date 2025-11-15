import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use Case: Actualizar Ubicación del Usuario
/// 
/// Encapsula la lógica de negocio para actualizar la ubicación principal.
/// 
/// RESPONSABILIDADES:
/// - Validar datos de ubicación
/// - Invocar el repositorio para actualizar
/// - Retornar la ubicación actualizada o un error
class UpdateUserLocation {
  final UserRepository repository;

  UpdateUserLocation(this.repository);

  /// Ejecutar el caso de uso
  /// 
  /// [userId] ID del usuario (requerido)
  /// [direccion] Dirección (opcional)
  /// [latitud] Latitud (opcional pero recomendado con longitud)
  /// [longitud] Longitud (opcional pero recomendado con latitud)
  /// [ciudad] Ciudad (opcional)
  /// [departamento] Departamento (opcional)
  /// [pais] País (opcional)
  Future<Result<UserLocation>> call({
    required int userId,
    String? direccion,
    double? latitud,
    double? longitud,
    String? ciudad,
    String? departamento,
    String? pais,
  }) async {
    // Validación: userId debe ser positivo
    if (userId <= 0) {
      return Error(ValidationFailure('ID de usuario inválido'));
    }

    // Si se proporciona latitud, longitud también es requerida (y viceversa)
    if ((latitud != null && longitud == null) ||
        (latitud == null && longitud != null)) {
      return Error(
        ValidationFailure(
          'Latitud y longitud deben proporcionarse juntas',
        ),
      );
    }

    // Validar rango de coordenadas si se proporcionan
    if (latitud != null && longitud != null) {
      if (latitud < -90 || latitud > 90) {
        return Error(
          ValidationFailure('Latitud debe estar entre -90 y 90'),
        );
      }
      if (longitud < -180 || longitud > 180) {
        return Error(
          ValidationFailure('Longitud debe estar entre -180 y 180'),
        );
      }
    }

    return await repository.updateLocation(
      userId: userId,
      direccion: direccion?.trim(),
      latitud: latitud,
      longitud: longitud,
      ciudad: ciudad?.trim(),
      departamento: departamento?.trim(),
      pais: pais?.trim(),
    );
  }
}
