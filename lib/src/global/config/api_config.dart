import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Para emulador Android: usar 10.0.2.2
  // Para navegador: usar localhost
  // Si usas Laragon el proyecto debe apuntar a: http://<host>/ping_go/backend-deploy
  // Para el emulador Android: usar 10.0.2.2
  // Para un dispositivo físico o WSL, usa la IP de tu máquina (e.g. 192.168.1.10)
  static String get baseUrl {
    final ip = dotenv.env['SERVER_IP'] ?? '10.0.2.2';
    return 'http://$ip/ping_go/backend-deploy';
  }


  // Endpoints principales
  static String get authEndpoint => '$baseUrl/auth';
  static String get userEndpoint => '$baseUrl/user';
  static String get conductorEndpoint => '$baseUrl/conductor';
  static String get adminEndpoint => '$baseUrl/admin';

  // Endpoint helper usado por el proveedor de DB para verificar la conexión
  static String get verifySystemUrl => '$baseUrl/verify_system_json.php';

  // Configuración de timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
