import 'package:flutter/material.dart';
import '../../services/conductor_service.dart';

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
      final summary = await ConductorService.getTripSummary(
        solicitudId: int.parse(widget.tripData['solicitud_id'].toString()),
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'CONTINUAR',
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
            leading: CircleAvatar(
              backgroundColor: Colors.grey[800],
              backgroundImage: (viaje['cliente_foto'] != null)
                ? NetworkImage(viaje['cliente_foto'])
                : null,
              child: (viaje['cliente_foto'] == null)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
            ),
            title: Text(
              viaje['cliente'] ?? 'Cliente',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          Text(
            label, 
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey[400],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16
            )
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
