import 'package:flutter/material.dart';
import '../../services/trip_request_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../global/services/auth/user_service.dart';

class ClientTripSummaryScreen extends StatefulWidget {
  final int solicitudId;
  final Map<String, dynamic> tripData;

  const ClientTripSummaryScreen({
    super.key,
    required this.solicitudId,
    required this.tripData,
  });

  @override
  State<ClientTripSummaryScreen> createState() => _ClientTripSummaryScreenState();
}

class _ClientTripSummaryScreenState extends State<ClientTripSummaryScreen> {
  bool _isLoading = true;
  bool _isSubmittingRating = false;
  int _selectedRating = 0;
  Map<String, dynamic>? _summaryData;

  String _formatCurrency(double amount) {
    if (amount == 0) return '\$0';
    final parts = amount.toStringAsFixed(0).split('.');
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = parts[0].replaceAllMapped(regex, (Match m) => '${m[1]}.');
    return '\$$formatted';
  }

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final summary = await TripRequestService.getTripSummary(widget.solicitudId);
      
      if (mounted) {
        setState(() {
          _summaryData = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds s';
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    return h > 0 ? '$h h $m min' : '$m min';
  }

  /// Get profile image URL with proper base URL prefix
  String? _getProfileImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    final url = AppConfig.resolveImageUrl(relativePath);
    return url.isNotEmpty ? url : null;
  }

  Future<void> _submitRatingAndFinish() async {
    // Si no seleccionó calificación, solo navegamos
    if (_selectedRating == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() => _isSubmittingRating = true);

    try {
      final session = await UserService.getSavedSession();
      final userId = session?['id']; // as int?
      
      if (userId != null) {
        // userId might come as String or Int from shared prefs via UserService helper map construction
        final userIdInt = userId is int ? userId : int.parse(userId.toString());
        
        final result = await TripRequestService.rateTrip(
          solicitudId: widget.solicitudId,
          usuarioId: userIdInt,
          calificacion: _selectedRating,
        );
        
        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Gracias por tu calificación!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error submitting rating: $e');
    }

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Resumen del Viaje', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : (_summaryData == null) 
            ? _buildErrorView() 
            : _buildContent(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmittingRating ? null : _submitRatingAndFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmittingRating
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : const Text(
                  'FINALIZAR',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text('Viaje Completado', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Gracias por viajar con nosotros', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Parse data from _summaryData handling potential nulls
    // Structure depends on what getTripSummary returns.
    // Assuming keys: costo_total, distancia_km, duracion_segundos, conductor...
    
    final total = double.tryParse(_summaryData!['costo_total']?.toString() ?? '0') ?? 0.0;
    final distancia = double.tryParse(_summaryData!['distancia_real_km']?.toString() ?? '0') ?? 0.0;
    final duracion = int.tryParse(_summaryData!['duracion_real_segundos']?.toString() ?? '0') ?? 0;
    final conductor = _summaryData!['conductor'] ?? {};
    final profileUrl = _getProfileImageUrl(conductor['foto']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Amount
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('Has pagado', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(total),
                  style: const TextStyle(
                    color: Color(0xFFFFD700), 
                    fontSize: 48, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1
                  ),
                ),
                Text(
                  '${distancia.toStringAsFixed(1)} km • ${_formatDuration(duracion)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Driver Info
          _buildSectionTitle('Conductor'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              backgroundImage: (profileUrl != null)
                ? NetworkImage(profileUrl)
                : null,
              child: (profileUrl == null)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
            ),
            title: Text(
              conductor['nombre'] ?? 'Conductor',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                 const Icon(Icons.star, size: 14, color: Colors.amber),
                 Text(' ${double.tryParse(conductor['calificacion']?.toString() ?? '0') == 0 ? '5.0' : conductor['calificacion']}', style: const TextStyle(color: Colors.grey)),
                 const SizedBox(width: 10),
                 Text(conductor['placa'] ?? '', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),

          // Rating Prompt (Placeholder)
          Center(
            child: Column(
              children: [
                const Text('¿Cómo estuvo tu viaje?', style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border, 
                          color: const Color(0xFFFFD700), 
                          size: 40
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.grey, 
        fontSize: 12, 
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2
      ),
    );
  }
}
