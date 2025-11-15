import '../../domain/entities/admin.dart';

/// Modelo de Datos para SystemStats
class SystemStatsModel extends SystemStats {
  const SystemStatsModel({
    required super.totalUsuarios,
    required super.totalConductores,
    required super.conductoresPendientes,
    required super.viajesHoy,
    required super.viajesTotal,
    required super.gananciaHoy,
    required super.gananciaTotal,
  });

  factory SystemStatsModel.fromJson(Map<String, dynamic> json) {
    return SystemStatsModel(
      totalUsuarios: _parseInt(json['total_usuarios']),
      totalConductores: _parseInt(json['total_conductores']),
      conductoresPendientes: _parseInt(json['conductores_pendientes']),
      viajesHoy: _parseInt(json['viajes_hoy']),
      viajesTotal: _parseInt(json['viajes_total']),
      gananciaHoy: _parseDouble(json['ganancia_hoy']),
      gananciaTotal: _parseDouble(json['ganancia_total']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
