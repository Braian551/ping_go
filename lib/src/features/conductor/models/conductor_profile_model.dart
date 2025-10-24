import 'driver_license_model.dart';
import 'vehicle_model.dart';

/// Modelo para el perfil completo del conductor
class ConductorProfileModel {
  final DriverLicenseModel? licencia;
  final VehicleModel? vehiculo;
  final VerificationStatus estadoVerificacion;
  final DateTime? fechaUltimaVerificacion;
  final List<String> documentosPendientes;
  final List<String> documentosRechazados;
  final String? motivoRechazo;
  final bool aprobado;

  ConductorProfileModel({
    this.licencia,
    this.vehiculo,
    this.estadoVerificacion = VerificationStatus.pendiente,
    this.fechaUltimaVerificacion,
    this.documentosPendientes = const [],
    this.documentosRechazados = const [],
    this.motivoRechazo,
    this.aprobado = false,
  });

  factory ConductorProfileModel.fromJson(Map<String, dynamic> json) {
    return ConductorProfileModel(
      licencia: json['licencia'] != null
          ? DriverLicenseModel.fromJson(json['licencia'])
          : null,
      vehiculo: json['vehiculo'] != null
          ? VehicleModel.fromJson(json['vehiculo'])
          : null,
      estadoVerificacion: VerificationStatus.fromString(
        json['estado_verificacion']?.toString() ?? 'pendiente',
      ),
      fechaUltimaVerificacion: json['fecha_ultima_verificacion'] != null
          ? DateTime.tryParse(json['fecha_ultima_verificacion'].toString())
          : null,
      documentosPendientes: json['documentos_pendientes'] != null
          ? List<String>.from(json['documentos_pendientes'])
          : [],
      documentosRechazados: json['documentos_rechazados'] != null
          ? List<String>.from(json['documentos_rechazados'])
          : [],
      motivoRechazo: json['motivo_rechazo']?.toString(),
      aprobado: json['aprobado'] == 1 || json['aprobado'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licencia': licencia?.toJson(),
      'vehiculo': vehiculo?.toJson(),
      'estado_verificacion': estadoVerificacion.value,
      'fecha_ultima_verificacion': fechaUltimaVerificacion?.toIso8601String(),
      'documentos_pendientes': documentosPendientes,
      'documentos_rechazados': documentosRechazados,
      'motivo_rechazo': motivoRechazo,
      'aprobado': aprobado ? 1 : 0,
    };
  }

  /// Verifica si el perfil está completo
  bool get isProfileComplete {
    return licencia != null &&
        licencia!.isComplete &&
        vehiculo != null &&
        vehiculo!.isComplete;
  }

  /// Verifica si hay documentos pendientes de subir
  bool get hasPendingDocuments {
    return documentosPendientes.isNotEmpty;
  }

  /// Verifica si hay documentos rechazados
  bool get hasRejectedDocuments {
    return documentosRechazados.isNotEmpty;
  }

  /// Verifica si el conductor puede estar disponible
  bool get canBeAvailable {
    return aprobado &&
        estadoVerificacion == VerificationStatus.aprobado &&
        isProfileComplete &&
        !hasPendingDocuments &&
        !hasRejectedDocuments;
  }

  /// Obtiene el porcentaje de completitud del perfil
  double get completionPercentage {
    int total = 0;
    int completed = 0;

    // Licencia (40%)
    total += 40;
    if (licencia != null && licencia!.isComplete) {
      completed += 40;
    } else if (licencia != null) {
      completed += 20;
    }

    // Vehículo (40%)
    total += 40;
    if (vehiculo != null && vehiculo!.isBasicComplete) {
      completed += 20;
    }
    if (vehiculo != null && vehiculo!.isDocumentsComplete) {
      completed += 20;
    }

    // Verificación (20%)
    total += 20;
    if (estadoVerificacion == VerificationStatus.aprobado) {
      completed += 20;
    } else if (estadoVerificacion == VerificationStatus.enRevision) {
      completed += 10;
    }

    return completed / total;
  }

  /// Lista de tareas pendientes para completar el perfil
  List<String> get pendingTasks {
    List<String> tasks = [];

    if (licencia == null || !licencia!.isComplete) {
      tasks.add('Registrar licencia de conducción');
    } else if (licencia!.isExpiringSoon) {
      tasks.add('Renovar licencia de conducción (vence pronto)');
    } else if (!licencia!.isValid) {
      tasks.add('Renovar licencia de conducción (vencida)');
    }

    if (vehiculo == null || !vehiculo!.isBasicComplete) {
      tasks.add('Registrar información del vehículo');
    }

    if (vehiculo != null && !vehiculo!.isDocumentsComplete) {
      tasks.add('Completar documentos del vehículo');
    }

    if (documentosPendientes.isNotEmpty) {
      tasks.addAll(documentosPendientes.map((doc) => 'Subir $doc'));
    }

    if (documentosRechazados.isNotEmpty) {
      tasks.addAll(
        documentosRechazados.map((doc) => 'Corregir y volver a subir $doc'),
      );
    }

    if (estadoVerificacion == VerificationStatus.pendiente && isProfileComplete) {
      tasks.add('Esperar verificación de documentos');
    }

    return tasks;
  }

  ConductorProfileModel copyWith({
    DriverLicenseModel? licencia,
    VehicleModel? vehiculo,
    VerificationStatus? estadoVerificacion,
    DateTime? fechaUltimaVerificacion,
    List<String>? documentosPendientes,
    List<String>? documentosRechazados,
    String? motivoRechazo,
    bool? aprobado,
  }) {
    return ConductorProfileModel(
      licencia: licencia ?? this.licencia,
      vehiculo: vehiculo ?? this.vehiculo,
      estadoVerificacion: estadoVerificacion ?? this.estadoVerificacion,
      fechaUltimaVerificacion: fechaUltimaVerificacion ?? this.fechaUltimaVerificacion,
      documentosPendientes: documentosPendientes ?? this.documentosPendientes,
      documentosRechazados: documentosRechazados ?? this.documentosRechazados,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      aprobado: aprobado ?? this.aprobado,
    );
  }
}

/// Estado de verificación del perfil del conductor
enum VerificationStatus {
  pendiente('pendiente', 'Pendiente', '⏳'),
  enRevision('en_revision', 'En Revisión', '🔍'),
  aprobado('aprobado', 'Aprobado', '✅'),
  rechazado('rechazado', 'Rechazado', '❌');

  final String value;
  final String label;
  final String emoji;

  const VerificationStatus(this.value, this.label, this.emoji);

  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VerificationStatus.pendiente,
    );
  }
}
