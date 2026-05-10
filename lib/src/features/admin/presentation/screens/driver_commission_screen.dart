import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ping_go/src/global/services/admin/admin_service.dart';
import 'package:ping_go/src/widgets/avatars/custom_user_avatar.dart';
import 'package:ping_go/src/core/config/app_config.dart';
import '../../../conductor/presentation/widgets/payment_detail_sheet.dart';

class DriverCommissionScreen extends StatefulWidget {
  const DriverCommissionScreen({super.key});

  @override
  State<DriverCommissionScreen> createState() => _DriverCommissionScreenState();
}

class _DriverCommissionScreenState extends State<DriverCommissionScreen> {
  List<dynamic> _drivers = [];
  List<dynamic> _history = [];
  List<dynamic> _comprobantes = [];
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
      final results = await Future.wait([
        AdminService.getDriversWithDebt(),
        AdminService.getCommissionHistory(),
        AdminService.getCommissionPayments(),
      ]);

      if (mounted) {
        setState(() {
          if (results[0]['success'] == true)
            _drivers = results[0]['data'] ?? [];
          if (results[1]['success'] == true)
            _history = results[1]['data'] ?? [];
          if (results[2]['success'] == true)
            _comprobantes = results[2]['data'] ?? [];
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
  Future<void> _collectCommission(
    int conductorId,
    String driverName,
    double totalDebt,
  ) async {
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
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Registrar Cobro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conductor: $driverName',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
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
                      prefixStyle: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
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
                    style: TextStyle(
                      color: Colors.redAccent.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final double? enteredAmount = double.tryParse(
                              amountController.text,
                            );
                            if (enteredAmount == null || enteredAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor ingresa un monto válido',
                                  ),
                                ),
                              );
                              return;
                            }
                            Navigator.pop(context, {
                              'confirmed': true,
                              'amount': enteredAmount,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Confirmar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
              backgroundColor: (data['success'] == true)
                  ? Colors.green
                  : Colors.red,
            ),
          );
          _fetchDriversWithDebt();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cobrar: $e'),
              backgroundColor: Colors.red,
            ),
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
              Tab(
                text: 'Pendientes',
                icon: Icon(Icons.pending_actions_rounded),
              ),
              Tab(text: 'Historial', icon: Icon(Icons.history_rounded)),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        body: TabBarView(
          children: [_buildPendientesTab(), _buildHistorialTab()],
        ),
      ),
    );
  }

  Widget _buildPendientesTab() {
    final pendingComprobantes = _comprobantes
        .where(
          (item) => _getPagoEstado(item as Map<String, dynamic>) == 'pendiente',
        )
        .cast<Map<String, dynamic>>()
        .toList();

    if (_isLoading && _drivers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }
    if (_errorMessage.isNotEmpty && _drivers.isEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: Colors.white)),
      );
    }
    if (_drivers.isEmpty) {
      return const Center(
        child: Text(
          'No hay comisiones pendientes.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_drivers.isNotEmpty) ...[
          Text(
            'Comisiones pendientes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ..._drivers.map((driver) {
            final double debt =
                double.tryParse(driver['deuda_total'].toString()) ?? 0.0;
            final conductorId =
                int.tryParse(driver['conductor_id']?.toString() ?? '') ?? 0;
            Map<String, dynamic>? pendingProof;
            for (final pago in pendingComprobantes) {
              final pagoConductorId =
                  int.tryParse(pago['conductor_id']?.toString() ?? '') ?? 0;
              if (pagoConductorId == conductorId) {
                pendingProof = pago;
                break;
              }
            }

            return Card(
              color: const Color(0xFF2C2C2C),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${driver['marca_vehiculo']} ${driver['modelo_vehiculo']} • ${driver['placa_vehiculo']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            '\$${NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0).format(debt)}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    if (pendingProof != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Comprobante pendiente',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _showComprobanteDetailSheet(pendingProof!),
                              child: const Text('Ver comprobante'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: conductorId > 0
                            ? () => _collectCommission(
                                conductorId,
                                driver['nombre'],
                                debt,
                              )
                            : null,
                        icon: const Icon(Icons.attach_money),
                        label: const Text('Registrar Cobro'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  void _showComprobanteDetailSheet(Map<String, dynamic> pago) {
    final comprobanteUrl = _getPagoComprobanteUrl(pago);
    final conductorNombre = _getPagoNombre(pago);
    final monto = _getPagoMonto(pago);
    final fecha = _getPagoFecha(pago);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(
                conductorNombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Monto: \$${NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0).format(monto)} COP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (fecha.isNotEmpty)
                Text(
                  'Enviado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.tryParse(fecha) ?? DateTime.now())}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              const SizedBox(height: 14),
              if (comprobanteUrl != null && comprobanteUrl.isNotEmpty)
                GestureDetector(
                  onTap: () => _showFullImage(comprobanteUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      AppConfig.resolveImageUrl(comprobanteUrl),
                      height: 260,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: Colors.white.withOpacity(0.05),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white30,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No hay imagen de comprobante',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              if (pago['nota_admin'] != null &&
                  pago['nota_admin'].toString().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Nota: ${pago['nota_admin']}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleComprobante(pago, 'rechazado');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFf5576c),
                        side: const BorderSide(color: Color(0xFFf5576c)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _handleComprobante(pago, 'aprobado');
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorialTab() {
    if (_isLoading && _history.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }
    if (_history.isEmpty) {
      return const Center(
        child: Text(
          'No hay historial de pagos registrados.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final double amount =
            double.tryParse(item['monto_pagado'].toString()) ?? 0.0;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CustomUserAvatar(
                imageUrl: item['url_imagen_perfil'],
                radius: 20,
              ),
              title: Text(
                '${item['nombre']} ${item['apellido']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
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
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InteractiveViewer(
            child: Image.network(
              AppConfig.resolveImageUrl(url),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleComprobante(
    Map<String, dynamic> pago,
    String accion,
  ) async {
    String? nota;
    if (accion == 'rechazado') {
      final controller = TextEditingController();
      nota = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Motivo del rechazo',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe el motivo...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf5576c),
              ),
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Rechazar'),
            ),
          ],
        ),
      );
      if (nota == null) return; // Cancelled
    }

    setState(() => _isLoading = true);
    try {
      final pagoId = int.tryParse(pago['id']?.toString() ?? '');
      if (pagoId == null || pagoId <= 0) {
        throw Exception('ID de pago inválido');
      }
      final result = await AdminService.approveCommissionPayment(
        pagoId: pagoId,
        accion: accion,
        nota: nota,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Acción realizada'),
            backgroundColor: result['success'] == true
                ? const Color(0xFF4CAF50)
                : Colors.red,
          ),
        );
        _fetchData(); // Refresh all tabs
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _getPagoEstado(Map<String, dynamic> pago) {
    return pago['estado']?.toString().toLowerCase() ?? 'pendiente';
  }

  String _getPagoNombre(Map<String, dynamic> pago) {
    final nombre = pago['conductor_nombre'] ?? pago['nombre'] ?? '';
    final apellido = pago['conductor_apellido'] ?? pago['apellido'] ?? '';
    final fullName = '$nombre $apellido'.trim();
    if (fullName.isNotEmpty) return fullName;
    return 'Conductor #${pago['conductor_id'] ?? ''}';
  }

  String? _getPagoComprobanteUrl(Map<String, dynamic> pago) {
    final direct = pago['url_comprobante']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;
    final fallback = pago['comprobante_url']?.toString();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  String _getPagoFecha(Map<String, dynamic> pago) {
    return pago['fecha_envio']?.toString() ??
        pago['creado_en']?.toString() ??
        '';
  }

  double _getPagoMonto(Map<String, dynamic> pago) {
    return double.tryParse(pago['monto']?.toString() ?? '0') ?? 0;
  }
}
