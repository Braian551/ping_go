import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import '../entities/auth_session.dart';
import '../repositories/user_repository.dart';

/// Use Case: Registrar Usuario
/// 
/// Encapsula la lógica de negocio para registrar un nuevo usuario en el sistema.
/// 
/// RESPONSABILIDADES:
/// - Validar datos de entrada
/// - Invocar el repositorio para crear el usuario
/// - Retornar la sesión creada o un error
/// 
/// PRINCIPIOS:
/// - Una responsabilidad: registrar usuario
/// - Sin dependencias de frameworks
/// - Testeable con unit tests
class RegisterUser {
  final UserRepository repository;

  RegisterUser(this.repository);

  /// Ejecutar el caso de uso
  /// 
  /// [nombre] Nombre del usuario (requerido, no vacío)
  /// [apellido] Apellido del usuario (requerido, no vacío)
  /// [email] Email válido (requerido)
  /// [telefono] Teléfono (requerido, no vacío)
  /// [password] Contraseña (requerido, mínimo 6 caracteres)
  /// [direccion] Dirección (opcional)
  /// [latitud] Latitud (opcional pero recomendado con longitud)
  /// [longitud] Longitud (opcional pero recomendado con latitud)
  /// [ciudad] Ciudad (opcional)
  /// [departamento] Departamento (opcional)
  /// [pais] País (opcional, default: Colombia)
  Future<Result<AuthSession>> call({
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String password,
    String? direccion,
    double? latitud,
    double? longitud,
    String? ciudad,
    String? departamento,
    String? pais,
  }) async {
    // Validaciones de negocio
    if (nombre.trim().isEmpty) {
      return Error(ValidationFailure('El nombre es requerido'));
    }

    if (apellido.trim().isEmpty) {
      return Error(ValidationFailure('El apellido es requerido'));
    }

    if (email.trim().isEmpty) {
      return Error(ValidationFailure('El email es requerido'));
    }

    if (!_isValidEmail(email)) {
      return Error(ValidationFailure('El email no es válido'));
    }

    if (telefono.trim().isEmpty) {
      return Error(ValidationFailure('El teléfono es requerido'));
    }

    if (password.length < 6) {
      return Error(
        ValidationFailure('La contraseña debe tener al menos 6 caracteres'),
      );
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

    // Invocar repositorio para registrar
    return await repository.register(
      nombre: nombre.trim(),
      apellido: apellido.trim(),
      email: email.trim().toLowerCase(),
      telefono: telefono.trim(),
      password: password,
      direccion: direccion?.trim(),
      latitud: latitud,
      longitud: longitud,
      ciudad: ciudad?.trim(),
      departamento: departamento?.trim(),
      pais: pais?.trim() ?? 'Colombia',
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
