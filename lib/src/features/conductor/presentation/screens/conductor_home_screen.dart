import 'package:flutter/material.dart';
import '../widgets/conductor_app_bar.dart';
import '../widgets/conductor_bottom_nav.dart';
import '../views/conductor_dashboard_view.dart';
import '../views/conductor_map_view.dart';
import '../views/conductor_history_view.dart';
import '../views/conductor_profile_view.dart';

class ConductorHomeScreen extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorHomeScreen({
    super.key,
    required this.conductorUser,
  });

  @override
  State<ConductorHomeScreen> createState() => _ConductorHomeScreenState();
}

class _ConductorHomeScreenState extends State<ConductorHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: ConductorAppBar(conductorUser: widget.conductorUser),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: ConductorBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    // Unique keys ensure animation works correctly when switching
    switch (_currentIndex) {
      case 0:
        return ConductorDashboardView(key: const ValueKey(0), conductorUser: widget.conductorUser);
      case 1:
        return const ConductorMapView(key: ValueKey(1));
      case 2:
        return const ConductorHistoryView(key: ValueKey(2));
      case 3:
        return ConductorProfileView(key: const ValueKey(3), conductorUser: widget.conductorUser);
      default:
        return ConductorDashboardView(key: const ValueKey(0), conductorUser: widget.conductorUser);
    }
  }
}