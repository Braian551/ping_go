import 'package:flutter/foundation.dart';
import 'package:ping_go/src/features/user/domain/entities/user.dart';
import 'package:ping_go/src/features/user/domain/entities/auth_session.dart';
import 'package:ping_go/src/features/user/domain/usecases/register_user.dart';
import 'package:ping_go/src/features/user/domain/usecases/login_user.dart';
import 'package:ping_go/src/features/user/domain/usecases/logout_user.dart';
import 'package:ping_go/src/features/user/domain/usecases/get_user_profile.dart';
import 'package:ping_go/src/features/user/domain/usecases/update_user_profile.dart';
import 'package:ping_go/src/features/user/domain/usecases/update_user_location.dart';
import 'package:ping_go/src/features/user/domain/usecases/get_saved_session.dart';

/// Provider de Usuarios y Autenticación
/// 
/// Gestiona el estado de autenticación y perfil del usuario.
/// Invoca use cases del dominio y notifica cambios a la UI.
/// 
/// PRINCIPIOS:
/// - Solo invoca use cases (no tiene lógica de negocio)
/// - Gestiona estado de la UI (loading, error, data)
/// - Notifica cambios con notifyListeners()
/// - Parte del microservicio de usuarios
class UserProvider extends ChangeNotifier {
  final RegisterUser registerUserUseCase;
  final LoginUser loginUserUseCase;
  final LogoutUser logoutUserUseCase;
  final GetUserProfile getUserProfileUseCase;
  final UpdateUserProfile updateUserProfileUseCase;
  final UpdateUserLocation updateUserLocationUseCase;
  final GetSavedSession getSavedSessionUseCase;

  UserProvider({
    required this.registerUserUseCase,
    required this.loginUserUseCase,
    required this.logoutUserUseCase,
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.updateUserLocationUseCase,
    required this.getSavedSessionUseCase,
  });

  // Estado de autenticación
  AuthSession? _session;
  bool _isAuthenticated = false;

  // Estado de la UI
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  AuthSession? get session => _session;
  User? get currentUser => _session?.user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Registrar un nuevo usuario
  Future<bool> register({
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
    _setLoading(true);
    _clearMessages();

    final result = await registerUserUseCase(
      nombre: nombre,
      apellido: apellido,
      email: email,
      telefono: telefono,
      password: password,
      direccion: direccion,
      latitud: latitud,
      longitud: longitud,
      ciudad: ciudad,
      departamento: departamento,
      pais: pais,
    );

    return result.when(
      success: (session) {
        _session = session;
        _isAuthenticated = true;
        _setLoading(false);
        _successMessage = 'Registro exitoso';
        notifyListeners();
        return true;
      },
      error: (failure) {
        _setLoading(false);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Iniciar sesión
  Future<bool> login({
    required String email,
    required String password,
    bool saveSession = true,
  }) async {
    _setLoading(true);
    _clearMessages();

    final result = await loginUserUseCase(
      email: email,
      password: password,
      saveSession: saveSession,
    );

    return result.when(
      success: (session) {
        _session = session;
        _isAuthenticated = true;
        _setLoading(false);
        _successMessage = 'Inicio de sesión exitoso';
        notifyListeners();
        return true;
      },
      error: (failure) {
        _setLoading(false);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Cerrar sesión
  Future<bool> logout() async {
    _setLoading(true);
    _clearMessages();

    final result = await logoutUserUseCase();

    return result.when(
      success: (_) {
        _session = null;
        _isAuthenticated = false;
        _setLoading(false);
        _successMessage = 'Sesión cerrada';
        notifyListeners();
        return true;
      },
      error: (failure) {
        _setLoading(false);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Obtener perfil del usuario
  Future<bool> getProfile({int? userId, String? email}) async {
    _setLoading(true);
    _clearMessages();

    final result = await getUserProfileUseCase(
      userId: userId,
      email: email,
    );

    return result.when(
      success: (user) {
        // Actualizar el usuario en la sesión actual
        if (_session != null) {
          _session = _session!.copyWith(user: user);
        } else {
          // Crear sesión temporal si no existe
          _session = AuthSession(
            user: user,
            loginAt: DateTime.now(),
          );
        }
        _setLoading(false);
        notifyListeners();
        return true;
      },
      error: (failure) {
        _setLoading(false);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Actualizar perfil del usuario
  Future<bool> updateProfile({
    required int userId,
    String? nombre,
    String? apellido,
    String? telefono,
  }) async {
    _setLoading(true);
    _clearMessages();

    final result = await updateUserProfileUseCase(
      userId: userId,
      nombre: nombre,
      apellido: apellido,
      telefono: telefono,
    );

    return result.when(
      success: (user) {
        // Actualizar el usuario en la sesión actual
        if (_session != null) {
          _session = _session!.copyWith(user: user);
        }
        _setLoading(false);
        _successMessage = 'Perfil actualizado correctamente';
        notifyListeners();
        return true;
      },
      error: (failure) {
        _setLoading(false);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Actualizar ubicación del usuario
  Future<bool> updateLocation({
    required int userId,
    String? direccion,
    double? latitud,
    double? longitud,
    String? ciudad,
    String? departamento,
    String? pais,
  }) async {
    _setLoading(true);
    _clearMessages();

    final result = await updateUserLocationUseCase(
      userId: userId,
      direccion: direccion,
      latitud: latitud,
      longitud: longitud,
      ciudad: ciudad,
      departamento: departamento,
      pais: pais,
    );

    return result.when(
      success: (location) {
        // Actualizar la ubicación en el usuario de la sesión actual
        if (_session != null) {
          final updatedUser = _session!.user.copyWith(
            ubicacionPrincipal: location,
          );
          _session = _session!.copyWith(user: updatedUser);
        }
        _setLoading(false);
        _successMessage = 'Ubicación actualizada correctamente';
        notifyListeners();
        return true;
      },
      error: (failure) {
        _setLoading(false);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Cargar sesión guardada (útil para auto-login)
  Future<bool> loadSavedSession() async {
    _setLoading(true);

    final result = await getSavedSessionUseCase();

    return result.when(
      success: (session) {
        if (session != null) {
          _session = session;
          _isAuthenticated = true;
        }
        _setLoading(false);
        notifyListeners();
        return session != null;
      },
      error: (failure) {
        _setLoading(false);
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
    );
  }

  /// Limpiar mensajes
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
