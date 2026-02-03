import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/conductor_service.dart';

typedef PaymentDetailFetcher = Future<Map<String, dynamic>> Function(int conductorId, String fechaPago);

class PaymentDetailSheet extends StatefulWidget {
  final int conductorId;
  final Map<String, dynamic> payment;
  final PaymentDetailFetcher? fetcher;

  const PaymentDetailSheet({
    super.key,
    required this.conductorId,
    required this.payment,
    this.fetcher,
  });

  @override
  State<PaymentDetailSheet> createState() => _PaymentDetailSheetState();
}

class _PaymentDetailSheetState extends State<PaymentDetailSheet> {
  bool _isLoading = true;
  List<dynamic> _trips = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final fetcher = widget.fetcher ?? ConductorService.getPaymentDetails;
      final result = await fetcher(
        widget.conductorId,
        widget.payment['fecha_pago'].toString(),
      );

      if (mounted) {
        setState(() {
          if (result['success'] == true) {
            _trips = result['trips'];
          } else {
            _error = result['message'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatCurrency(double amount) {
    if (amount == 0) return '\$0';
    final parts = amount.toStringAsFixed(0).split('.');
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = parts[0].replaceAllMapped(regex, (Match m) => '${m[1]}.');
    return '\$$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(widget.payment['monto_pagado'].toString()) ?? 0.0;
    final date = DateTime.tryParse(widget.payment['fecha_pago'].toString()) ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalle de Pago',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(amount),
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFF00)))
                : _error != null
                    ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _trips.length,
                        separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 32),
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          final tripTotal = double.tryParse(trip['monto_total'].toString()) ?? 0.0;
                          final tripCom = double.tryParse(trip['comision'].toString()) ?? 0.0;
                          final tripDate = DateTime.tryParse(trip['fecha_transaccion'].toString()) ?? DateTime.now();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${trip['cliente_nombre']} ${trip['cliente_apellido'] ?? ''}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    DateFormat('HH:mm').format(tripDate),
                                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildLocationSmall(Icons.my_location, trip['direccion_recogida'] ?? 'Origen'),
                              const SizedBox(height: 4),
                              _buildLocationSmall(Icons.location_on, trip['direccion_destino'] ?? 'Destino', iconColor: const Color(0xFFFFFF00)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total del viaje: ${_formatCurrency(tripTotal)}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                  ),
                                  Text(
                                    'Comisión: ${_formatCurrency(tripCom)}',
                                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSmall(IconData icon, String text, {Color iconColor = Colors.white54}) {
    return Row(
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
