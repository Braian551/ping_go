import 'dart:ui';
import 'package:flutter/material.dart';

/// Pantalla de configuración y ajustes del usuario
/// Incluye notificaciones, privacidad, idioma, etc.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationAlwaysOn = false;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _promotionalEmails = true;
  String _selectedLanguage = 'Español';
  String _selectedTheme = 'Oscuro';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Notificaciones', [
                      _buildSwitchTile(
                        icon: Icons.notifications_active,
                        title: 'Notificaciones push',
                        subtitle: 'Recibir alertas en tiempo real',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.email_outlined,
                        title: 'Notificaciones por correo',
                        subtitle: 'Recibir actualizaciones por email',
                        value: _emailNotifications,
                        onChanged: (value) {
                          setState(() => _emailNotifications = value);
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.sms_outlined,
                        title: 'Notificaciones por SMS',
                        subtitle: 'Recibir mensajes de texto',
                        value: _smsNotifications,
                        onChanged: (value) {
                          setState(() => _smsNotifications = value);
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.local_offer_outlined,
                        title: 'Promociones y ofertas',
                        subtitle: 'Recibir descuentos exclusivos',
                        value: _promotionalEmails,
                        onChanged: (value) {
                          setState(() => _promotionalEmails = value);
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Privacidad y seguridad', [
                      _buildSwitchTile(
                        icon: Icons.location_on_outlined,
                        title: 'Ubicación siempre activa',
                        subtitle: 'Permitir acceso continuo a ubicación',
                        value: _locationAlwaysOn,
                        onChanged: (value) {
                          setState(() => _locationAlwaysOn = value);
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.lock_outline,
                        title: 'Cambiar contraseña',
                        subtitle: 'Actualizar tu contraseña',
                        onTap: () {
                          _showChangePasswordDialog();
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Autenticación de dos factores',
                        subtitle: 'Agregar capa adicional de seguridad',
                        onTap: () {
                          _showComingSoon('Autenticación de dos factores');
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.phone_android_outlined,
                        title: 'Dispositivos autorizados',
                        subtitle: 'Gestionar dispositivos con acceso',
                        onTap: () {
                          _showComingSoon('Dispositivos autorizados');
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Preferencias', [
                      _buildSelectionTile(
                        icon: Icons.language,
                        title: 'Idioma',
                        subtitle: _selectedLanguage,
                        onTap: () {
                          _showLanguageSelector();
                        },
                      ),
                      _buildSelectionTile(
                        icon: Icons.palette_outlined,
                        title: 'Tema',
                        subtitle: _selectedTheme,
                        onTap: () {
                          _showThemeSelector();
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.volume_up_outlined,
                        title: 'Sonidos',
                        subtitle: 'Gestionar sonidos de la app',
                        onTap: () {
                          _showComingSoon('Sonidos');
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Legal', [
                      _buildNavigationTile(
                        icon: Icons.description_outlined,
                        title: 'Términos y condiciones',
                        subtitle: 'Leer los términos de uso',
                        onTap: () {
                          Navigator.pushNamed(context, '/terms');
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Política de privacidad',
                        subtitle: 'Cómo usamos tu información',
                        onTap: () {
                          Navigator.pushNamed(context, '/privacy');
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.gavel_outlined,
                        title: 'Licencias de código abierto',
                        subtitle: 'Software de terceros',
                        onTap: () {
                          _showComingSoon('Licencias');
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Soporte', [
                      _buildNavigationTile(
                        icon: Icons.help_outline,
                        title: 'Centro de ayuda',
                        subtitle: 'Encuentra respuestas a tus preguntas',
                        onTap: () {
                          Navigator.pushNamed(context, '/help');
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.chat_outlined,
                        title: 'Contactar soporte',
                        subtitle: 'Chatea con nuestro equipo',
                        onTap: () {
                          _showComingSoon('Soporte en vivo');
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.bug_report_outlined,
                        title: 'Reportar un problema',
                        subtitle: 'Ayúdanos a mejorar',
                        onTap: () {
                          _showBugReportDialog();
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSection('Cuenta', [
                      _buildNavigationTile(
                        icon: Icons.download_outlined,
                        title: 'Descargar mis datos',
                        subtitle: 'Obtener copia de tu información',
                        onTap: () {
                          _showComingSoon('Descarga de datos');
                        },
                      ),
                      _buildNavigationTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Eliminar cuenta',
                        subtitle: 'Cerrar permanentemente tu cuenta',
                        color: Colors.red,
                        onTap: () {
                          _showDeleteAccountDialog();
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'PingGo v1.0.0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© 2024 PingGo. Todos los derechos reservados',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Configuración',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFFF00),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFF00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFFFFF00), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFFFFFF00),
                  activeTrackColor: const Color(0xFFFFFF00).withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? const Color(0xFFFFFF00);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tileColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: tileColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: color ?? Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.3),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _buildNavigationTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar idioma',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption('Español'),
            _buildLanguageOption('English'),
            _buildLanguageOption('Português'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedLanguage = language);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFFF00).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFFF00)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFFF00) : Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFFFFFF00)),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar tema',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildThemeOption('Oscuro'),
            _buildThemeOption('Claro'),
            _buildThemeOption('Sistema'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme) {
    final isSelected = _selectedTheme == theme;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTheme = theme);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFFF00).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFFF00)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                theme,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFFFFF00) : Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFFFFFF00)),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Cambiar contraseña',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta funcionalidad estará disponible próximamente.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFFFFFF00)),
            ),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Reportar problema',
          style: TextStyle(color: Colors.white),
        ),
        content: const TextField(
          style: TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe el problema...',
            hintStyle: TextStyle(color: Colors.white30),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reporte enviado. Gracias por tu ayuda!'),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Enviar',
              style: TextStyle(color: Color(0xFFFFFF00)),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar cuenta',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar lógica de eliminación
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
