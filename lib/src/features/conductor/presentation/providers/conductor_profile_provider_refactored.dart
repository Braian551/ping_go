import 'package:flutter/foundation.dart';
import '../../domain/entities/conductor_profile.dart';
import '../../domain/usecases/get_conductor_profile.dart';
import '../../domain/usecases/update_conductor_profile.dart';
import '../../domain/usecases/update_driver_license.dart';
import '../../domain/usecases/update_vehicle.dart';
import '../../domain/usecases/submit_profile_for_approval.dart';

/// Provider refactorizado para gestión del perfil del conductor
/// 
/// RESPONSABILIDADES:
/// - Gestionar estado de UI (loading, error, success)
/// - Invocar use cases del dominio
/// - Notificar cambios a la UI
/// 
/// NO HACE:
/// - Lógica de negocio (está en use cases)
/// - Llamadas directas a API (está en datasources)
/// - Serialización (está en models)
/// 
/// PATRÓN: Presentation Layer
/// - Separa completamente UI de lógica de negocio
/// - Facilita testing (mock use cases)
/// - Facilita migración a BLoC o Riverpod si es necesario
class ConductorProfileProvider extends ChangeNotifier {
  final GetConductorProfile getConductorProfileUseCase;
  final UpdateConductorProfile updateProfileUseCase;
  final UpdateDriverLicense updateLicenseUseCase;
  final UpdateVehicle updateVehicleUseCase;
  final SubmitProfileForApproval submitForApprovalUseCase;

  ConductorProfileProvider({
    required this.getConductorProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateLicenseUseCase,
    required this.updateVehicleUseCase,
    required this.submitForApprovalUseCase,
  });

  // Estado
  ConductorProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ConductorProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Carga el perfil del conductor
  Future<void> loadProfile(int conductorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getConductorProfileUseCase(conductorId);

    result.when(
      success: (profile) {
        _profile = profile;
        _errorMessage = null;
      },
      error: (failure) {
        _errorMessage = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Actualiza el perfil
  Future<bool> updateProfile(
    int conductorId,
    Map<String, dynamic> profileData,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateProfileUseCase(conductorId, profileData);

    final success = result.when(
      success: (profile) {
        _profile = profile;
        _errorMessage = null;
        return true;
      },
      error: (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Actualiza la licencia
  Future<bool> updateLicense(
    int conductorId,
    DriverLicense license,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateLicenseUseCase(conductorId, license);

    final success = result.when(
      success: (updatedLicense) {
        if (_profile != null) {
          _profile = _profile!.copyWith(license: updatedLicense);
        }
        _errorMessage = null;
        return true;
      },
      error: (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Actualiza el vehículo
  Future<bool> updateVehicle(
    int conductorId,
    Vehicle vehicle,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await updateVehicleUseCase(conductorId, vehicle);

    final success = result.when(
      success: (updatedVehicle) {
        if (_profile != null) {
          _profile = _profile!.copyWith(vehicle: updatedVehicle);
        }
        _errorMessage = null;
        return true;
      },
      error: (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Envía el perfil para aprobación
  Future<bool> submitForApproval(int conductorId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await submitForApprovalUseCase(conductorId);

    final success = result.when(
      success: (_) {
        _errorMessage = null;
        return true;
      },
      error: (failure) {
        _errorMessage = failure.message;
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Limpia el estado
  void clear() {
    _profile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
