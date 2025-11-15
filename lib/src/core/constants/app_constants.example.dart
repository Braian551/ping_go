// lib/src/core/constants/app_constants.example.dart
// 
// ARCHIVO DE EJEMPLO - COPIA ESTE ARCHIVO A app_constants.dart
// Y REEMPLAZA LOS VALORES CON TUS CONFIGURACIONES REALES

class AppConstants {
  // Configuración de Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  
  // Configuración del servicio de email (Backend PHP con Google SMTP)
  static const String emailApiUrl = 'https://tu-servidor.com/backend/email_service.php';
  static const String emailLocalUrl = 'http://localhost/backend/email_service.php';
  
  // Configuración para desarrollo
  static const bool useEmailMock = false; // Cambia a true para usar mock en desarrollo
  
  // Configuración de la base de datos
  static const String databaseHost = 'localhost';
  static const String databasePort = '3306';
  static const String databaseName = 'pingo';
  static const String databaseUser = 'root';
  static const String databasePassword = '';
  
  // Configuración de la aplicación
  static const String appName = 'PingGo';
  static const String appVersion = '1.0.0';
  
  // URLs de la API
  static const String baseApiUrl = 'https://api.pingo.com';
  
  // Configuración de mapas
  static const double defaultLatitude = 4.6097; // Bogotá, Colombia
  static const double defaultLongitude = -74.0817;
  static const double defaultZoom = 15.0;
  
  // Configuración de validación
  static const int minPasswordLength = 6;
  static const int minPhoneLength = 10;
  static const int verificationCodeLength = 6;
  static const int resendCodeDelaySeconds = 60;
}
