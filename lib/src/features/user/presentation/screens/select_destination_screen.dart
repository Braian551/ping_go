import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
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
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  
  final FocusNode _originFocus = FocusNode();
  final FocusNode _destinationFocus = FocusNode();
  
  SimpleLocation? _originLocation;
  SimpleLocation? _destinationLocation;
  Position? _currentPosition;
  
  bool _isSearchingDestination = false;
  bool _isLoadingSuggestions = false;
  List<SimpleLocation> _searchSuggestions = [];
  bool _showSuggestions = false;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    
    // Listeners for focus changes to trigger/hide suggestions or clear search
    _originFocus.addListener(() {
      if (_originFocus.hasFocus) {
        setState(() {
           _showSuggestions = true;
           // Trigger search immediately if text exists
           if (_originController.text.isNotEmpty) _onSearchTextChanged();
        });
      }
    });
    
    _destinationFocus.addListener(() {
      if (_destinationFocus.hasFocus) {
        setState(() {
           _showSuggestions = true;
           if (_destinationController.text.isNotEmpty) _onSearchTextChanged();
        });
      }
    });
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _originFocus.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }
  
  // Reuse existing methods but adapt
  Future<void> _loadCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final place = await OsmService.reverseGeocode(position.latitude, position.longitude);
      
      setState(() {
        _currentPosition = position;
        _originLocation = SimpleLocation(
           latitude: position.latitude,
           longitude: position.longitude,
           address: place?.displayName ?? 'Tu ubicación actual'
        );
        _originController.text = _originLocation!.address;
      });
    } catch (_) {
      // Handle error quietly or set default
    }
  }

  void _onSearchTextChanged() {
    final isOrigin = _originFocus.hasFocus;
    final query = isOrigin ? _originController.text.trim() : _destinationController.text.trim();
    
    if (query.length >= 2) {
      _searchSuggestionsWithDebounce(query);
    } else {
      setState(() => _searchSuggestions = []);
    }
  }

  Future<void> _searchSuggestionsWithDebounce(String query) async {
    if (_isSearchingDestination) return;
    setState(() {
      _isSearchingDestination = true;
      _isLoadingSuggestions = true;
    });
    
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Debounce
      
      // Check which field is active to ensure we don't overwrite if user switched fast
      final activeQuery = _originFocus.hasFocus ? _originController.text.trim() : _destinationController.text.trim();
      if (activeQuery != query) return;

      final results = await OsmService.searchPlaces(
        query, 
        lat: _currentPosition?.latitude, 
        lon: _currentPosition?.longitude,
        limit: 5
      );
      
      if (mounted) {
        setState(() {
          _searchSuggestions = results.map((p) => SimpleLocation(
            latitude: p.lat,
            longitude: p.lon,
            address: p.displayName
          )).toList();
        });
      }
    } catch (_) {}
    finally {
      if (mounted) setState(() {
        _isSearchingDestination = false;
        _isLoadingSuggestions = false;
      });
    }
  }

  void _selectSuggestion(SimpleLocation location) {
    setState(() {
      if (_originFocus.hasFocus) {
        _originLocation = location;
        _originController.text = location.address;
        _originFocus.unfocus();
        // Auto focus destination if empty
        if (_destinationController.text.isEmpty) {
          _destinationFocus.requestFocus();
        }
      } else {
        _destinationLocation = location;
        _destinationController.text = location.address;
        _destinationFocus.unfocus();
      }
      _showSuggestions = false;
      _searchSuggestions = [];
    });
  }

  void _searchDestination() {
     // Triggered by "Enter" key
     // Just hide keyboard if valid
     FocusScope.of(context).unfocus();
     setState(() => _showSuggestions = false);
  }
  
  void _continueToPreview() {
    if (_originLocation == null || _destinationLocation == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa origen y destino')));
       return;
    }
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
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF1A1A1A),
                    Colors.black,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Planificar viaje',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Route Selector
                _buildRouteSelector(),
                
                // Suggestions List
                if (_showSuggestions)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _isLoadingSuggestions 
                          ? _buildShimmerSuggestions()
                          : _searchSuggestions.isNotEmpty 
                            ? ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _searchSuggestions.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.white.withOpacity(0.05),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final suggestion = _searchSuggestions[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFFFFFF00),
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                suggestion.address,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                                onTap: () => _selectSuggestion(suggestion),
                              );
                            },
                        )
                      : const SizedBox.shrink(),
                      ),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                
                // Continue Button
                if (_destinationLocation != null && _originLocation != null && !_showSuggestions) 
                  _buildContinueButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSuggestions() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withOpacity(0.05),
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Container(
                  width: 150,
                  height: 12,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.5), // Subtle background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Origin Input
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 32, // More spacing
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _originController,
                  focusNode: _originFocus,
                  hintText: 'Punto de origen',
                  isActive: _originFocus.hasFocus,
                  onClear: () {
                    _originController.clear();
                    _onSearchTextChanged();
                  },
                ),
              ),
            ],
          ),
          
          // Destination Input
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFF00),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFFF00).withOpacity(0.5),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  controller: _destinationController,
                  focusNode: _destinationFocus,
                  hintText: '¿A dónde vas?',
                  isActive: _destinationFocus.hasFocus,
                  onClear: () {
                    _destinationController.clear();
                    _onSearchTextChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool isActive,
    VoidCallback? onClear,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive 
          ? Border.all(color: const Color(0xFFFFFF00).withOpacity(0.5), width: 1)
          : Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        cursorColor: const Color(0xFFFFFF00),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: controller.text.isNotEmpty && isActive
              ? GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close_rounded, size: 18, color: Colors.white.withOpacity(0.5)),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        onChanged: (_) => _onSearchTextChanged(),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _continueToPreview,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFFF00),
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
    );
  }
}


