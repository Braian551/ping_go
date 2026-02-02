import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ping_go/src/core/config/app_config.dart';

class TripDetailSheet extends StatelessWidget {
  final Map<String, dynamic> trip;

  const TripDetailSheet({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final conductor = trip['conductor'];
    final estado = trip['estado'] ?? 'desconocido';
    final costo = double.tryParse(trip['costo']?.toString() ?? '0') ?? 0.0;
    final fecha = trip['fecha'] ?? '';
    final duracion = trip['duracion_real'] != null 
        ? _formatDuration(int.tryParse(trip['duracion_real'].toString()) ?? 0) 
        : '--';
    final distancia = trip['distancia_real'] != null 
        ? '${double.tryParse(trip['distancia_real'].toString())?.toStringAsFixed(1) ?? '0.0'} km' 
        : '--';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header: Estado y Fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detalle del viaje',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(estado).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(estado),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fecha,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          
          const SizedBox(height: 32),

          // Conductor Info
          if (conductor != null) ...[
            const Text(
              'Conductor',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: conductor['foto'] != null 
                    ? NetworkImage(_resolveUrl(conductor['foto']))
                    : null,
                  child: conductor['foto'] == null 
                    ? const Icon(Icons.person, size: 24, color: Colors.white)
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conductor['nombre'] ?? 'Conductor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (conductor['modelo'] != null)
                            Text(
                              conductor['modelo'],
                              style: TextStyle(color: Colors.grey[400], fontSize: 13),
                            ),
                          if (conductor['placa'] != null) ...[
                            const SizedBox(width: 8),
                            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(
                              conductor['placa'],
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
          
          // Ruta
          const Text(
            'Ruta',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRouteItem(Icons.circle, Colors.yellow, trip['origen'] ?? 'Origen'),
          _buildRouteLine(),
          _buildRouteItem(Icons.location_on, Colors.red, trip['destino'] ?? 'Destino'),
          
          const SizedBox(height: 32),
          
          // Resumen de Costo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildCostRow('Distancia recorrida', distancia),
                const SizedBox(height: 12),
                _buildCostRow('Tiempo de viaje', duracion),
                const Divider(color: Colors.grey, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${_formatCurrency(costo)}',
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRouteItem(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine() {
    return Container(
      margin: const EdgeInsets.only(left: 7.5),
      padding: const EdgeInsets.symmetric(vertical: 4),
      height: 24,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completada':
      case 'finalizado':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      case 'aceptada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds s';
    int h = seconds ~/ 3600;
    int m = (seconds % 3600) ~/ 60;
    if (h > 0) return '$h h $m min';
    return '$m min';
  }

  String _resolveUrl(String path) {
    return AppConfig.resolveImageUrl(path);
  }
}
