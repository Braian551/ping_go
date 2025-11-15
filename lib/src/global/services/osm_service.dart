// lib/src/global/services/osm_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../core/config/env_config.dart';
import '../../core/constants/app_constants.dart';

/// Servicio para interactuar con APIs de OpenStreetMap (gratuitas)
class OsmService {
  /// Buscar lugares usando Nominatim
  static Future<List<OsmPlace>> searchPlaces(String query, {
    double? lat,
    double? lon,
    int limit = 5,
  }) async {
    try {
      final params = {
        'q': query,
        'format': 'json',
        'limit': limit.toString(),
        'addressdetails': '1',
        'extratags': '1',
        'countrycodes': 'co', // Limitar búsqueda a Colombia
      };

      if (lat != null && lon != null) {
        // Usar viewbox más amplio para Colombia si no hay coordenadas específicas
        // Coordenadas aproximadas de Colombia: -79.0 a -66.8 longitud, -4.2 a 12.5 latitud
        params['viewbox'] = '${lon - 0.5},${lat + 0.5},${lon + 0.5},${lat - 0.5}';
        params['bounded'] = '1'; // Limitar resultados al viewbox
      } else {
        // Si no hay coordenadas, usar viewbox de toda Colombia
        params['viewbox'] = '-79.0,12.5,-66.8,-4.2';
        params['bounded'] = '1';
      }

      final uri = Uri.parse(AppConstants.nominatimUrl).replace(
        path: '/search',
        queryParameters: params,
      );

      final response = await http.get(uri, headers: {
        'User-Agent': EnvConfig.nominatimUserAgent,
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((item) => OsmPlace.fromJson(item)).toList();
      }

      return [];
    } catch (e) {
      print('Error buscando lugares: $e');
      return [];
    }
  }

  /// Geocodificación inversa usando Nominatim
  static Future<OsmPlace?> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse(AppConstants.nominatimUrl).replace(
        path: '/reverse',
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'addressdetails': '1',
          'extratags': '1',
          'countrycodes': 'co', // Limitar a Colombia
        },
      );

      final response = await http.get(uri, headers: {
        'User-Agent': EnvConfig.nominatimUserAgent,
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return OsmPlace.fromJson(data);
        }
      }

      return null;
    } catch (e) {
      print('Error en geocodificación inversa: $e');
      return null;
    }
  }

  /// Obtener URL de tile para OpenStreetMap
  static String getTileUrl() {
    return AppConstants.osmTileUrl;
  }

  /// Calcular ruta usando OSRM (Open Source Routing Machine)
  static Future<OsmRoute?> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    try {
      // Construir coordenadas para OSRM: lon,lat;lon,lat
      final coordinates = waypoints.map((point) => '${point.longitude},${point.latitude}').join(';');
      
      final uri = Uri.parse('http://router.project-osrm.org/route/v1/driving/$coordinates').replace(
        queryParameters: {
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'false',
        },
      );

      final response = await http.get(uri, headers: {
        'User-Agent': EnvConfig.nominatimUserAgent,
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return OsmRoute.fromJson(data['routes'][0]);
        }
      }

      return null;
    } catch (e) {
      print('Error calculando ruta: $e');
      return null;
    }
  }
}

/// Modelo para lugares de OpenStreetMap
class OsmPlace {
  final String displayName;
  final double lat;
  final double lon;
  final Map<String, dynamic> address;

  OsmPlace({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.address,
  });

  factory OsmPlace.fromJson(Map<String, dynamic> json) {
    return OsmPlace(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      address: json['address'] ?? {},
    );
  }

  String get shortName {
    final city = address['city'] ?? address['town'] ?? address['village'];
    final country = address['country'];
    if (city != null && country != null) {
      return '$city, $country';
    }
    return displayName.split(',')[0];
  }
}

/// Modelo para rutas de OSRM
class OsmRoute {
  final List<LatLng> geometry;
  final double distanceKm;
  final int durationMinutes;

  OsmRoute({
    required this.geometry,
    required this.distanceKm,
    required this.durationMinutes,
  });

  factory OsmRoute.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['coordinates'] as List?;
    final List<LatLng> points = [];
    
    if (geometry != null) {
      for (var coord in geometry) {
        if (coord is List && coord.length >= 2) {
          points.add(LatLng(coord[1], coord[0])); // OSRM usa [lon, lat]
        }
      }
    }

    return OsmRoute(
      geometry: points,
      distanceKm: (json['distance'] ?? 0) / 1000.0, // metros a km
      durationMinutes: ((json['duration'] ?? 0) / 60).ceil(), // segundos a minutos
    );
  }
}