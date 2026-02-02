import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/routes/route_names.dart';

class AdminManagementTab extends StatefulWidget {
  final Map<String, dynamic> adminUser;

  const AdminManagementTab({
    super.key,
    required this.adminUser,
  });

  @override
  State<AdminManagementTab> createState() => _AdminManagementTabState();
}

class _AdminManagementTabState extends State<AdminManagementTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final adminId = int.tryParse(widget.adminUser['id']?.toString() ?? '0') ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Gestión del sistema',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra todos los aspectos de la plataforma',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          _buildSection(
            title: 'Usuarios',
            items: [
              _ManagementItem(
                title: 'Gestión de Usuarios',
                subtitle: 'Ver, editar y administrar todos los usuarios',
                icon: Icons.people_outline_rounded,
                accentColor: const Color(0xFF667eea),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.adminUsers,
                    arguments: {'admin_id': adminId, 'admin_user': widget.adminUser},
                  );
                },
              ),
              _ManagementItem(
                title: 'Solicitudes Pendientes',
                subtitle: 'Revisar y aprobar nuevos conductores',
                icon: Icons.checklist_rtl_rounded,
                accentColor: const Color(0xFFFFFF00),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.adminPendingDrivers,
                    arguments: {'adminId': adminId},
                  );
                },
              ),
              _ManagementItem(
                title: 'Cobro de Comisiones',
                subtitle: 'Gestionar deudas y pagos de conductores',
                icon: Icons.payments_rounded,
                accentColor: const Color(0xFF00C853),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.adminCommissions);
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSection(
            title: 'Configuración y Tarifas',
            items: [
              _ManagementItem(
                title: 'Tarifas y Comisiones',
                subtitle: 'Gestionar precios y comisiones en COP',
                icon: Icons.attach_money_rounded,
                accentColor: const Color(0xFFFFFF00),
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.adminRates);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<_ManagementItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildManagementCard(item),
        )),
      ],
    );
  }

  Widget _buildManagementCard(_ManagementItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: item.accentColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20),
                splashColor: item.accentColor.withOpacity(0.1),
                highlightColor: item.accentColor.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: item.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.accentColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(item.icon, color: item.accentColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withOpacity(0.4),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Función en desarrollo'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ManagementItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  _ManagementItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });
}
