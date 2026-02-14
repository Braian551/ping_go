import 'package:flutter/material.dart';
import '../../services/conductor_service.dart';
import '../../../../core/config/app_config.dart';
import '../../../../widgets/avatars/custom_user_avatar.dart';
import '../../../../widgets/rating/rating_selector.dart';

class TripSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final double realDistanceKm;
  final int realDurationSeconds;
  final int conductorId;

  const TripSummaryScreen({
    super.key,
    required this.tripData,
    required this.realDistanceKm,
    required this.realDurationSeconds,
    required this.conductorId,
  });

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen> {
  bool _isLoading = true;
  bool _isSubmittingRating = false;
  Map<String, dynamic>? _summaryData;
  
  // Rating state
  int _clientRating = 0;
  TipoCalificacion _tipoCalificacion = TipoCalificacion.estrellas;
  String _motivoBandera = '';

  int get _solicitudId {
    final id = widget.tripData['solicitud_id'] ?? widget.tripData['id'];
    if (id == null) return 0;
    return int.tryParse(id.toString()) ?? 0;
  }

  String _formatCurrency(double amount) {
    if (!amount.isFinite) return '\$0';
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
      final summary = await ConductorService.getTripSummary(
        solicitudId: _solicitudId,
        conductorId: widget.conductorId,
        distanciaKm: widget.realDistanceKm,
        duracionSegundos: widget.realDurationSeconds,
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando resumen: $e')),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds s';
    }
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    int s = seconds % 60;
    
    if (h > 0) {
      return '$h h $m min ${s > 0 ? '$s s' : ''}';
    }
    return '$m min ${s > 0 ? '$s s' : ''}';
  }

  Future<void> _submitRatingAndContinue() async {
    // Si tiene rating, enviarlo
    if (_clientRating > 0) {
      // Si es bandera y no hay motivo, mostrar error
      if (_tipoCalificacion == TipoCalificacion.bandera && _motivoBandera.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor describe el motivo del reporte'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isSubmittingRating = true);

      try {
        final result = await ConductorService.rateClient(
          solicitudId: _solicitudId,
          conductorId: widget.conductorId,
          calificacion: _clientRating,
          tipoCalificacion: _tipoCalificacion == TipoCalificacion.estrellas ? 'estrellas' : 'bandera',
          motivoBandera: _motivoBandera,
        );

        if (result['success'] == true && mounted) {
          final message = _tipoCalificacion == TipoCalificacion.bandera
              ? 'Reporte enviado al administrador'
              : 'Calificación enviada';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: _tipoCalificacion == TipoCalificacion.bandera 
                  ? Colors.orange 
                  : Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error submitting client rating: $e');
      }
    }

    if (mounted) {
      Navigator.pop(context);
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
            onPressed: _isSubmittingRating ? null : _submitRatingAndContinue,
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
              : Text(
                  _clientRating > 0 ? 'CALIFICAR Y CONTINUAR' : 'CONTINUAR',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          const Icon(Icons.error_outline, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text('No se pudo cargar el resumen', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchSummary,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
            child: const Text('Reintentar', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  Widget _buildContent() {
    final calculo = _summaryData!['calculo'] ?? {};
    final viaje = _summaryData!['viaje'] ?? {};
    final desglose = calculo['desglose'] ?? {};
    final total = double.tryParse(calculo['total']?.toString() ?? '0') ?? 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Total
          Center(
            child: Column(
              children: [
                const Text('Total a cobrar', style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                  '${widget.realDistanceKm.toStringAsFixed(1)} km • ${_formatDuration(widget.realDurationSeconds)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Detalles del Cliente
          _buildSectionTitle('Pasajero'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CustomUserAvatar(
              imageUrl: viaje['cliente_foto'],
              radius: 24,
              backgroundColor: Colors.grey[800],
              fallbackColor: Colors.white,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    viaje['cliente'] ?? 'Cliente',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 2),
                Text(
                  (double.tryParse(viaje['cliente_calificacion']?.toString() ?? '5.0') ?? 5.0).toStringAsFixed(1),
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
            subtitle: const Text('Pago en efectivo', style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.money, color: Color(0xFFFFD700)),
          ),
          
          const Divider(color: Colors.grey),
          const SizedBox(height: 16),

          // Desglose
          _buildSectionTitle('Desglose de Tarifa'),
          const SizedBox(height: 8),
          _buildRow('Tarifa Base', _formatCurrency(double.tryParse(desglose['tarifa_base']?.toString() ?? '0') ?? 0)),
          _buildRow('Distancia (${widget.realDistanceKm.toStringAsFixed(1)} km)', _formatCurrency(double.tryParse(desglose['costo_distancia']?.toString() ?? '0') ?? 0)),
          _buildRow('Tiempo (${_formatDuration(widget.realDurationSeconds)})', _formatCurrency(double.tryParse(desglose['costo_tiempo']?.toString() ?? '0') ?? 0)),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Colors.grey),
          ),
          
          _buildRow('Total', _formatCurrency(total), isTotal: true),
          
          const SizedBox(height: 32),
          
          // Rating del Cliente
          _buildSectionTitle('Calificar Pasajero'),
          const SizedBox(height: 16),
          Center(
            child: RatingSelector(
              initialRating: _clientRating,
              initialTipo: _tipoCalificacion,
              onChanged: (rating, tipo, motivo) {
                setState(() {
                  _clientRating = rating;
                  _tipoCalificacion = tipo;
                  _motivoBandera = motivo;
                });
              },
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

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: TextStyle(
                color: isTotal ? Colors.white : Colors.grey[400],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 18 : 16
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value, 
            style: TextStyle(
              color: isTotal ? const Color(0xFFFFD700) : Colors.white,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16
            )
          ),
        ],
      ),
    );
  }
}

