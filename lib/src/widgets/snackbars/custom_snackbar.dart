// lib/src/widgets/snackbars/custom_snackbar.dart
import 'package:flutter/material.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class CustomSnackbar {
  /// Muestra un snackbar personalizado
  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _getSnackbarConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                color: config.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Mensaje
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: config.borderColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: 8,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: config.actionColor,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  /// Muestra un snackbar de éxito
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Muestra un snackbar de error
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Muestra un snackbar de advertencia
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Muestra un snackbar informativo
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static _SnackbarConfig _getSnackbarConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          icon: Icons.check_circle,
          iconColor: const Color(0xFF4CAF50),
          iconBackgroundColor: const Color(0xFF4CAF50).withOpacity(0.2),
          borderColor: const Color(0xFF4CAF50),
          actionColor: const Color(0xFF4CAF50),
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error,
          iconColor: const Color(0xFFFF5252),
          iconBackgroundColor: const Color(0xFFFF5252).withOpacity(0.2),
          borderColor: const Color(0xFFFF5252),
          actionColor: const Color(0xFFFF5252),
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning,
          iconColor: const Color(0xFFFFA726),
          iconBackgroundColor: const Color(0xFFFFA726).withOpacity(0.2),
          borderColor: const Color(0xFFFFA726),
          actionColor: const Color(0xFFFFA726),
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info,
          iconColor: const Color(0xFFFFFF00),
          iconBackgroundColor: const Color(0xFFFFFF00).withOpacity(0.2),
          borderColor: const Color(0xFFFFFF00),
          actionColor: const Color(0xFFFFFF00),
        );
    }
  }
}

class _SnackbarConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color borderColor;
  final Color actionColor;

  _SnackbarConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.borderColor,
    required this.actionColor,
  });
}
