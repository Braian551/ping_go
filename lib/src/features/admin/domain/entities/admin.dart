/// Entidad de Dominio: Admin
class Admin {
  final int id;
  final String nombre;
  final String email;
  final AdminRole role;
  final bool activo;

  const Admin({
    required this.id,
    required this.nombre,
    required this.email,
    required this.role,
    required this.activo,
  });
}

enum AdminRole {
  superAdmin('Super Admin'),
  admin('Admin'),
  moderador('Moderador');

  final String displayName;
  const AdminRole(this.displayName);
}

/// Estadísticas del sistema
class SystemStats {
  final int totalUsuarios;
  final int totalConductores;
  final int conductoresPendientes;
  final int viajesHoy;
  final int viajesTotal;
  final double gananciaHoy;
  final double gananciaTotal;

  const SystemStats({
    required this.totalUsuarios,
    required this.totalConductores,
    required this.conductoresPendientes,
    required this.viajesHoy,
    required this.viajesTotal,
    required this.gananciaHoy,
    required this.gananciaTotal,
  });
}
