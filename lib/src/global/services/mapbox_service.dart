// lib/src/global/services/mapbox_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../core/config/env_config.dart';
import 'quota_monitor_service.dart';

/// Servicio para interactuar con la API de Mapbox
/// Maneja mapas, rutas, geocoding y optimización de rutas
class MapboxService {
  static const String _baseUrl = 'https://api.mapbox.com';
  
  // ============================================
  // DIRECTIONS API (Rutas y Navegación)
  // ============================================
  
  /// Obtener ruta entre dos o más puntos usando Mapbox Directions API
  /// 
  /// [waypoints] - Lista de coordenadas (mínimo 2)
  /// [profile] - Tipo de transporte: driving, walking, cycling
  /// [alternatives] - Si es true, devuelve rutas alternativas
  /// [steps] - Si es true, incluye instrucciones paso a paso
  /// 
  /// Retorna [MapboxRoute] con la información de la ruta
  static Future<MapboxRoute?> getRoute({
    required List<LatLng> waypoints,
    String profile = 'driving', // driving, walking, cycling, driving-traffic
    bool alternatives = true,
    bool steps = true,
    bool geometries = true,
  }) async {
    try {
      if (waypoints.length < 2) {
        throw Exception('Se necesitan al menos 2 puntos para calcular una ruta');
      }

      // Construir string de coordenadas: "lng,lat;lng,lat;..."
      final coordinates = waypoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      // Construir URL
      final url = Uri.parse(
        '$_baseUrl/directions/v5/mapbox/$profile/$coordinates'
        '?alternatives=$alternatives'
        '&steps=$steps'
        '&geometries=geojson'
        '&overview=full'
        '&access_token=${EnvConfig.mapboxPublicToken}'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Incrementar contador de uso
        await QuotaMonitorService.incrementMapboxRouting();
        
        final data = json.decode(response.body);
        
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          return MapboxRoute.fromJson(data['routes'][0]);
        }
      } else {
        print('Error en Mapbox Directions: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      print('Error obteniendo ruta de Mapbox: $e');
      return null;
    }
  }

  /// Optimizar orden de múltiples waypoints para la ruta más eficiente
  /// Útil para delivery o múltiples paradas
  static Future<MapboxRoute?> getOptimizedRoute({
    required LatLng origin,
    required LatLng destination,
    required List<LatLng> waypoints,
    String profile = 'driving',
  }) async {
    try {
      // Construir lista completa: origin, waypoints, destination
      final allPoints = [origin, ...waypoints, destination];
      
      // Construir string de coordenadas
      final coordinates = allPoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      // El endpoint de optimización requiere indicar qué puntos son fijos
      final url = Uri.parse(
        '$_baseUrl/optimized-trips/v1/mapbox/$profile/$coordinates'
        '?source=first'      // Origen es el primer punto
        '&destination=last'  // Destino es el último punto
        '&roundtrip=false'   // No es un viaje circular
        '&steps=true'
        '&geometries=geojson'
        '&overview=full'
        '&access_token=${EnvConfig.mapboxPublicToken}'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await QuotaMonitorService.incrementMapboxRouting();
        
        final data = json.decode(response.body);
        
        if (data['trips'] != null && (data['trips'] as List).isNotEmpty) {
          return MapboxRoute.fromJson(data['trips'][0]);
        }
      }
      
      return null;
    } catch (e) {
      print('Error en ruta optimizada: $e');
      return null;
    }
  }

  // ============================================
  // STATIC IMAGES API
  // ============================================
  
  /// Obtener URL de imagen estática del mapa
  /// Útil para previsualizaciones o miniaturas
  static String getStaticMapUrl({
    required LatLng center,
    double zoom = 14,
    int width = 600,
    int height = 400,
    String style = 'streets-v12',
    List<MapMarker>? markers,
  }) {
    final lng = center.longitude;
    final lat = center.latitude;
    
    String overlays = '';
    
    // Añadir marcadores si existen
    if (markers != null && markers.isNotEmpty) {
      for (var marker in markers) {
        overlays += 'pin-s-${marker.label}+${marker.color}(${marker.position.longitude},${marker.position.latitude}),';
      }
      // Remover última coma
      if (overlays.isNotEmpty) {
        overlays = overlays.substring(0, overlays.length - 1);
      }
    }
    
    return '$_baseUrl/styles/v1/mapbox/$style/static/$overlays/$lng,$lat,$zoom,0/${width}x$height@2x?access_token=${EnvConfig.mapboxPublicToken}';
  }

  // ============================================
  // GEOCODING API (Búsqueda de lugares)
  // ============================================
  
  /// Buscar lugares por texto
  /// [query] - Texto de búsqueda (dirección, nombre de lugar, etc.)
  /// [proximity] - Coordenadas para priorizar resultados cercanos
  /// [limit] - Número máximo de resultados (1-10)
  /// [types] - Tipos de resultados: address, poi, place, etc.
  static Future<List<MapboxPlace>> searchPlaces({
    required String query,
    LatLng? proximity,
    int limit = 5,
    List<String>? types,
  }) async {
    try {
      if (query.trim().isEmpty) return [];

      final queryParams = <String, String>{
        'access_token': EnvConfig.mapboxPublicToken,
        'limit': limit.toString(),
        'language': 'es',
      };

      if (proximity != null) {
        queryParams['proximity'] = '${proximity.longitude},${proximity.latitude}';
      }

      if (types != null && types.isNotEmpty) {
        queryParams['types'] = types.join(',');
      }

      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        '$_baseUrl/geocoding/v5/mapbox.places/$encodedQuery.json'
      ).replace(queryParameters: queryParams);

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['features'] != null) {
          final features = data['features'] as List;
          return features.map((f) => MapboxPlace.fromJson(f)).toList();
        }
      } else {
        print('Error en Mapbox Geocoding: ${response.statusCode} - ${response.body}');
      }
      
      return [];
    } catch (e) {
      print('Error buscando lugares: $e');
      return [];
    }
  }

  /// Geocodificación inversa: obtener dirección desde coordenadas
  static Future<MapboxPlace?> reverseGeocode({
    required LatLng position,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/geocoding/v5/mapbox.places/${position.longitude},${position.latitude}.json'
        '?access_token=${EnvConfig.mapboxPublicToken}'
        '&language=es'
        '&types=address,poi,place'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['features'] != null && (data['features'] as List).isNotEmpty) {
          return MapboxPlace.fromJson(data['features'][0]);
        }
      }
      
      return null;
    } catch (e) {
      print('Error en geocodificación inversa: $e');
      return null;
    }
  }

  // ============================================
  // TILES API
  // ============================================
  
  /// Obtener URL para tiles de Mapbox (para flutter_map)
  static String getTileUrl({String style = 'streets-v12'}) {
    return 'https://api.mapbox.com/styles/v1/mapbox/$style/tiles/{z}/{x}/{y}@2x?access_token=${EnvConfig.mapboxPublicToken}';
  }

  // ============================================
  // MATRIX API (Distances y Tiempos)
  // ============================================
  
  /// Calcular matriz de distancias y tiempos entre múltiples puntos
  /// Útil para encontrar el punto más cercano o comparar múltiples destinos
  static Future<MapboxMatrix?> getMatrix({
    required List<LatLng> origins,
    required List<LatLng> destinations,
    String profile = 'driving',
  }) async {
    try {
      // Combinar todos los puntos
      final allPoints = [...origins, ...destinations];
      
      final coordinates = allPoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      // Indicar cuáles son orígenes y cuáles destinos
      final sources = List.generate(origins.length, (i) => i).join(';');
      final destinationsIdx = List.generate(
        destinations.length, 
        (i) => i + origins.length
      ).join(';');

      final url = Uri.parse(
        '$_baseUrl/directions-matrix/v1/mapbox/$profile/$coordinates'
        '?sources=$sources'
        '&destinations=$destinationsIdx'
        '&access_token=${EnvConfig.mapboxPublicToken}'
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await QuotaMonitorService.incrementMapboxRouting();
        
        final data = json.decode(response.body);
        return MapboxMatrix.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('Error en Mapbox Matrix: $e');
      return null;
    }
  }
}

// ============================================
// MODELOS DE DATOS
// ============================================

/// Modelo de ruta de Mapbox
class MapboxRoute {
  final double distance; // en metros
  final double duration; // en segundos
  final List<LatLng> geometry; // Puntos de la ruta
  final List<MapboxStep>? steps; // Instrucciones paso a paso
  final String? routeSummary;

  MapboxRoute({
    required this.distance,
    required this.duration,
    required this.geometry,
    this.steps,
    this.routeSummary,
  });

  factory MapboxRoute.fromJson(Map<String, dynamic> json) {
    List<LatLng> geometry = [];
    
    // Parsear geometría GeoJSON
    if (json['geometry'] != null && json['geometry']['coordinates'] != null) {
      final coords = json['geometry']['coordinates'] as List;
      geometry = coords.map((coord) {
        return LatLng(coord[1] as double, coord[0] as double);
      }).toList();
    }

    // Parsear steps
    List<MapboxStep>? steps;
    if (json['legs'] != null) {
      final legs = json['legs'] as List;
      if (legs.isNotEmpty && legs[0]['steps'] != null) {
        final stepsData = legs[0]['steps'] as List;
        steps = stepsData.map((step) => MapboxStep.fromJson(step)).toList();
      }
    }

    return MapboxRoute(
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      geometry: geometry,
      steps: steps,
      routeSummary: json['summary'],
    );
  }

  /// Distancia en kilómetros
  double get distanceKm => distance / 1000;

  /// Duración en minutos
  double get durationMinutes => duration / 60;

  /// Formato legible de distancia
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${distance.toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Formato legible de duración
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '${durationMinutes.toStringAsFixed(0)} min';
    }
    final hours = (durationMinutes / 60).floor();
    final mins = (durationMinutes % 60).toStringAsFixed(0);
    return '${hours}h ${mins}min';
  }
}

/// Paso de instrucción de ruta
class MapboxStep {
  final double distance;
  final double duration;
  final String instruction;
  final String? name;
  final String? maneuver;

  MapboxStep({
    required this.distance,
    required this.duration,
    required this.instruction,
    this.name,
    this.maneuver,
  });

  factory MapboxStep.fromJson(Map<String, dynamic> json) {
    return MapboxStep(
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      instruction: json['maneuver']?['instruction'] ?? '',
      name: json['name'],
      maneuver: json['maneuver']?['type'],
    );
  }
}

/// Matriz de distancias y tiempos
class MapboxMatrix {
  final List<List<double?>> durations; // en segundos
  final List<List<double?>> distances; // en metros

  MapboxMatrix({
    required this.durations,
    required this.distances,
  });

  factory MapboxMatrix.fromJson(Map<String, dynamic> json) {
    return MapboxMatrix(
      durations: (json['durations'] as List?)
          ?.map((row) => (row as List).map((d) => d as double?).toList())
          .toList() ?? [],
      distances: (json['distances'] as List?)
          ?.map((row) => (row as List).map((d) => d as double?).toList())
          .toList() ?? [],
    );
  }
}

/// Marcador para mapas estáticos
class MapMarker {
  final LatLng position;
  final String label; // 'a', 'b', 'c', etc. o 'star', 'circle'
  final String color; // hexadecimal sin #, ej: 'ff0000'

  MapMarker({
    required this.position,
    this.label = 'a',
    this.color = 'ff0000',
  });
}

/// Lugar encontrado por Geocoding API
class MapboxPlace {
  final String id;
  final String placeName; // Nombre completo del lugar
  final String text; // Nombre corto
  final LatLng coordinates;
  final String? address;
  final String? placeType; // poi, address, place, etc.
  final Map<String, dynamic>? context; // Información de contexto (ciudad, país, etc.)

  MapboxPlace({
    required this.id,
    required this.placeName,
    required this.text,
    required this.coordinates,
    this.address,
    this.placeType,
    this.context,
  });

  factory MapboxPlace.fromJson(Map<String, dynamic> json) {
    final coords = json['geometry']['coordinates'] as List;
    
    return MapboxPlace(
      id: json['id'] ?? '',
      placeName: json['place_name'] ?? '',
      text: json['text'] ?? '',
      coordinates: LatLng(coords[1] as double, coords[0] as double),
      address: json['properties']?['address'],
      placeType: (json['place_type'] as List?)?.first,
      context: json['context'] != null ? Map<String, dynamic>.from(json) : null,
    );
  }

  /// Obtener información del contexto (ciudad, región, país)
  String get contextInfo {
    if (context == null) return '';
    
    final parts = <String>[];
    final contextList = context!['context'] as List?;
    
    if (contextList != null) {
      for (var item in contextList) {
        if (item['id'].toString().startsWith('place.') ||
            item['id'].toString().startsWith('region.')) {
          parts.add(item['text']);
        }
      }
    }
    
    return parts.join(', ');
  }
}
