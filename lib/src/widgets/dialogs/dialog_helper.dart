// lib/src/widgets/dialogs/dialog_helper.dart
import 'package:flutter/material.dart';
import 'custom_dialog.dart';

class DialogHelper {
  /// Muestra un diálogo de éxito
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String primaryButtonText = 'Entendido',
    VoidCallback? onPrimaryPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        type: DialogType.success,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Muestra un diálogo de error
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String primaryButtonText = 'Entendido',
    VoidCallback? onPrimaryPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        type: DialogType.error,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Muestra un diálogo de advertencia
  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
    String primaryButtonText = 'Entendido',
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        type: DialogType.warning,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Muestra un diálogo informativo
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String primaryButtonText = 'Entendido',
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool barrierDismissible = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        type: DialogType.info,
        title: title,
        message: message,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Muestra un diálogo de confirmación
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    DialogType type = DialogType.warning,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        type: type,
        title: title,
        message: message,
        primaryButtonText: confirmText,
        secondaryButtonText: cancelText,
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        onSecondaryPressed: () => Navigator.of(context).pop(false),
        barrierDismissible: barrierDismissible,
      ),
    );
  }
}
