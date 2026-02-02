import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';

class TripDetailSheet extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailSheet({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    // Helper function for currency formatting
    String formatCurrency(double amount) {
      if (amount == 0) return '\$0';
      final parts = amount.toStringAsFixed(0).split('.');
      final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      final formatted = parts[0].replaceAllMapped(regex, (Match m) => '${m[1]}.');
      return '\$$formatted';
    }

    // Parse data safely
    final fecha = DateTime.tryParse(trip['fecha_creacion'].toString()) ?? DateTime.now();
    final formattedDate = DateFormat('EEEE d, MMMM yyyy').format(fecha);
    final formattedTime = DateFormat('hh:mm a').format(fecha);
    
    final ganancia = double.tryParse(trip['ganancia_conductor']?.toString() ?? '0') ?? 0.0;
    final total = double.tryParse(trip['precio_final']?.toString() ?? '0') ?? 0.0;
    final comisionAmount = total - ganancia;
    final comisionPercent = trip['porcentaje_comision']?.toString() ?? '15';
    
    // Helper function for duration formatting
    String formatDuration(int seconds) {
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
    
    final durationSeconds = int.tryParse(trip['duracion_real']?.toString() ?? '0') ?? 0;
    
    final distanceKm = double.tryParse(trip['distancia_real']?.toString() ?? '0') ?? 0.0;

    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: (trip['cliente_foto'] != null && trip['cliente_foto'].toString().isNotEmpty)
                      ? NetworkImage(AppConfig.resolveImageUrl(trip['cliente_foto']))
                      : null,
                  child: (trip['cliente_foto'] == null || trip['cliente_foto'].toString().isEmpty)
                      ? const Icon(Icons.person, size: 30, color: Colors.white54)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip['cliente_nombre']} ${trip['cliente_apellido'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '$formattedDate • $formattedTime',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(ganancia),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),

          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.timer_outlined, formatDuration(durationSeconds), 'Duración'),
                _buildStatItem(Icons.speed, '$distanceKm km', 'Distancia'),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),

          // Locations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildLocationItem(
                  Icons.my_location, 
                  Colors.white70, 
                  trip['direccion_recogida'] ?? 'Punto de recogida',
                  isFirst: true,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 11),
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                _buildLocationItem(
                  Icons.location_on, 
                  const Color(0xFFFFD700), 
                  trip['direccion_destino'] ?? 'Destino',
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          // Financial Details Box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
              child: Column(
                children: [
                  _buildFinanceRow('Tarifa Total', formatCurrency(total)),
                  const SizedBox(height: 8),
                  _buildFinanceRow(
                    'Comisión ($comisionPercent%)', 
                    '-${formatCurrency(comisionAmount)}',
                    isNegative: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.white10),
                  ),
                  _buildFinanceRow(
                    'Tu Ganancia', 
                    formatCurrency(ganancia),
                    isBold: true,
                    valueColor: const Color(0xFFFFD700),
                  ),
                ],
              ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationItem(IconData icon, Color color, String text, {bool isFirst = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceRow(String label, String value, {bool isNegative = false, bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isNegative ? Colors.redAccent : Colors.white),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
