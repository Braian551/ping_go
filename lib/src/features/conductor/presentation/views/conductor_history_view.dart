import 'package:flutter/material.dart';
import '../../services/conductor_service.dart';
import 'package:intl/intl.dart';
import '../widgets/trip_detail_sheet.dart';

class ConductorHistoryView extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorHistoryView({super.key, required this.conductorUser});

  @override
  State<ConductorHistoryView> createState() => _ConductorHistoryViewState();
}

class _ConductorHistoryViewState extends State<ConductorHistoryView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _viajes = [];
  String? _errorMessage;

  String _formatCurrency(double amount) {
    final parts = amount.toStringAsFixed(0).split('.');
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = parts[0].replaceAllMapped(regex, (Match m) => '${m[1]}.');
    return '\$$formatted';
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = int.parse(widget.conductorUser['id'].toString());
      final response = await ConductorService.getHistorialViajes(conductorId: userId);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response['success'] == true) {
            _viajes = List<Map<String, dynamic>>.from(response['viajes']);
          } else {
            _errorMessage = response['message'] ?? 'No se pudieron cargar los viajes';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error de conexión: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_viajes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 16),
            Text(
              'No tienes viajes realizados aún',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _viajes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final viaje = _viajes[index];
        final fecha = DateTime.tryParse(viaje['fecha_creacion'].toString()) ?? DateTime.now();
        final formattedDate = DateFormat('dd MMM, hh:mm a').format(fecha);
        
        final ganancia = double.tryParse(viaje['ganancia_conductor']?.toString() ?? '0') ?? 0.0;
        final total = double.tryParse(viaje['precio_final']?.toString() ?? '0') ?? 0.0;
        final comision = viaje['porcentaje_comision']?.toString() ?? '15';

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => TripDetailSheet(trip: viaje),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Completado',
                          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: (viaje['cliente_foto'] != null && viaje['cliente_foto'].toString().isNotEmpty)
                            ? NetworkImage(viaje['cliente_foto'])
                            : null,
                        child: (viaje['cliente_foto'] == null || viaje['cliente_foto'].toString().isEmpty)
                            ? const Icon(Icons.person, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${viaje['cliente_nombre']} ${viaje['cliente_apellido'] ?? ''}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(ganancia),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green, 
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total: ${_formatCurrency(total)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Comisión: $comision%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.05)),
                  const SizedBox(height: 8),
                  _buildAddressRow(Icons.my_location, Colors.white70, viaje['direccion_recogida'] ?? 'Origen'),
                  const SizedBox(height: 8),
                  _buildAddressRow(Icons.location_on, const Color(0xFFFFD700), viaje['direccion_destino'] ?? 'Destino'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
