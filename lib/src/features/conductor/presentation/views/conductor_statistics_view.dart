import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/conductor_service.dart';

/// Vista de estadísticas del conductor: ganancias, viajes, rating, deuda, gráficos
class ConductorStatisticsView extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorStatisticsView({
    super.key,
    required this.conductorUser,
  });

  @override
  State<ConductorStatisticsView> createState() => _ConductorStatisticsViewState();
}

class _ConductorStatisticsViewState extends State<ConductorStatisticsView> {
  bool _loading = true;
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _commissionData = {};
  final _copFormat = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final userId = widget.conductorUser['id'];
    final conductorId = int.tryParse(userId?.toString() ?? '0') ?? 0;
    if (conductorId == 0) {
      setState(() => _loading = false);
      return;
    }

    final results = await Future.wait([
      ConductorService.getEstadisticas(conductorId),
      ConductorService.getCommissionStatus(conductorId),
    ]);

    if (mounted) {
      setState(() {
        _stats = results[0];
        final commResult = results[1];
        _commissionData = commResult['success'] == true ? (commResult['data'] ?? {}) : {};
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFFFFF00),
      backgroundColor: const Color(0xFF1A1A1A),
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          _buildHeader(),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFFFFFF00)),
              ),
            )
          else ...[
            _buildCommissionCard(),
            const SizedBox(height: 20),
            _buildChartSection(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildMonthlySummary(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Mis Estadísticas',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildChartSection() {
    final weeklyData = _stats['grafico_semanal'] as List? ?? [];
    if (weeklyData.isEmpty) return const SizedBox.shrink();

    // Find max Y for axis
    double maxY = 0;
    for (var day in weeklyData) {
      final monto = double.tryParse(day['monto']?.toString() ?? '0') ?? 0;
      if (monto > maxY) maxY = monto;
    }
    // Add buffer
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingresos Semanales',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        _copFormat.format(rod.toY),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                    getTooltipColor: (_) => const Color(0xFF2C2C2C),
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weeklyData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              weeklyData[index]['dia'] ?? '',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(weeklyData.length, (index) {
                  final day = weeklyData[index];
                  final monto = double.tryParse(day['monto']?.toString() ?? '0') ?? 0.0;
                  final isToday = index == weeklyData.length - 1; // Assuming last is today

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: monto,
                        color: isToday ? const Color(0xFFFFFF00) : const Color(0xFF4CAF50),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.white.withOpacity(0.02),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final ganancia = double.tryParse(_stats['ganancia_hoy']?.toString() ?? '0') ?? 0;
    final viajes = _stats['viajes_hoy']?.toString() ?? '0';
    final rating = _stats['calificacion']?.toString() ?? '0.0';
    final horasOnline = _stats['horas_online']?.toString() ?? '0h';

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(
              icon: Icons.attach_money_rounded,
              label: 'Ganancias Hoy',
              value: _copFormat.format(ganancia),
              color: const Color(0xFF4CAF50),
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              icon: Icons.local_taxi_rounded,
              label: 'Viajes Hoy',
              value: viajes,
              color: const Color(0xFF2196F3),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(
              icon: Icons.star_rounded,
              label: 'Calificación',
              value: rating,
              color: const Color(0xFFFFFF00),
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(
              icon: Icons.timer_rounded,
              label: 'Horas Online',
              value: horasOnline,
              color: const Color(0xFF9C27B0),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlySummary() {
    final gananciaMensual = double.tryParse(_stats['ganancia_mensual']?.toString() ?? '0') ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFF00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFFFFF00)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ganancia Mensual',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                _copFormat.format(gananciaMensual),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Slightly smaller to fit currency
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionCard() {
    final deuda = double.tryParse(_commissionData['deuda_actual']?.toString() ?? '0') ?? 0;
    final tope = double.tryParse(_commissionData['tope_comision']?.toString() ?? '20000') ?? 20000;
    final debePagar = _commissionData['debe_pagar'] == true;
    final pagoPendiente = _commissionData['pago_pendiente'] == true;
    final porcentaje = tope > 0 ? (deuda / tope).clamp(0.0, 1.0) : 0.0;

    Color barColor;
    if (debePagar) {
      barColor = const Color(0xFFf5576c);
    } else if (porcentaje > 0.7) {
      barColor = Colors.orange;
    } else {
      barColor = const Color(0xFF4CAF50);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: debePagar
                  ? const Color(0xFFf5576c).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    debePagar ? Icons.warning_amber_rounded : Icons.account_balance_wallet_rounded,
                    color: debePagar ? const Color(0xFFf5576c) : const Color(0xFFFFFF00),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Estado de Comisión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deuda: ${_copFormat.format(deuda)}',
                    style: TextStyle(
                      color: debePagar ? const Color(0xFFf5576c) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tope: ${_copFormat.format(tope)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: porcentaje,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: barColor,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(porcentaje * 100).toStringAsFixed(0)}% del tope',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
              if (pagoPendiente) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFF00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFFF00).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: Color(0xFFFFFF00), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Comprobante en revisión',
                        style: TextStyle(color: Color(0xFFFFFF00), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
