import 'package:flutter/material.dart';
import 'statistics_screen.dart';

/// Wrapper para la pantalla de estadísticas para uso con el tab de admin
class AdminStatisticsScreen extends StatelessWidget {
  final Map<String, dynamic> adminUser;

  const AdminStatisticsScreen({
    super.key,
    required this.adminUser,
  });

  @override
  Widget build(BuildContext context) {
    final adminId = int.tryParse(adminUser['id']?.toString() ?? '0') ?? 0;
    
    return StatisticsScreen(adminId: adminId);
  }
}
