// lib/src/features/admin/presentation/screens/statistics_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/global/services/admin/admin_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  final int adminId;

  const StatisticsScreen({super.key, required this.adminId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  String _selectedPeriod = '7d';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadStats();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final response = await AdminService.getDashboardStats(
      adminId: widget.adminId,
      period: _selectedPeriod,
    );

    if (!mounted) return;

    if (response['success'] == true && response['data'] != null) {
      setState(() {
        _stats = response['data'];
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: _isLoading ? _buildShimmerLoading() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.8)),
          ),
        ),
      ),
      leading: null,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFF00), Color(0xFFFFD700)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFFF00).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Métricas y análisis',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFFF00)),
            onPressed: _loadStats,
            tooltip: 'Actualizar',
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(height: 60),
            const SizedBox(height: 20),
            _buildShimmerBox(height: 300),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: List.generate(4, (_) => _buildShimmerBox(height: 100)),
            ),
            const SizedBox(height: 20),
            _buildShimmerBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({required double height, double? width}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A1A),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          color: const Color(0xFFFFFF00),
          backgroundColor: const Color(0xFF1A1A1A),
          onRefresh: _loadStats,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  _buildRegistrosChart(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),
                  _buildDistributionChart(),
                  const SizedBox(height: 24),
                  _buildDriverRankings(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverRankings() {
    final topConductores =
        (_stats?['rankings']?['top_conductores'] as List?) ?? [];
    final worstConductores =
        (_stats?['rankings']?['worst_conductores'] as List?) ?? [];
    final sortedWorstConductores = List<dynamic>.from(worstConductores)
      ..sort((a, b) {
        final aScore = _getFlagScore(a as Map<String, dynamic>);
        final bScore = _getFlagScore(b as Map<String, dynamic>);
        return bScore.compareTo(aScore);
      });

    if (topConductores.isEmpty && worstConductores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ranking de Conductores',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        if (topConductores.isNotEmpty)
          _buildRankingList(
            'Mejores Conductores',
            topConductores,
            const Color(0xFFFFD700), // Dorado
            Icons.emoji_events_rounded,
          ),
        if (topConductores.isNotEmpty && sortedWorstConductores.isNotEmpty)
          const SizedBox(height: 20),
        if (sortedWorstConductores.isNotEmpty)
          _buildRankingList(
            'Conductores en Riesgo',
            sortedWorstConductores,
            const Color(0xFFf5576c), // Rojo
            Icons.warning_amber_rounded,
          ),
      ],
    );
  }

  Widget _buildRankingList(
    String title,
    List<dynamic> drivers,
    Color accentColor,
    IconData icon,
  ) {
    final isRiskSection = title == 'Conductores en Riesgo';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...drivers.asMap().entries.map((entry) {
                final index = entry.key;
                final driver = entry.value;
                final nombre = '${driver['nombre']} ${driver['apellido']}'
                    .trim();
                final rating =
                    double.tryParse(
                      driver['calificacion_promedio']?.toString() ?? '0',
                    ) ??
                    0.0;
                final count =
                    int.tryParse(
                      driver['total_calificaciones']?.toString() ?? '0',
                    ) ??
                    0;
                final flagScore = _getFlagScore(driver);
                final totalFlags =
                    int.tryParse(driver['total_banderas']?.toString() ?? '0') ??
                    0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre.isEmpty ? 'Conductor sin nombre' : nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$count calif. | $totalFlags reportes',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: accentColor.withOpacity(0.3),
                              ),
                            ),
                            child: isRiskSection
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.flag_rounded,
                                        color: accentColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_formatScore(flagScore)}/5',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: accentColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          if (!isRiskSection && flagScore > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${flagScore.toStringAsFixed(1)}% reportes',
                                style: TextStyle(
                                  color: Colors.redAccent.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  double _getFlagScore(Map<String, dynamic> driver) {
    final totalFlags =
        int.tryParse(driver['total_banderas']?.toString() ?? '0') ?? 0;
    final rawAvg =
        double.tryParse(driver['promedio_banderas']?.toString() ?? '0') ?? 0.0;

    if (totalFlags <= 0 && rawAvg <= 0) return 0;

    if (rawAvg > 0 && rawAvg <= 5) {
      return rawAvg;
    }

    if (rawAvg > 5) {
      final scaled = (rawAvg / 100) * 5;
      return scaled.clamp(1, 5).toDouble();
    }

    return totalFlags.clamp(1, 5).toDouble();
  }

  String _formatScore(double score) {
    return score % 1 == 0 ? score.toStringAsFixed(0) : score.toStringAsFixed(1);
  }

  Widget _buildPeriodSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              _buildPeriodButton('7 días', '7d'),
              _buildPeriodButton('30 días', '30d'),
              _buildPeriodButton('Todo', 'all'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!mounted) return;
          setState(() => _selectedPeriod = value);
          _loadStats();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFF00) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrosChart() {
    final registros = _stats?['registros_ultimos_7_dias'] ?? [];

    if (registros.isEmpty) {
      return _buildEmptyState();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFF00).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFFFFFF00),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registros Recientes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          _selectedPeriod == 'all'
                              ? 'Histórico completo'
                              : (_selectedPeriod == '30d'
                                    ? 'Últimos 30 días'
                                    : 'Últimos 7 días'),
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval:
                              1, // Llamamos para cada punto para controlar exactitud
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final int index = value.toInt();
                            if (index < 0 || index >= registros.length)
                              return const SizedBox.shrink();

                            // Lógica de espaciado dinámico
                            int showEvery = 1;
                            if (registros.length > 60) {
                              showEvery = 20; // 90 días (All)
                            } else if (registros.length > 15) {
                              showEvery = 7; // 30 días
                            } else if (registros.length > 7) {
                              showEvery = 2; // 14 días (si existiera)
                            }

                            // Siempre mostrar el primer y el último punto
                            bool isEdge =
                                index == 0 || index == registros.length - 1;
                            bool isStep = index % showEvery == 0;

                            // Evitar colisión con el punto final
                            if (isStep &&
                                !isEdge &&
                                (registros.length - 1 - index) <
                                    (showEvery * 0.75)) {
                              isStep = false;
                            }

                            if (!isEdge && !isStep)
                              return const SizedBox.shrink();

                            final fecha =
                                registros[index]['fecha']?.toString() ?? '';
                            final parts = fecha.split('-');
                            if (parts.length >= 3) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  '${parts[2]}/${parts[1]}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 9,
                                    fontWeight: isEdge
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          // Ajustar intervalo Y según el máximo
                          interval: _getMaxValue(registros) > 10
                              ? (_getMaxValue(registros) / 5).ceilToDouble()
                              : 1,
                          reservedSize: 35,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            // No mostrar 0 si está muy pegado al eje o si es decimal
                            if (value != value.toInt().toDouble())
                              return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _getMaxValue(registros) > 10
                          ? (_getMaxValue(registros) / 5).ceilToDouble()
                          : 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withOpacity(0.03),
                        strokeWidth: 1,
                      ),
                    ),
                    minX: 0,
                    maxX: (registros.length - 1).toDouble(),
                    minY: 0,
                    maxY:
                        (_getMaxValue(registros) +
                        0.5), // Pequeño margen arriba
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getChartSpots(registros),
                        isCurved: true,
                        curveSmoothness: 0.35,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFF00), Color(0xFFFFD700)],
                        ),
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show:
                              registros.length <=
                              10, // Solo mostrar puntos en vista de 7 días
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 2.5,
                              color: const Color(0xFFFFFF00),
                              strokeWidth: 1,
                              strokeColor: Colors.black,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFFF00).withOpacity(0.3),
                              const Color(0xFFFFFF00).withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getChartSpots(List<dynamic> registros) {
    return List.generate(registros.length, (index) {
      final cantidad =
          int.tryParse(registros[index]['total']?.toString() ?? '0') ?? 0;
      return FlSpot(index.toDouble(), cantidad.toDouble());
    });
  }

  double _getMaxValue(List<dynamic> registros) {
    double max = 0;
    for (var registro in registros) {
      final cantidad = int.tryParse(registro['total']?.toString() ?? '0') ?? 0;
      if (cantidad > max) max = cantidad.toDouble();
    }
    return max == 0 ? 10 : max;
  }

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insert_chart_outlined_rounded,
                  size: 48,
                  color: Colors.white30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No hay datos disponibles',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Las estadísticas aparecerán aquí',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final users = _stats?['usuarios'] ?? {};
    final solicitudes = _stats?['solicitudes'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Métricas generales',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: [
            _buildStatCard(
              'Total Usuarios',
              users['total_usuarios']?.toString() ?? '0',
              Icons.people_rounded,
              const Color(0xFF667eea),
            ),
            _buildStatCard(
              'Clientes',
              users['total_clientes']?.toString() ?? '0',
              Icons.person_rounded,
              const Color(0xFF11998e),
            ),
            _buildStatCard(
              'Conductores',
              users['total_conductores']?.toString() ?? '0',
              Icons.local_taxi_rounded,
              const Color(0xFFf5576c),
            ),
            _buildStatCard(
              'Solicitudes',
              solicitudes['total_solicitudes']?.toString() ?? '0',
              Icons.receipt_long_rounded,
              const Color(0xFFFFFF00),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionChart() {
    final solicitudes = _stats?['solicitudes'] ?? {};
    final completadas =
        int.tryParse(solicitudes['completadas']?.toString() ?? '0') ?? 0;
    final canceladas =
        int.tryParse(solicitudes['canceladas']?.toString() ?? '0') ?? 0;
    final enProceso =
        int.tryParse(solicitudes['en_proceso']?.toString() ?? '0') ?? 0;
    final total = completadas + canceladas + enProceso;

    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.pie_chart_rounded,
                      color: Color(0xFF667eea),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distribución de Solicitudes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Estado actual',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: completadas.toDouble(),
                              title:
                                  '${((completadas / total) * 100).toStringAsFixed(0)}%',
                              color: const Color(0xFF11998e),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: canceladas.toDouble(),
                              title:
                                  '${((canceladas / total) * 100).toStringAsFixed(0)}%',
                              color: const Color(0xFFf5576c),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: enProceso.toDouble(),
                              title:
                                  '${((enProceso / total) * 100).toStringAsFixed(0)}%',
                              color: const Color(0xFFFFFF00),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem(
                          'Completadas',
                          completadas,
                          const Color(0xFF11998e),
                        ),
                        const SizedBox(height: 12),
                        _buildLegendItem(
                          'Canceladas',
                          canceladas,
                          const Color(0xFFf5576c),
                        ),
                        const SizedBox(height: 12),
                        _buildLegendItem(
                          'En Proceso',
                          enProceso,
                          const Color(0xFFFFFF00),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
