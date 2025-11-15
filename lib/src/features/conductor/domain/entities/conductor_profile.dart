/// Entidad de dominio: Perfil del Conductor
/// 
/// Esta clase representa el concepto de negocio puro, sin dependencias
/// de frameworks o detalles de implementación. Es inmutable y contiene
/// solo la lógica de negocio esencial.
/// 
/// NOTA PARA MIGRACIÓN A MICROSERVICIOS:
/// - Esta entidad podría ser parte de un "Conductor Service"
/// - Puede ser fácilmente serializada para comunicación entre servicios
class ConductorProfile {
  final int id;
  final int conductorId;
  final String? nombreCompleto;
  final String? telefono;
  final String? direccion;
  final DriverLicense? license;
  final Vehicle? vehicle;
  final bool aprobado;
  final String? motivoRechazo;
  final DateTime? fechaAprobacion;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  const ConductorProfile({
    required this.id,
    required this.conductorId,
    this.nombreCompleto,
    this.telefono,
    this.direccion,
    this.license,
    this.vehicle,
    this.aprobado = false,
    this.motivoRechazo,
    this.fechaAprobacion,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  /// Verifica si el perfil está completo
  bool get isProfileComplete {
    return nombreCompleto != null &&
        nombreCompleto!.isNotEmpty &&
        telefono != null &&
        telefono!.isNotEmpty &&
        direccion != null &&
        direccion!.isNotEmpty &&
        license != null &&
        license!.isComplete &&
        vehicle != null &&
        vehicle!.isComplete;
  }

  /// Calcula el porcentaje de completitud del perfil
  int get completionPercentage {
    int completed = 0;
    const int total = 5; // nombre, teléfono, dirección, licencia, vehículo

    if (nombreCompleto != null && nombreCompleto!.isNotEmpty) completed++;
    if (telefono != null && telefono!.isNotEmpty) completed++;
    if (direccion != null && direccion!.isNotEmpty) completed++;
    if (license != null && license!.isComplete) completed++;
    if (vehicle != null && vehicle!.isComplete) completed++;

    return ((completed / total) * 100).round();
  }

  /// Crea una copia del perfil con campos actualizados
  ConductorProfile copyWith({
    int? id,
    int? conductorId,
    String? nombreCompleto,
    String? telefono,
    String? direccion,
    DriverLicense? license,
    Vehicle? vehicle,
    bool? aprobado,
    String? motivoRechazo,
    DateTime? fechaAprobacion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return ConductorProfile(
      id: id ?? this.id,
      conductorId: conductorId ?? this.conductorId,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      license: license ?? this.license,
      vehicle: vehicle ?? this.vehicle,
      aprobado: aprobado ?? this.aprobado,
      motivoRechazo: motivoRechazo ?? this.motivoRechazo,
      fechaAprobacion: fechaAprobacion ?? this.fechaAprobacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }
}

/// Entidad de dominio: Licencia de Conducir
class DriverLicense {
  final String? numero;
  final String? tipo;
  final DateTime? fechaEmision;
  final DateTime? fechaExpiracion;
  final String? imagenFrente;
  final String? imagenReverso;

  const DriverLicense({
    this.numero,
    this.tipo,
    this.fechaEmision,
    this.fechaExpiracion,
    this.imagenFrente,
    this.imagenReverso,
  });

  bool get isComplete {
    return numero != null &&
        numero!.isNotEmpty &&
        tipo != null &&
        fechaEmision != null &&
        fechaExpiracion != null;
  }

  bool get isExpired {
    if (fechaExpiracion == null) return false;
    return DateTime.now().isAfter(fechaExpiracion!);
  }

  DriverLicense copyWith({
    String? numero,
    String? tipo,
    DateTime? fechaEmision,
    DateTime? fechaExpiracion,
    String? imagenFrente,
    String? imagenReverso,
  }) {
    return DriverLicense(
      numero: numero ?? this.numero,
      tipo: tipo ?? this.tipo,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      imagenFrente: imagenFrente ?? this.imagenFrente,
      imagenReverso: imagenReverso ?? this.imagenReverso,
    );
  }
}

/// Entidad de dominio: Vehículo
class Vehicle {
  final String? marca;
  final String? modelo;
  final int? anio;
  final String? placa;
  final String? color;
  final int? capacidadPasajeros;
  final String? tipo;
  final String? imagenFrontal;
  final String? imagenLateral;
  final String? imagenTrasera;
  final String? imagenInterior;

  const Vehicle({
    this.marca,
    this.modelo,
    this.anio,
    this.placa,
    this.color,
    this.capacidadPasajeros,
    this.tipo,
    this.imagenFrontal,
    this.imagenLateral,
    this.imagenTrasera,
    this.imagenInterior,
  });

  bool get isComplete {
    return marca != null &&
        marca!.isNotEmpty &&
        modelo != null &&
        modelo!.isNotEmpty &&
        anio != null &&
        placa != null &&
        placa!.isNotEmpty &&
        color != null &&
        capacidadPasajeros != null;
  }

  Vehicle copyWith({
    String? marca,
    String? modelo,
    int? anio,
    String? placa,
    String? color,
    int? capacidadPasajeros,
    String? tipo,
    String? imagenFrontal,
    String? imagenLateral,
    String? imagenTrasera,
    String? imagenInterior,
  }) {
    return Vehicle(
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      placa: placa ?? this.placa,
      color: color ?? this.color,
      capacidadPasajeros: capacidadPasajeros ?? this.capacidadPasajeros,
      tipo: tipo ?? this.tipo,
      imagenFrontal: imagenFrontal ?? this.imagenFrontal,
      imagenLateral: imagenLateral ?? this.imagenLateral,
      imagenTrasera: imagenTrasera ?? this.imagenTrasera,
      imagenInterior: imagenInterior ?? this.imagenInterior,
    );
  }
}
