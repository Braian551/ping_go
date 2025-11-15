import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../global/services/osm_service.dart';
import 'trip_preview_screen.dart';

/// Modelo simple para ubicaciones
class SimpleLocation {
  final double latitude;
  final double longitude;
  final String address;
  
  SimpleLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
  
  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// Pantalla simplificada de selección de destino
/// Solo búsqueda de destino con Nominatim y mapa OpenStreetMap
class SelectDestinationScreen extends StatefulWidget {
  const SelectDestinationScreen({super.key});

  @override
  State<SelectDestinationScreen> createState() => _SelectDestinationScreenState();
}

class _SelectDestinationScreenState extends State<SelectDestinationScreen> {
  final TextEditingController _destinationController = TextEditingController();
  
  SimpleLocation? _originLocation;
  SimpleLocation? _destinationLocation;
  Position? _currentPosition;
  
  bool _isSearchingDestination = false;
  List<SimpleLocation> _searchSuggestions = [];
  bool _showSuggestions = false;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _destinationController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _destinationController.removeListener(_onSearchTextChanged);
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }
      
      // Obtener posición actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Geocodificar usando OSM
      final place = await OsmService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      
      final address = place?.displayName ?? 'Ubicación actual';
      
      setState(() {
        _currentPosition = position;
        _originLocation = SimpleLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    }
  }

  void _onSearchTextChanged() {
    final query = _destinationController.text.trim();
    
    if (query.length >= 1) {
      _searchSuggestionsWithDebounce(query);
    } else {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _searchSuggestionsWithDebounce(String query) async {
    // Cancelar búsqueda anterior si existe
    if (_isSearchingDestination) return;
    
    setState(() => _isSearchingDestination = true);
    
    try {
      // Pequeño delay para evitar demasiadas búsquedas
      await Future.delayed(const Duration(milliseconds: 150));
      
      if (!mounted || _destinationController.text.trim() != query) return;
      
      final results = await OsmService.searchPlaces(
        query,
        lat: _currentPosition?.latitude,
        lon: _currentPosition?.longitude,
        limit: 5, // Limitar a 5 sugerencias
      );
      
      if (mounted && _destinationController.text.trim() == query) {
        setState(() {
          _searchSuggestions = results.map((place) => SimpleLocation(
            latitude: place.lat,
            longitude: place.lon,
            address: place.displayName,
          )).toList();
          _showSuggestions = _searchSuggestions.isNotEmpty;
        });
      }
    } catch (e) {
      // Silenciar errores de búsqueda en tiempo real
    } finally {
      if (mounted) {
        setState(() => _isSearchingDestination = false);
      }
    }
  }

  Future<void> _searchDestination() async {
    final query = _destinationController.text.trim();
    
    if (query.isEmpty) return;
    
    setState(() => _isSearchingDestination = true);
    
    try {
      // Buscar lugares con OSM (Nominatim)
      final results = await OsmService.searchPlaces(
        query,
        lat: _currentPosition?.latitude,
        lon: _currentPosition?.longitude,
      );
      
      if (results.isEmpty) {
        throw Exception('No se encontraron resultados');
      }
      
      // Convertir a SimpleLocation
      final locations = results.map((place) => SimpleLocation(
        latitude: place.lat,
        longitude: place.lon,
        address: place.displayName,
      )).toList();
      
      // Mostrar resultados para que el usuario seleccione
      if (mounted) {
        final selected = await showModalBottomSheet<SimpleLocation>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildSearchResults(locations),
        );
        
        if (selected != null) {
          setState(() {
            _destinationLocation = selected;
            _destinationController.text = selected.address;
            _searchSuggestions = [];
            _showSuggestions = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains('No se encontraron resultados') 
            ? 'No se encontraron resultados'
            : 'Error en búsqueda: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      setState(() => _isSearchingDestination = false);
    }
  }

  void _selectSuggestion(SimpleLocation location) {
    setState(() {
      _destinationLocation = location;
      _destinationController.text = location.address;
      _searchSuggestions = [];
      _showSuggestions = false;
    });
    // Ocultar teclado
    FocusScope.of(context).unfocus();
  }

  Widget _buildSearchResults(List<SimpleLocation> results) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Selecciona un destino',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: results.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final location = results[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(
                      location.address,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    onTap: () => Navigator.pop(context, location),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _continueToPreview() {
    if (_originLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un destino'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Usar vehículo por defecto (moto)
    const defaultVehicleType = 'moto';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPreviewScreen(
          origin: _originLocation!,
          destination: _destinationLocation!,
          vehicleType: defaultVehicleType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFF00)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '¿A dónde vas?',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Campo de búsqueda de destino
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFFF00), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFF00),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFFF00), width: 2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        style: const TextStyle(
                          color: Color(0xFFFFFF00),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar destino en Colombia',
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(179, 255, 255, 255),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          suffixIcon: _isSearchingDestination
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFF00)),
                                    ),
                                  ),
                                )
                              : const Icon(Icons.search, size: 20, color: Color(0xFFFFFF00)),
                        ),
                        onSubmitted: (_) => _searchDestination(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Sugerencias de búsqueda
          if (_showSuggestions && _searchSuggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFFF00), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x4DFFFF00),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchSuggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    color: const Color(0x4DFFFF00),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = _searchSuggestions[index];
                    return Container(
                      color: Colors.black,
                      child: ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on,
                          color: Color(0xFFFFFF00),
                          size: 20,
                        ),
                        title: Text(
                          suggestion.address,
                          style: const TextStyle(
                            color: Color(0xFFFFFF00),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectSuggestion(suggestion),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Espacio vacío para mantener el layout simple
          const Expanded(child: SizedBox()),
          
          // Botón de continuar (solo si hay destino seleccionado)
          if (_destinationLocation != null) _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: const Color(0x4DFFFF00), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _continueToPreview,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFF00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ver en mapa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
