import 'package:ping_go/src/core/error/result.dart';
import '../entities/conductor_profile.dart';

/// Repositorio de Conductores (Contrato del Dominio)
///
/// Define las operaciones disponibles para gestión de conductores.
/// Esta es una interfaz abstracta que será implementada en la capa de datos.
///
/// PRINCIPIOS:
/// - Contrato puro (no implementa nada)
/// - Retorna Result<T> para manejo funcional de errores
/// - Sin dependencias de frameworks (HTTP, BD, etc.)
/// - Parte del microservicio de conductores
abstract class ConductorRepository {
  /// Obtener perfil del conductor
  ///
  /// [conductorId] ID del conductor
  ///
  /// Retorna [Result<ConductorProfile>] con los datos del perfil
  Future<Result<ConductorProfile>> getProfile(int conductorId);

  /// Actualizar perfil del conductor
  ///
  /// [conductorId] ID del conductor
  /// [profileData] Datos del perfil a actualizar
  ///
  /// Retorna [Result<ConductorProfile>] con el perfil actualizado
  Future<Result<ConductorProfile>> updateProfile(
    int conductorId,
    Map<String, dynamic> profileData,
  );

  /// Actualizar licencia de conducir del conductor
  ///
  /// [conductorId] ID del conductor
  /// [license] Datos de la licencia
  ///
  /// Retorna [Result<DriverLicense>] con la licencia actualizada
  Future<Result<DriverLicense>> updateLicense(
    int conductorId,
    DriverLicense license,
  );

  /// Actualizar vehículo del conductor
  ///
  /// [conductorId] ID del conductor
  /// [vehicle] Datos del vehículo
  ///
  /// Retorna [Result<Vehicle>] con el vehículo actualizado
  Future<Result<Vehicle>> updateVehicle(
    int conductorId,
    Vehicle vehicle,
  );

  /// Enviar perfil para aprobación administrativa
  ///
  /// [conductorId] ID del conductor
  ///
  /// Retorna [Result<bool>] true si se envió correctamente
  Future<Result<bool>> submitForApproval(int conductorId);
}