import 'package:flutter/material.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
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
  late Map<String, dynamic> _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.conductorUser;
    // Force refresh to get latest data (including profile image if not in session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
    });
  }

  Future<void> _refreshUserData() async {
    try {
      final sess = await UserService.getSavedSession();
      if (sess != null) {
        final userId = sess['id'] as int?;
        final email = sess['email'] as String?;
        if (userId != null) {
          final profile = await UserService.getProfile(userId: userId, email: email);
          if (profile != null && profile['success'] == true) {
            if (mounted) {
              setState(() {
                _currentUser = profile['user'];
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: ConductorAppBar(conductorUser: _currentUser),
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
        return ConductorDashboardView(key: const ValueKey(0), conductorUser: _currentUser);
      case 1:
        return const ConductorMapView(key: ValueKey(1));
      case 2:
        return ConductorHistoryView(key: const ValueKey(2), conductorUser: _currentUser);
      case 3:
        return ConductorProfileView(
          key: const ValueKey(3), 
          conductorUser: _currentUser,
          onProfileUpdate: _refreshUserData,
        );
      default:
        return ConductorDashboardView(key: const ValueKey(0), conductorUser: _currentUser);
    }
  }
}