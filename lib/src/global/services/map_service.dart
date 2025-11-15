import 'package:latlong2/latlong.dart';

class MapService {
  static const double defaultZoom = 15.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 10.0;

  /// Calcular distancia entre dos puntos (en metros)
  static double calculateDistance(LatLng point1, LatLng point2) {
    final Distance distance = Distance();
    return distance(point1, point2);
  }

  /// Validar coordenadas
  static bool isValidCoordinate(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  /// Obtener URL de tile para OpenStreetMap
  static String getTileUrl(int x, int y, int zoom) {
    return 'https://tile.openstreetmap.org/$zoom/$x/$y.png';
  }

  /// Obtener URL de tile alternativo (CartoDB)
  static String getCartoDBTileUrl(int x, int y, int zoom) {
    return 'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/$zoom/$x/$y.png';
  }
}