/// Modelo para información de la licencia de conducción
class DriverLicenseModel {
  final String numero;
  final DateTime fechaExpedicion;
  final DateTime fechaVencimiento;
  final LicenseCategory categoria;
  final String? foto;
  final String? fotoReverso;
  final bool isVerified;

  DriverLicenseModel({
    required this.numero,
    required this.fechaExpedicion,
    required this.fechaVencimiento,
    required this.categoria,
    this.foto,
    this.fotoReverso,
    this.isVerified = false,
  });

  factory DriverLicenseModel.fromJson(Map<String, dynamic> json) {
    return DriverLicenseModel(
      numero: json['licencia_conduccion']?.toString() ?? '',
      fechaExpedicion: json['licencia_expedicion'] != null
          ? DateTime.parse(json['licencia_expedicion'].toString())
          : DateTime.now(),
      fechaVencimiento: json['licencia_vencimiento'] != null
          ? DateTime.parse(json['licencia_vencimiento'].toString())
          : DateTime.now(),
      categoria: LicenseCategory.fromString(
        json['licencia_categoria']?.toString() ?? 'C1',
      ),
      foto: json['licencia_foto_url']?.toString(),
      fotoReverso: json['licencia_foto_reverso']?.toString(),
      isVerified: json['licencia_verificada'] == 1 || json['licencia_verificada'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'licencia_conduccion': numero,
      'licencia_expedicion': fechaExpedicion.toIso8601String(),
      'licencia_vencimiento': fechaVencimiento.toIso8601String(),
      'licencia_categoria': categoria.value,
      'licencia_foto': foto,
      'licencia_foto_reverso': fotoReverso,
      'licencia_verificada': isVerified ? 1 : 0,
    };
  }

  /// Verifica si la licencia está vigente
  bool get isValid {
    return fechaVencimiento.isAfter(DateTime.now());
  }

  /// Verifica si la licencia está próxima a vencer (30 días)
  bool get isExpiringSoon {
    final daysUntilExpiry = fechaVencimiento.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  /// Días restantes hasta el vencimiento
  int get daysUntilExpiry {
    return fechaVencimiento.difference(DateTime.now()).inDays;
  }

  /// Verifica si todos los datos están completos
  bool get isComplete {
    return numero.isNotEmpty &&
        categoria != LicenseCategory.ninguna &&
        fechaVencimiento.isAfter(DateTime.now());
  }

  DriverLicenseModel copyWith({
    String? numero,
    DateTime? fechaExpedicion,
    DateTime? fechaVencimiento,
    LicenseCategory? categoria,
    String? foto,
    String? fotoReverso,
    bool? isVerified,
  }) {
    return DriverLicenseModel(
      numero: numero ?? this.numero,
      fechaExpedicion: fechaExpedicion ?? this.fechaExpedicion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      categoria: categoria ?? this.categoria,
      foto: foto ?? this.foto,
      fotoReverso: fotoReverso ?? this.fotoReverso,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Categorías de licencia de conducción en Colombia
enum LicenseCategory {
  ninguna('ninguna', 'Ninguna', ''),
  a1('A1', 'A1', 'Motocicletas hasta 125cc'),
  a2('A2', 'A2', 'Motocicletas superior a 125cc'),
  b1('B1', 'B1', 'Automóviles, motocarros, cuatrimotor y camperos'),
  b2('B2', 'B2', 'Camionetas y microbuses'),
  b3('B3', 'B3', 'Camiones rígidos, busetas y buses'),
  c1('C1', 'C1', 'Automóviles, camperos (Servicio público)'),
  c2('C2', 'C2', 'Camionetas, microbuses (Servicio público)'),
  c3('C3', 'C3', 'Camiones, buses (Servicio público)');

  final String value;
  final String label;
  final String description;

  const LicenseCategory(this.value, this.label, this.description);

  static LicenseCategory fromString(String value) {
    return LicenseCategory.values.firstWhere(
      (cat) => cat.value.toLowerCase() == value.toLowerCase(),
      orElse: () => LicenseCategory.ninguna,
    );
  }
}
