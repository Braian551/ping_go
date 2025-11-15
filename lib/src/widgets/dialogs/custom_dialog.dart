// lib/src/widgets/dialogs/custom_dialog.dart
import 'package:flutter/material.dart';

enum DialogType {
  success,
  error,
  warning,
  info,
}

class CustomDialog extends StatelessWidget {
  final DialogType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? customIcon;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.customIcon,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getDialogConfig();
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: config.borderColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: config.glowColor.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con icono
            Container(
              padding: const EdgeInsets.only(top: 32, bottom: 20),
              child: Column(
                children: [
                  // Icono con efecto de glow
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          config.glowColor.withOpacity(0.2),
                          config.glowColor.withOpacity(0.05),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                    child: Center(
                      child: customIcon ??
                          Icon(
                            config.icon,
                            size: 38,
                            color: config.iconColor,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Título
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: config.titleColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Mensaje
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white70,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botones
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  // Botón primario
                  if (primaryButtonText != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: onPrimaryPressed ??
                            () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: config.primaryButtonColor,
                          foregroundColor: config.primaryButtonTextColor,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          primaryButtonText!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                  // Botón secundario
                  if (secondaryButtonText != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: onSecondaryPressed ??
                            () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          secondaryButtonText!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _DialogConfig _getDialogConfig() {
    switch (type) {
      case DialogType.success:
        return _DialogConfig(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF4CAF50),
          titleColor: const Color(0xFF4CAF50),
          borderColor: const Color(0xFF4CAF50),
          glowColor: const Color(0xFF4CAF50),
          primaryButtonColor: const Color(0xFF4CAF50),
          primaryButtonTextColor: Colors.black,
        );
      case DialogType.error:
        return _DialogConfig(
          icon: Icons.error_outline,
          iconColor: const Color(0xFFFF5252),
          titleColor: const Color(0xFFFF5252),
          borderColor: const Color(0xFFFF5252),
          glowColor: const Color(0xFFFF5252),
          primaryButtonColor: const Color(0xFFFF5252),
          primaryButtonTextColor: Colors.white,
        );
      case DialogType.warning:
        return _DialogConfig(
          icon: Icons.warning_amber_outlined,
          iconColor: const Color(0xFFFFA726),
          titleColor: const Color(0xFFFFA726),
          borderColor: const Color(0xFFFFA726),
          glowColor: const Color(0xFFFFA726),
          primaryButtonColor: const Color(0xFFFFA726),
          primaryButtonTextColor: Colors.black,
        );
      case DialogType.info:
        return _DialogConfig(
          icon: Icons.info_outline,
          iconColor: const Color(0xFFFFFF00),
          titleColor: const Color(0xFFFFFF00),
          borderColor: const Color(0xFFFFFF00),
          glowColor: const Color(0xFFFFFF00),
          primaryButtonColor: const Color(0xFFFFFF00),
          primaryButtonTextColor: Colors.black,
        );
    }
  }
}

class _DialogConfig {
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final Color borderColor;
  final Color glowColor;
  final Color primaryButtonColor;
  final Color primaryButtonTextColor;

  _DialogConfig({
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.borderColor,
    required this.glowColor,
    required this.primaryButtonColor,
    required this.primaryButtonTextColor,
  });
}
