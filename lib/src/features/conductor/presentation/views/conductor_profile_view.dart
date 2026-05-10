import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/core/config/app_config.dart';
import 'package:ping_go/src/features/user/presentation/screens/edit_profile_screen.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import 'package:ping_go/src/routes/route_names.dart';
import 'package:ping_go/src/features/conductor/presentation/screens/conductor_earnings_screen.dart';
import 'package:ping_go/src/features/conductor/presentation/screens/commission_payment_screen.dart';
import 'package:ping_go/src/features/shared/widgets/profile_shared_widgets.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';

class ConductorProfileView extends StatelessWidget {
  final Map<String, dynamic> conductorUser;
  final VoidCallback? onProfileUpdate;

  const ConductorProfileView({
    super.key, 
    required this.conductorUser,
    this.onProfileUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(context),
          const SizedBox(height: 24),
          _buildProfileMenu(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return ProfileHeaderCard(
      name: '${conductorUser['nombre']} ${conductorUser['apellido'] ?? ''}',
      email: conductorUser['email'],
      imageUrl: conductorUser['url_imagen_perfil'],
      rating: double.tryParse(conductorUser['calificacion_promedio']?.toString() ?? '5.0') ?? 5.0,
      totalRatings: int.tryParse(conductorUser['total_calificaciones']?.toString() ?? '0') ?? 0,
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.person_outline_rounded,
          title: 'Editar Perfil',
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(user: conductorUser),
              ),
            );
            if (result == true && onProfileUpdate != null) {
              onProfileUpdate!();
            }
          },
        ),
        ProfileMenuItem(
          icon: Icons.history_rounded,
          title: 'Historial de Viajes',
          onTap: () {},
        ),
        ProfileMenuItem(
          icon: Icons.attach_money_rounded,
          title: 'Información de Pago',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConductorEarningsScreen(conductorUser: conductorUser),
              ),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.receipt_long_rounded,
          title: 'Pagar Comisión',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommissionPaymentScreen(conductorUser: conductorUser),
              ),
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.settings_outlined,
          title: 'Configuración',
          onTap: () {
            CustomSnackbar.showInfo(context, message: 'Función en desarrollo');
          },
        ),
        ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          title: 'Ayuda y Soporte',
          onTap: () {
            CustomSnackbar.showInfo(context, message: 'Función en desarrollo');
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.logout_rounded,
          title: 'Cerrar Sesión',
          isLogout: true,
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await ProfileLogoutDialog.show(context);

    if (shouldLogout == true) {
      await UserService.clearSession();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, RouteNames.welcome, (route) => false);
      }
    }
  }
}
