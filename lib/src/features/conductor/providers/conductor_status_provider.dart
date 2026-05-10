import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/conductor_service.dart';

class ConductorStatusProvider with ChangeNotifier {
  bool _isOnline = false;
  bool _isBusy = false;
  Map<String, dynamic>? _pendingAssignment;

  Timer? _locationTimer;
  Timer? _assignmentTimer;

  int? _conductorId;
  String? _vehicleType;

  bool get isOnline => _isOnline;
  bool get isBusy => _isBusy;
  Map<String, dynamic>? get pendingAssignment => _pendingAssignment;

  void initialize(int conductorId, String? vehicleType) {
    if (conductorId <= 0) return;

    final hasChanged = _conductorId != conductorId;
    _conductorId = conductorId;
    _vehicleType = vehicleType;

    if (hasChanged) {
      _pendingAssignment = null;
      _isBusy = false;
      notifyListeners();
    }
  }

  void updateVehicleType(String? type) {
    _vehicleType = type;
    notifyListeners();
  }

  Future<void> toggleOnline() async {
    if (_isOnline) {
      await _stopOnlineServices();
    } else {
      await _startOnlineServices();
    }
  }

  Future<void> _startOnlineServices() async {
    if (_conductorId == null) return;

    final commissionStatus = await ConductorService.getCommissionStatus(
      _conductorId!,
    );
    final hasPendingCommission =
        commissionStatus['success'] == true &&
        commissionStatus['data']?['debe_pagar'] == true;
    if (hasPendingCommission) {
      final debt = commissionStatus['data']?['deuda_actual']?.toString() ?? '0';
      throw Exception(
        'COMISION_PENDIENTE: Debes pagar tu comisión pendiente (\$$debt COP) para conectarte.',
      );
    }

    // Check permissions
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación requeridos');
    }

    try {
      // Update backend availability
      await ConductorService.actualizarDisponibilidad(
        conductorId: _conductorId!,
        disponible: true,
      );

      _isOnline = true;
      notifyListeners();

      // Start timers
      _locationTimer?.cancel();
      _assignmentTimer?.cancel();

      // Initial update
      _updateLocation();
      _checkPendingAssignments();

      _locationTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updateLocation(),
      );
      _assignmentTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _checkPendingAssignments(),
      );
    } catch (e) {
      print('Error starting online services: $e');
      rethrow;
    }
  }

  Future<void> _stopOnlineServices() async {
    if (_conductorId != null) {
      try {
        await ConductorService.actualizarDisponibilidad(
          conductorId: _conductorId!,
          disponible: false,
        );
      } catch (e) {
        print('Error updating availability to offline: $e');
      }
    }

    _isOnline = false;
    _locationTimer?.cancel();
    _assignmentTimer?.cancel();
    _locationTimer = null;
    _assignmentTimer = null;
    notifyListeners();
  }

  Future<void> _updateLocation() async {
    if (!_isOnline || _conductorId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      await ConductorService.actualizarUbicacion(
        conductorId: _conductorId!,
        latitud: position.latitude,
        longitud: position.longitude,
      );
    } catch (e) {
      print('Error updating global location: $e');
    }
  }

  Future<void> _checkPendingAssignments() async {
    if (!_isOnline || _conductorId == null || _isBusy) return;

    try {
      final assignment = await ConductorService.getPendingAssignments(
        _conductorId!,
      );

      if (assignment == null) {
        if (_pendingAssignment != null) {
          _pendingAssignment = null;
          notifyListeners();
        }
        return;
      }

      final incomingId = assignment['solicitud_id']?.toString();
      final currentId = _pendingAssignment?['solicitud_id']?.toString();

      if (_pendingAssignment == null || incomingId != currentId) {
        _pendingAssignment = assignment;
        notifyListeners();
      }
    } catch (e) {
      print('Error polling global assignments: $e');
    }
  }

  void setPendingAssignment(Map<String, dynamic> assignment) {
    _pendingAssignment = assignment;
    notifyListeners();
  }

  void clearPendingAssignment() {
    _pendingAssignment = null;
    notifyListeners();
  }

  void setBusy(bool busy) {
    _isBusy = busy;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _assignmentTimer?.cancel();
    super.dispose();
  }
}
