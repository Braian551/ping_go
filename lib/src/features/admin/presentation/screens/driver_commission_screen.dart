import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ping_go/src/global/services/admin/admin_service.dart';
import 'package:ping_go/src/widgets/avatars/custom_user_avatar.dart';
import '../../../conductor/presentation/widgets/payment_detail_sheet.dart';

class DriverCommissionScreen extends StatefulWidget {
  const DriverCommissionScreen({super.key});

  @override
  State<DriverCommissionScreen> createState() => _DriverCommissionScreenState();
}

class _DriverCommissionScreenState extends State<DriverCommissionScreen> {
  List<dynamic> _drivers = [];
  List<dynamic> _history = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final debtData = await AdminService.getDriversWithDebt();
      final historyData = await AdminService.getCommissionHistory();

      if (mounted) {
        setState(() {
          if (debtData['success'] == true) {
            _drivers = debtData['data'];
          }
          if (historyData['success'] == true) {
            _history = historyData['data'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error de conexión: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchDriversWithDebt() async {
    // Keep this for refreshing after a payment
    try {
      final data = await AdminService.getDriversWithDebt();
      final hData = await AdminService.getCommissionHistory();
      if (mounted && data['success'] == true) {
        setState(() {
          _drivers = data['data'];
          _history = hData['data'] ?? _history;
        });
      }
    } catch (_) {}
  }

  // ... (Keep _collectCommission as is, it's already good)
  Future<void> _collectCommission(int conductorId, String driverName, double totalDebt) async {
    final TextEditingController amountController = TextEditingController(
      text: totalDebt.toStringAsFixed(0),
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.amber, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Registrar Cobro',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conductor: $driverName',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Monto a cobrar',
                      labelStyle: const TextStyle(color: Colors.amber),
                      prefixText: r'$ ',
                      prefixStyle: const TextStyle(color: Colors.amber, fontSize: 18),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deuda total: \$${NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0).format(totalDebt)}',
                    style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final double? enteredAmount = double.tryParse(amountController.text);
                            if (enteredAmount == null || enteredAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor ingresa un monto válido')),
                              );
                              return;
                            }
                            Navigator.pop(context, {'confirmed': true, 'amount': enteredAmount});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null && result['confirmed'] == true) {
      final double collectAmount = result['amount'];
      try {
        setState(() => _isLoading = true);
        final data = await AdminService.collectCommission(
          conductorId: conductorId,
          amount: collectAmount,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Acción realizada'),
              backgroundColor: (data['success'] == true) ? Colors.green : Colors.red,
            ),
          );
          _fetchDriversWithDebt();
        }
      } catch (e) {
         if (mounted) {
           setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cobrar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cobro de Comisiones'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Pendientes', icon: Icon(Icons.pending_actions_rounded)),
              Tab(text: 'Historial', icon: Icon(Icons.history_rounded)),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        body: TabBarView(
          children: [
            _buildPendientesTab(),
            _buildHistorialTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendientesTab() {
    if (_isLoading && _drivers.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }
    if (_errorMessage.isNotEmpty && _drivers.isEmpty) {
      return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.white)));
    }
    if (_drivers.isEmpty) {
      return const Center(child: Text('No hay conductores con deuda pendiente.', style: TextStyle(color: Colors.white70)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _drivers.length,
      itemBuilder: (context, index) {
        final driver = _drivers[index];
        final double debt = double.tryParse(driver['deuda_total'].toString()) ?? 0.0;

        return Card(
          color: const Color(0xFF2C2C2C),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomUserAvatar(
                      imageUrl: driver['url_imagen_perfil'],
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${driver['nombre']} ${driver['apellido']}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${driver['marca_vehiculo']} ${driver['modelo_vehiculo']} • ${driver['placa_vehiculo']}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.5)),
                      ),
                      child: Text(
                        '\$${NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0).format(debt)}',
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _collectCommission(int.parse(driver['conductor_id'].toString()), driver['nombre'], debt),
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Registrar Cobro'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistorialTab() {
    if (_isLoading && _history.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }
    if (_history.isEmpty) {
      return const Center(child: Text('No hay historial de pagos registrados.', style: TextStyle(color: Colors.white70)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final double amount = double.tryParse(item['monto_pagado'].toString()) ?? 0.0;
        final DateTime date = DateTime.parse(item['fecha_pago']);

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => PaymentDetailSheet(
                conductorId: int.parse(item['conductor_id'].toString()),
                payment: item,
                fetcher: AdminService.getPaymentDetails,
              ),
            );
          },
          child: Card(
            color: const Color(0xFF2C2C2C),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CustomUserAvatar(
              imageUrl: item['url_imagen_perfil'],
              radius: 20,
            ),
            title: Text(
              '${item['nombre']} ${item['apellido']}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(date),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Text(
                  '${item['num_transacciones']} transacciones liquidadas',
                  style: const TextStyle(color: Colors.amber, fontSize: 11),
                ),
              ],
            ),
            trailing: Text(
              '\$${NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0).format(amount)}',
              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),);
      },
    );
  }
}
