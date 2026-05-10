import 'dart:convert';
import 'package:http/http.dart' as http;

class VehicleApiService {
  static const String _baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  static const List<String> _commonCarMakes = [
    'CHEVROLET', 'RENAULT', 'MAZDA', 'KIA', 'HYUNDAI', 'TOYOTA', 'NISSAN', 'FORD', 
    'VOLKSWAGEN', 'SUZUKI', 'HONDA', 'MERCEDES-BENZ', 'BMW', 'AUDI', 'FIAT', 'JEEP', 
    'MITSUBISHI', 'PEUGEOT', 'CITROEN', 'SUBARU', 'VOLVO', 'LAND ROVER', 'PORSCHE', 
    'MINI', 'SEAT', 'DODGE', 'RAM', 'SSANGYONG', 'CHERY', 'JAC', 'BYD', 'FOTON', 
    'GREAT WALL', 'CHANGAN', 'GEELY', 'MG', 'DFSK', 'TESLA', 'LEXUS', 'DAIHATSU'
  ];

  static const List<String> _commonMotorcycleMakes = [
    'YAMAHA', 'BAJAJ', 'HONDA', 'SUZUKI', 'AKT', 'VICTORY', 'HERO', 'TVS', 
    'KAWASAKI', 'KTM', 'KYMCO', 'PIAGGIO', 'VESPA', 'DUCATI', 'BMW', 
    'ROYAL ENFIELD', 'HARLEY-DAVIDSON', 'BENELLI', 'HUSQVARNA', 'TRIUMPH', 'APRILIA', 'SYM'
  ];

  /// Fetch vehicle makes by type (car, motorcycle)
  /// type: 'car' or 'motorcycle'
  static Future<List<String>> getMakes(String type) async {
    final bool isMoto = type.toLowerCase() == 'motocicleta' || type.toLowerCase() == 'motorcycle';
    final fallbackList = isMoto ? _commonMotorcycleMakes : _commonCarMakes;

    try {
      // NHTSA uses specific names for vehicle types
      String nhtsaType = isMoto ? 'motorcycle' : 'passenger car';
          
      final url = Uri.parse('$_baseUrl/GetMakesForVehicleType/$nhtsaType?format=json');
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['Results'] as List;
        
        final apiList = results
            .map<String>((item) => item['MakeName']?.toString().trim().toUpperCase() ?? '')
            .where((name) => name.isNotEmpty)
            .where((name) => _isValidBrand(name)) // Filter junk
            .toSet() // Remove duplicates
            .toList();
            
        // Combine Common List + API List (deduplicated)
        // We put common list first
        final Set<String> combined = {...fallbackList};
        combined.addAll(apiList);
        
        return combined.toList();
      }
      return fallbackList;
    } catch (e) {
      print('Error fetching makes: $e. Returning fallback list.');
      return fallbackList;
    }
  }

  static bool _isValidBrand(String name) {
    // Filter out obscure custom shops, LLCs, etc.
    final badKeywords = [
      'LLC', 'INC', 'LTD', 'CORP', 'CO.', 'LIMITED', 'CUSTOMS', 'CHOPPERS', 
      'PERFORMANCE', 'RACING', 'CYCLE', 'TRAILER', 'MOTOR', 'CONVERSION', 
      'SYSTEMS', 'DESIGN', 'WORKS', 'GARAGE', 'INDUSTRIES', 'MANUFACTURING', 
      'ENTERPRISES', 'GROUP', 'HOLDINGS', 'TRUST', 'PARTNERS', ',', '.', 
      'SERVICES', 'SOLUTION', 'LOGISTICS', 'INTERNATIONAL', 'GLOBAL', 
      'KUSTOMS', 'RESTORATION', 'ENGINEERING'
    ];
    
    // Exclude if starts with digit (except specifically allowed ones if any, but mostly junk)
    if (RegExp(r'^[0-9]').hasMatch(name)) return false;
    
    // Exclude if contains bad keywords
    for (final keyword in badKeywords) {
      if (name.contains(keyword)) return false;
    }
    
    return true;
  }

  /// Fetch models for a specific make
  /// Returns List<String> of model names
  static Future<List<String>> getModels(String make) async {
    try {
      final url = Uri.parse('$_baseUrl/GetModelsForMake/$make?format=json');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['Results'] as List;
        
        return results
            .map<String>((item) => item['Model_Name']?.toString().trim().toUpperCase() ?? '')
            .where((name) => name.isNotEmpty)
            .toSet() // Remove duplicates
            .toList()
            ..sort();
      }
      return [];
    } catch (e) {
      print('Error fetching models: $e');
      return [];
    }
  }
}
