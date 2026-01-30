import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import 'package:ping_go/src/routes/route_names.dart';

class ConductorProfileView extends StatelessWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorProfileView({super.key, required this.conductorUser});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileMenu(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFF00).withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    (conductorUser['nombre'] ?? 'C')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFFFF00),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${conductorUser['nombre']} ${conductorUser['apellido'] ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                conductorUser['email'] ?? '',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(context, Icons.person_outline_rounded, 'Editar Perfil', () {}),
        const SizedBox(height: 12),
        _buildMenuItem(context, Icons.history_rounded, 'Historial de Viajes', () {}),
        const SizedBox(height: 12),
         _buildMenuItem(context, Icons.attach_money_rounded, 'Información de Pago', () {}),
        const SizedBox(height: 12),
        _buildMenuItem(context, Icons.settings_outlined, 'Configuración', () {}),
        const SizedBox(height: 12),
        _buildMenuItem(context, Icons.help_outline_rounded, 'Ayuda y Soporte', () {}),
        const SizedBox(height: 24),
        _buildMenuItem(
          context, 
          Icons.logout_rounded, 
          'Cerrar Sesión', 
          () => _handleLogout(context),
          isLogout: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    VoidCallback onTap, 
    {bool isLogout = false}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLogout 
                  ? Colors.red.withOpacity(0.1) 
                  : const Color(0xFF1A1A1A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLogout 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.2)
                        : const Color(0xFFFFFF00).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon, 
                    color: isLogout 
                        ? Colors.red 
                        : const Color(0xFFFFFF00), 
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLogout ? Colors.red : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded, 
                  color: isLogout 
                      ? Colors.red.withOpacity(0.5) 
                      : Colors.white.withOpacity(0.3), 
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: Colors.red, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Estás seguro de que deseas salir?',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Salir', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (shouldLogout == true) {
      await UserService.clearSession();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, RouteNames.welcome, (route) => false);
      }
    }
  }
}
