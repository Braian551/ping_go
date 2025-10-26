import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../global/services/nominatim_service.dart';
import '../../../global/services/mapbox_service.dart';
import '../../../global/services/traffic_service.dart';
import '../../../global/services/quota_monitor_service.dart';

class MapProvider with ChangeNotifier {
  LatLng? _selectedLocation;
  String? _selectedAddress;
  String? _searchQuery;
  bool _isLoading = false;
  List<NominatimResult> _searchResults = [];
  LatLng? _currentLocation;
  String? _selectedCity;
  String? _selectedState;
  
  // Nueva funcionalidad: Rutas y Tráfico
  MapboxRoute? _currentRoute;
  List<LatLng> _routeWaypoints = [];
  TrafficFlow? _currentTraffic;
  List<TrafficIncident> _trafficIncidents = [];
  QuotaStatus? _quotaStatus;

  // Getters
  LatLng? get selectedLocation => _selectedLocation;
  String? get selectedAddress => _selectedAddress;
  String? get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  List<NominatimResult> get searchResults => _searchResults;
  LatLng? get currentLocation => _currentLocation;
  String? get selectedCity => _selectedCity;
  String? get selectedState => _selectedState;
  
  // Nuevos getters
  MapboxRoute? get currentRoute => _currentRoute;
  List<LatLng> get routeWaypoints => _routeWaypoints;
  TrafficFlow? get currentTraffic => _currentTraffic;
  List<TrafficIncident> get trafficIncidents => _trafficIncidents;
  QuotaStatus? get quotaStatus => _quotaStatus;

  /// Seleccionar ubicacin desde el mapa
  Future<void> selectLocation(LatLng location) async {
    _selectedLocation = location;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await NominatimService.reverseGeocode(
        location.latitude, 
        location.longitude
      );
      
      if (result != null) {
        _selectedAddress = result.getFormattedAddress();
        _selectedCity = result.getCity();
        _selectedState = result.getState();
      } else {
        _selectedAddress = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        _selectedCity = null;
        _selectedState = null;
      }
    } catch (e) {
      _selectedAddress = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      _selectedCity = null;
      _selectedState = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Buscar dirección por texto - Mejorado para Colombia
  void searchAddress(String query) async {
    _searchQuery = query;

    // Si la consulta está vacía, limpiar resultados y regresar inmediatamente
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Usar la ubicación actual como proximidad si está disponible
      _searchResults = await NominatimService.searchAddress(
        query,
        proximity: _currentLocation ?? _selectedLocation,
        limit: 10, // Más resultados para mejor cobertura
      );
    } catch (e) {
      _searchResults = [];
      print('Error buscando dirección: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Seleccionar resultado de búsqueda
  void selectSearchResult(NominatimResult result) {
    _selectedLocation = LatLng(result.lat, result.lon);
    _selectedAddress = result.getFormattedAddress();
    _selectedCity = result.getCity();
    _selectedState = result.getState();
    _searchResults = [];
    _searchQuery = null;
    notifyListeners();
  }

  /// Establecer ubicación actual
  void setCurrentLocation(LatLng? location) {
    _currentLocation = location;
    notifyListeners();
  }

  /// Limpiar búsqueda
  void clearSearch() {
    _searchResults = [];
    _searchQuery = null;
    notifyListeners();
  }

  /// Limpiar selección
  void clearSelection() {
    _selectedLocation = null;
    _selectedAddress = null;
    _searchResults = [];
    _searchQuery = null;
    _selectedCity = null;
    _selectedState = null;
    notifyListeners();
  }

  /// Permite establecer la dirección seleccionada manualmente (por ejemplo, edición)
  void setSelectedAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }

  /// Geocodificar una dirección de texto y centrar el mapa en el primer resultado.
  /// Geocode an address and select the first result. Returns true if a result
  /// was found and selected, false otherwise.
  Future<bool> geocodeAndSelect(String address) async {
    final query = address.trim();
    if (query.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final results = await NominatimService.searchAddress(
        query,
        proximity: _currentLocation ?? _selectedLocation,
        limit: 10,
      );
      if (results.isNotEmpty) {
        // Seleccionar el primer resultado
        selectSearchResult(results.first);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // No se encontraron resultados
        _searchResults = [];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _searchResults = [];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================================
  // NUEVAS FUNCIONALIDADES: RUTAS Y TRÁFICO
  // ============================================

  /// Calcular ruta entre origen y destino usando Mapbox
  Future<bool> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
    String profile = 'driving', // driving, walking, cycling
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final points = [origin];
      if (waypoints != null) points.addAll(waypoints);
      points.add(destination);

      final route = await MapboxService.getRoute(
        waypoints: points,
        profile: profile,
        alternatives: true,
        steps: true,
      );

      if (route != null) {
        _currentRoute = route;
        _routeWaypoints = points;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error calculando ruta: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Limpiar ruta actual
  void clearRoute() {
    _currentRoute = null;
    _routeWaypoints = [];
    notifyListeners();
  }

  /// Obtener información de tráfico en una ubicación
  Future<void> fetchTrafficInfo(LatLng location) async {
    try {
      final traffic = await TrafficService.getTrafficFlow(location: location);
      _currentTraffic = traffic;
      notifyListeners();
    } catch (e) {
      print('Error obteniendo tráfico: $e');
    }
  }

  /// Obtener incidentes de tráfico cercanos
  Future<void> fetchTrafficIncidents(LatLng location, {double radiusKm = 5.0}) async {
    try {
      final incidents = await TrafficService.getTrafficIncidents(
        location: location,
        radiusKm: radiusKm,
      );
      _trafficIncidents = incidents;
      notifyListeners();
    } catch (e) {
      print('Error obteniendo incidentes: $e');
    }
  }

  /// Actualizar estado de cuotas
  Future<void> updateQuotaStatus() async {
    try {
      final status = await QuotaMonitorService.getQuotaStatus();
      _quotaStatus = status;
      notifyListeners();
    } catch (e) {
      print('Error actualizando cuotas: $e');
    }
  }

  /// Agregar waypoint a la ruta actual
  void addWaypoint(LatLng waypoint) {
    if (!_routeWaypoints.contains(waypoint)) {
      _routeWaypoints.add(waypoint);
      notifyListeners();
    }
  }

  /// Remover waypoint de la ruta
  void removeWaypoint(LatLng waypoint) {
    _routeWaypoints.remove(waypoint);
    notifyListeners();
  }
}