import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Servicio de geocoding GRATUITO usando Nominatim (OpenStreetMap)
/// No requiere API key y es completamente gratuito
/// Optimizado para búsquedas en Colombia
/// Límite recomendado: 1 request por segundo
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'PingGo/1.0 (contact@pinggo.app)';
  
  /// Buscar dirección por texto - MEJORADO para Colombia
  static Future<List<NominatimResult>> searchAddress(
    String query, {
    LatLng? proximity,
    int limit = 10,
  }) async {
    try {
      // Construir parámetros de búsqueda
      final params = {
        'format': 'json',
        'q': query,
        'addressdetails': '1',
        'limit': limit.toString(),
        'countrycodes': 'co', // ⭐ LIMITAR A COLOMBIA
        'accept-language': 'es', // ⭐ ESPAÑOL
      };

      // Si hay proximidad, agregar viewbox para priorizar resultados cercanos
      if (proximity != null) {
        // Crear un viewbox de ~50km alrededor del punto
        final double delta = 0.5;
        params['viewbox'] = 
            '${proximity.longitude - delta},${proximity.latitude + delta},'
            '${proximity.longitude + delta},${proximity.latitude - delta}';
        params['bounded'] = '0'; // No limitar estrictamente
      }

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: params);

      print('🔍 Buscando en Nominatim: ${uri.toString().replaceAll(_baseUrl, '...')}');

      final response = await http
          .get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
          'Accept-Language': 'es-CO,es;q=0.9',
        },
      )
          .timeout(const Duration(seconds: 8)); // Reducir timeout a 8 segundos

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results = data.map((item) => NominatimResult.fromJson(item)).toList();
        print('✅ Encontrados ${results.length} lugares en Colombia');
        return results;
      } else {
        print('❌ Error en la búsqueda: ${response.statusCode}');
        throw Exception('Error en la búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      throw Exception('Error de conexión o timeout: $e');
    }
  }

  /// Reverse geocoding - obtener dirección desde coordenadas
  static Future<NominatimResult?> reverseGeocode(double lat, double lon) async {
    try {
      final params = {
        'format': 'json',
        'lat': lat.toString(),
        'lon': lon.toString(),
        'addressdetails': '1',
        'accept-language': 'es',
      };

      final uri = Uri.parse('$_baseUrl/reverse').replace(queryParameters: params);

      print('📍 Geocodificación inversa: $lat, $lon');

      final response = await http
          .get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
          'Accept-Language': 'es-CO,es;q=0.9',
        },
      )
          .timeout(const Duration(seconds: 5)); // Reducir timeout a 5 segundos

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final result = NominatimResult.fromJson(data);
        print('✅ Dirección encontrada: ${result.getFormattedAddress()}');
        return result;
      } else {
        print('❌ Error en geocodificación inversa: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error en geocodificación inversa: $e');
      return null;
    }
  }

  /// Buscar lugares cercanos por categoría (restaurantes, hospitales, etc.)
  static Future<List<NominatimResult>> searchByCategory({
    required String category,
    required LatLng center,
    int limit = 10,
  }) async {
    return searchAddress(
      category,
      proximity: center,
      limit: limit,
    );
  }

  /// Buscar una dirección específica en una ciudad
  static Future<List<NominatimResult>> searchInCity({
    required String query,
    required String city,
    int limit = 10,
  }) async {
    return searchAddress(
      '$query, $city, Colombia',
      limit: limit,
    );
  }
}

class NominatimResult {
  final double lat;
  final double lon;
  final String displayName;
  final Map<String, dynamic> address;
  final String? type;

  NominatimResult({
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.address,
    this.type,
  });

  // Método para obtener coordenadas como LatLng
  LatLng get coordinates => LatLng(lat, lon);

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? '',
      address: json['address'] is Map ? Map<String, dynamic>.from(json['address']) : {},
      type: json['type'],
    );
  }

  /// Obtener dirección formateada de manera clara
  String getFormattedAddress() {
    final addr = address;
    final components = <String>[];
    
    // Priorizar información relevante para Colombia
    if (addr['road'] != null) {
      String road = addr['road'];
      if (addr['house_number'] != null) {
        road = '$road #${addr['house_number']}';
      }
      components.add(road);
    }
    
    if (addr['neighbourhood'] != null) components.add(addr['neighbourhood']);
    if (addr['suburb'] != null && addr['suburb'] != addr['neighbourhood']) {
      components.add(addr['suburb']);
    }
    
    final city = getCity();
    if (city != null) components.add(city);
    
    final state = getState();
    if (state != null && state != city) components.add(state);
    
    return components.isNotEmpty ? components.join(', ') : displayName;
  }

  /// Obtener nombre corto del lugar (para mostrar en listas)
  String getShortName() {
    final addr = address;
    
    // Intentar obtener el nombre más específico
    if (addr['road'] != null) {
      return addr['road'];
    }
    
    if (addr['neighbourhood'] != null) {
      return addr['neighbourhood'];
    }
    
    if (addr['suburb'] != null) {
      return addr['suburb'];
    }
    
    final city = getCity();
    if (city != null) {
      return city;
    }
    
    // Si no hay nada, devolver la primera parte del display_name
    return displayName.split(',').first;
  }

  /// Obtener ciudad
  String? getCity() {
    return address['city'] ?? 
           address['town'] ?? 
           address['village'] ?? 
           address['municipality'];
  }

  /// Obtener departamento/estado
  String? getState() {
    return address['state'] ?? address['region'];
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'displayName': displayName,
      'address': address,
      'type': type,
    };
  }
}