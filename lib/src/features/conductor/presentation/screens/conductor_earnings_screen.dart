import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ping_go/src/core/config/app_config.dart';

class ConductorEarningsScreen extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorEarningsScreen({super.key, required this.conductorUser});

  @override
  State<ConductorEarningsScreen> createState() => _ConductorEarningsScreenState();
}

class _ConductorEarningsScreenState extends State<ConductorEarningsScreen> {
  bool _isLoading = true;
  String _error = '';
  double _totalEarnings = 0.0;
  double _currentDebt = 0.0;
  String _currency = 'COP';

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    try {
      final conductorId = widget.conductorUser['id'];
      final url = Uri.parse('${AppConfig.baseUrl}/conductor/get_balance.php?conductor_id=$conductorId');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final balance = data['balance'];
          if (mounted) {
            setState(() {
              _totalEarnings = double.parse(balance['ganancia_total'].toString());
              _currentDebt = double.parse(balance['deuda_actual'].toString());
              _currency = balance['moneda'] ?? 'COP';
              _isLoading = false;
            });
          }
        } else {
          throw Exception(data['message'] ?? 'Error al obtener datos');
        }
      } else {
        throw Exception('Error de servidor: ${response.statusCode}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        title: const Text('Información de Pago', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFF00)))
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = '';
                          });
                          _fetchEarnings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFF00),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      _buildDebtStatus(),
                      const SizedBox(height: 24),
                      const Text(
                        'Nota: La deuda actual corresponde a las comisiones de los viajes pagados en efectivo que aún no has abonado a la plataforma.',
                        style: TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFFF00).withOpacity(0.2),
            const Color(0xFFFFFF00).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFFF00).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFFFF00), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Mis Ganancias Netas',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$$_totalEarnings $_currency',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acumulado histórico',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebtStatus() {
    final hasDebt = _currentDebt > 0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasDebt ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deuda Actual',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasDebt ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasDebt ? Colors.red : Colors.green,
                    width: 1,
                  ),
                ),
                child: Text(
                  hasDebt ? 'PENDIENTE' : 'AL DÍA',
                  style: TextStyle(
                    color: hasDebt ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
             '\$$_currentDebt $_currency',
            style: TextStyle(
              color: hasDebt ? Colors.redAccent : Colors.greenAccent,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (hasDebt)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tienes comisiones pendientes de pago. Por favor contacta al administrador para regularizar tu cuenta.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
             const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '¡Estás libre de deudas!',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
