class ApiConfig {
  // Para emulador Android: usar 10.0.2.2
  // Para navegador: usar localhost
  // Si usas Laragon el proyecto debe apuntar a: http://<host>/ping_go/backend-deploy
  // Para el emulador Android: usar 10.0.2.2
  // Para un dispositivo físico o WSL, usa la IP de tu máquina (e.g. 192.168.1.10)
  static const String baseUrl = 'http://10.0.2.2/ping_go/backend-deploy';


  // Endpoints principales
  static const String authEndpoint = '$baseUrl/auth';
  static const String userEndpoint = '$baseUrl/user';
  static const String conductorEndpoint = '$baseUrl/conductor';
  static const String adminEndpoint = '$baseUrl/admin';

  // Endpoint helper usado por el proveedor de DB para verificar la conexión
  static const String verifySystemUrl = '$baseUrl/verify_system_json.php';

  // Configuración de timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
