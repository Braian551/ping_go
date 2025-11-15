class AppConfig {
  static const Environment environment = Environment.development;

  // NOTE: keep this consistent with `ApiConfig.baseUrl` in `lib/src/global/config/api_config.dart`
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://10.0.2.2/ping_go/backend-deploy';
      case Environment.staging:
        return 'https://staging-api.pingo.com';
      case Environment.production:
        return 'https://api.pingo.com';
    }
  }

  static String get authServiceUrl => '$baseUrl/auth';
  static String get conductorServiceUrl => '$baseUrl/conductor';
  static String get adminServiceUrl => '$baseUrl/admin';

  static String get tripServiceUrl => '$baseUrl/viajes';
  static String get mapServiceUrl => '$baseUrl/map';

  @Deprecated('Usar authServiceUrl en su lugar')
  static String get userServiceUrl => authServiceUrl;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 50 * 1024 * 1024;

  static const bool enableOfflineMode = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  static const double defaultLatitude = 4.6097;
  static const double defaultLongitude = -74.0817;

  static const String appVersion = '1.0.0';
  static const String apiVersion = 'v1';
}

enum Environment {
  development,
  staging,
  production,
}

class FeatureConfig {
  static const userServiceConfig = {
    'endpoint': '/auth',
    'version': 'v1',
    'timeout': Duration(seconds: 15),
    'retryAttempts': 3,
    'enableCache': false,
  };

  static const conductorConfig = {
    'endpoint': '/conductor',
    'version': 'v1',
    'timeout': Duration(seconds: 15),
    'retryAttempts': 3,
  };

  static const authConfig = {
    'endpoint': '/auth',
    'version': 'v1',
    'timeout': Duration(seconds: 10),
    'tokenExpiration': Duration(hours: 24),
  };

  static const mapConfig = {
    'endpoint': '/map',
    'version': 'v1',
    'timeout': Duration(seconds: 20),
    'cacheEnabled': true,
  };
}
