/// Modelo para información del vehículo
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VehicleModel {
  final String? marca;
  final String? modelo;
  final int? anio;
  final String? color;
  final String placa;
  final VehicleType tipo;
  final String? aseguradora;
  final String? numeroPoliza;
  final DateTime? vencimientoSeguro;
  final String? soatNumero;
  final DateTime? soatVencimiento;
  final String? tecnomecanicaNumero;
  final DateTime? tecnomecanicaVencimiento;
  final String? tarjetaPropiedadNumero;
  final String? fotoVehiculo;
  final String? fotoTarjetaPropiedad;
  final String? fotoSoat;
  final String? fotoTecnomecanica;

  VehicleModel({
    this.marca,
    this.modelo,
    this.anio,
    this.color,
    required this.placa,
    required this.tipo,
    this.aseguradora,
    this.numeroPoliza,
    this.vencimientoSeguro,
    this.soatNumero,
    this.soatVencimiento,
    this.tecnomecanicaNumero,
    this.tecnomecanicaVencimiento,
    this.tarjetaPropiedadNumero,
    this.fotoVehiculo,
    this.fotoTarjetaPropiedad,
    this.fotoSoat,
    this.fotoTecnomecanica,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      marca: json['vehiculo_marca']?.toString(),
      modelo: json['vehiculo_modelo']?.toString(),
      anio: int.tryParse(json['vehiculo_anio']?.toString() ?? ''),
      color: json['vehiculo_color']?.toString(),
      placa: json['vehiculo_placa']?.toString() ?? '',
      tipo: VehicleType.fromString(json['vehiculo_tipo']?.toString() ?? 'motocicleta'),
      aseguradora: json['aseguradora']?.toString(),
      numeroPoliza: json['numero_poliza_seguro']?.toString(),
      vencimientoSeguro: json['vencimiento_seguro'] != null
          ? DateTime.tryParse(json['vencimiento_seguro'].toString())
          : null,
      soatNumero: json['soat_numero']?.toString(),
      soatVencimiento: json['soat_vencimiento'] != null
          ? DateTime.tryParse(json['soat_vencimiento'].toString())
          : null,
      tecnomecanicaNumero: json['tecnomecanica_numero']?.toString(),
      tecnomecanicaVencimiento: json['tecnomecanica_vencimiento'] != null
          ? DateTime.tryParse(json['tecnomecanica_vencimiento'].toString())
          : null,
      tarjetaPropiedadNumero: json['tarjeta_propiedad_numero']?.toString(),
      fotoVehiculo: json['foto_vehiculo']?.toString(),
      fotoTarjetaPropiedad: json['tarjeta_propiedad_foto_url']?.toString(),
      fotoSoat: json['soat_foto_url']?.toString(),
      fotoTecnomecanica: json['tecnomecanica_foto_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehiculo_marca': marca,
      'vehiculo_modelo': modelo,
      'vehiculo_anio': anio,
      'vehiculo_color': color,
      'vehiculo_placa': placa,
      'vehiculo_tipo': tipo.value,
      'aseguradora': aseguradora,
      'numero_poliza_seguro': numeroPoliza,
      'vencimiento_seguro': vencimientoSeguro?.toIso8601String(),
      'soat_numero': soatNumero,
      'soat_vencimiento': soatVencimiento?.toIso8601String(),
      'tecnomecanica_numero': tecnomecanicaNumero,
      'tecnomecanica_vencimiento': tecnomecanicaVencimiento?.toIso8601String(),
      'tarjeta_propiedad_numero': tarjetaPropiedadNumero,
      // Nota: Las fotos se suben por separado usando upload_documents.php
      // No se incluyen en el toJson() porque update_vehicle.php no las maneja
    };
  }

  /// Verifica si el vehículo tiene todos los datos básicos
  bool get isBasicComplete {
    return placa.isNotEmpty &&
        marca != null &&
        marca!.isNotEmpty &&
        modelo != null &&
        modelo!.isNotEmpty &&
        anio != null &&
        color != null &&
        color!.isNotEmpty;
  }

  /// Verifica si todos los documentos del vehículo están completos
  bool get isDocumentsComplete {
    return soatNumero != null &&
        soatNumero!.isNotEmpty &&
        soatVencimiento != null &&
        tecnomecanicaNumero != null &&
        tecnomecanicaNumero!.isNotEmpty &&
        tecnomecanicaVencimiento != null &&
        tarjetaPropiedadNumero != null &&
        tarjetaPropiedadNumero!.isNotEmpty;
  }

  /// Verifica si todas las fotos están cargadas
  bool get isPhotosComplete {
    return fotoVehiculo != null &&
        fotoVehiculo!.isNotEmpty &&
        fotoTarjetaPropiedad != null &&
        fotoTarjetaPropiedad!.isNotEmpty &&
        fotoSoat != null &&
        fotoSoat!.isNotEmpty &&
        fotoTecnomecanica != null &&
        fotoTecnomecanica!.isNotEmpty;
  }

  /// Verifica si el registro del vehículo está completo
  bool get isComplete {
    return isBasicComplete && isDocumentsComplete;
  }

  VehicleModel copyWith({
    String? marca,
    String? modelo,
    int? anio,
    String? color,
    String? placa,
    VehicleType? tipo,
    String? aseguradora,
    String? numeroPoliza,
    DateTime? vencimientoSeguro,
    String? soatNumero,
    DateTime? soatVencimiento,
    String? tecnomecanicaNumero,
    DateTime? tecnomecanicaVencimiento,
    String? tarjetaPropiedadNumero,
    String? fotoVehiculo,
    String? fotoTarjetaPropiedad,
    String? fotoSoat,
    String? fotoTecnomecanica,
  }) {
    return VehicleModel(
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      color: color ?? this.color,
      placa: placa ?? this.placa,
      tipo: tipo ?? this.tipo,
      aseguradora: aseguradora ?? this.aseguradora,
      numeroPoliza: numeroPoliza ?? this.numeroPoliza,
      vencimientoSeguro: vencimientoSeguro ?? this.vencimientoSeguro,
      soatNumero: soatNumero ?? this.soatNumero,
      soatVencimiento: soatVencimiento ?? this.soatVencimiento,
      tecnomecanicaNumero: tecnomecanicaNumero ?? this.tecnomecanicaNumero,
      tecnomecanicaVencimiento: tecnomecanicaVencimiento ?? this.tecnomecanicaVencimiento,
      tarjetaPropiedadNumero: tarjetaPropiedadNumero ?? this.tarjetaPropiedadNumero,
      fotoVehiculo: fotoVehiculo ?? this.fotoVehiculo,
      fotoTarjetaPropiedad: fotoTarjetaPropiedad ?? this.fotoTarjetaPropiedad,
      fotoSoat: fotoSoat ?? this.fotoSoat,
      fotoTecnomecanica: fotoTecnomecanica ?? this.fotoTecnomecanica,
    );
  }
}

/// Tipo de vehículo
enum VehicleType {
  motocicleta('motocicleta', 'Motocicleta', FontAwesomeIcons.motorcycle),
  carro('carro', 'Carro', FontAwesomeIcons.car),
  furgoneta('furgoneta', 'Furgoneta', FontAwesomeIcons.vanShuttle),
  camion('camion', 'Camión', FontAwesomeIcons.truck);

  final String value;
  final String label;
  final IconData icon;

  const VehicleType(this.value, this.label, this.icon);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => VehicleType.motocicleta,
    );
  }
}
