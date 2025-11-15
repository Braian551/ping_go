import 'package:shared_preferences/shared_preferences.dart';

/// Script de utilidad para resetear el estado de notificaciones de aprobación
/// Útil durante el desarrollo y testing
class DebugApprovalReset {
  /// Resetea el estado de notificación para un conductor específico
  static Future<void> resetForConductor(int conductorId) async {
    final prefs = await SharedPreferences.getInstance();
    
    final shownKey = 'conductor_approval_shown_$conductorId';
    final statusKey = 'conductor_last_status_$conductorId';
    
    await prefs.remove(shownKey);
    await prefs.remove(statusKey);
    
    print('✅ Estado reseteado para conductor $conductorId');
    print('   - $shownKey: eliminado');
    print('   - $statusKey: eliminado');
    print('');
    print('💡 Reinicia la app o recarga el home para ver la alerta nuevamente.');
  }

  /// Resetea el estado para todos los conductores
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    int removedCount = 0;
    for (var key in keys) {
      if (key.startsWith('conductor_approval_') || 
          key.startsWith('conductor_last_status_')) {
        await prefs.remove(key);
        removedCount++;
        print('   - $key: eliminado');
      }
    }
    
    print('');
    print('✅ $removedCount claves eliminadas');
    print('💡 Reinicia la app para ver las alertas nuevamente.');
  }

  /// Muestra el estado actual de notificaciones
  static Future<void> showStatus(int conductorId) async {
    final prefs = await SharedPreferences.getInstance();
    
    final shownKey = 'conductor_approval_shown_$conductorId';
    final statusKey = 'conductor_last_status_$conductorId';
    
    final hasShown = prefs.getBool(shownKey) ?? false;
    final lastStatus = prefs.getString(statusKey);
    
    print('📊 Estado actual para conductor $conductorId:');
    print('   - Alerta ya mostrada: $hasShown');
    print('   - Último estado guardado: ${lastStatus ?? "ninguno"}');
  }
}
