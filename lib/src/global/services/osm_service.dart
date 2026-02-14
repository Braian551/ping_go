// lib/src/global/services/osm_service.dart
import 'dart:async';
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
        params['viewbox'] = '${lon - 0.5},${lat + 0.5},${lon + 0.5},${lat - 0.5}';
        params['bounded'] = '1';
      } else {
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
          'countrycodes': 'co',
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
    return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';
  }

  /// Calcular ruta usando OSRM (Open Source Routing Machine)
  static Future<OsmRoute?> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    final coordinates = waypoints.map((point) => '${point.longitude},${point.latitude}').join(';');
    
    // Lista de end-points para probar (Fallback strategy)
    final endpoints = [
      'https://router.project-osrm.org/route/v1/driving',  // Primary (HTTPS)
      'http://router.project-osrm.org/route/v1/driving',   // Fallback HTTP
      'https://routing.openstreetmap.de/routed-car/route/v1/driving', // Alternative server
    ];

    for (final baseUrl in endpoints) {
      try {
        final uri = Uri.parse('$baseUrl/$coordinates').replace(
          queryParameters: {
            'overview': 'full',
            'geometries': 'geojson',
            'steps': 'false',
          },
        );

        print('Calculating route: $uri');

        final response = await http.get(uri, headers: {
          'User-Agent': EnvConfig.nominatimUserAgent,
          'Accept': 'application/json',
        }).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['routes'] != null && data['routes'].isNotEmpty) {
            return OsmRoute.fromJson(data['routes'][0]);
          }
        }
      } catch (e) {
        print('Error calculating route with $baseUrl: $e');
        // Continue to next endpoint
      }
    }

    return null;
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
      distanceKm: (json['distance'] ?? 0) / 1000.0,
      durationMinutes: ((json['duration'] ?? 0) / 60).ceil(),
    );
  }
}
