// lib/src/widgets/dialogs/dialogs_example_screen.dart
// Esta pantalla es solo para demostración y pruebas
// No es necesaria para el funcionamiento de la app

import 'package:flutter/material.dart';
import 'dialog_helper.dart';
import '../snackbars/custom_snackbar.dart';

class DialogsExampleScreen extends StatelessWidget {
  const DialogsExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ejemplos de Alertas'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Diálogos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Diálogo de éxito
            ElevatedButton(
              onPressed: () {
                DialogHelper.showSuccess(
                  context,
                  title: '¡Registro Exitoso!',
                  message: 'Tu cuenta ha sido creada correctamente y ya puedes comenzar a usar la aplicación.',
                  primaryButtonText: 'Continuar',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Diálogo de Éxito'),
            ),

            const SizedBox(height: 12),

            // Diálogo de error
            ElevatedButton(
              onPressed: () {
                DialogHelper.showError(
                  context,
                  title: 'Código Incorrecto',
                  message: 'El código de verificación que ingresaste no es válido. Por favor, verifica e intenta nuevamente.',
                  primaryButtonText: 'Reintentar',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Diálogo de Error'),
            ),

            const SizedBox(height: 12),

            // Diálogo de advertencia
            ElevatedButton(
              onPressed: () {
                DialogHelper.showWarning(
                  context,
                  title: 'Acción Irreversible',
                  message: 'Esta acción no se puede deshacer. ¿Estás seguro de que deseas continuar?',
                  primaryButtonText: 'Continuar',
                  secondaryButtonText: 'Cancelar',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Diálogo de Advertencia'),
            ),

            const SizedBox(height: 12),

            // Diálogo informativo
            ElevatedButton(
              onPressed: () {
                DialogHelper.showInfo(
                  context,
                  title: 'Información Importante',
                  message: 'Tu ubicación será utilizada para brindarte un mejor servicio y mostrarte las opciones más cercanas.',
                  primaryButtonText: 'Entendido',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFF00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Diálogo Informativo'),
            ),

            const SizedBox(height: 12),

            // Diálogo de confirmación
            ElevatedButton(
              onPressed: () async {
                final result = await DialogHelper.showConfirmation(
                  context,
                  title: '¿Eliminar Cuenta?',
                  message: '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es permanente.',
                  confirmText: 'Eliminar',
                  cancelText: 'Cancelar',
                );

                if (result == true && context.mounted) {
                  CustomSnackbar.showSuccess(
                    context,
                    message: 'Acción confirmada',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Diálogo de Confirmación'),
            ),

            const SizedBox(height: 32),

            const Text(
              'Snackbars',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Snackbar de éxito
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.showSuccess(
                  context,
                  message: '¡Correo verificado exitosamente!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Snackbar de Éxito'),
            ),

            const SizedBox(height: 12),

            // Snackbar de error
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.showError(
                  context,
                  message: 'No se pudo conectar al servidor',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Snackbar de Error'),
            ),

            const SizedBox(height: 12),

            // Snackbar de advertencia
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.showWarning(
                  context,
                  message: 'Por favor, completa todos los campos requeridos',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Snackbar de Advertencia'),
            ),

            const SizedBox(height: 12),

            // Snackbar informativo
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.showInfo(
                  context,
                  message: 'Cargando información del perfil...',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFF00),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Snackbar Informativo'),
            ),

            const SizedBox(height: 12),

            // Snackbar con acción
            ElevatedButton(
              onPressed: () {
                CustomSnackbar.showError(
                  context,
                  message: 'Error al guardar los cambios',
                  actionLabel: 'REINTENTAR',
                  onAction: () {
                    CustomSnackbar.showInfo(
                      context,
                      message: 'Reintentando...',
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mostrar Snackbar con Acción'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
