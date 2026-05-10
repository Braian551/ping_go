import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/conductor_status_provider.dart';
import '../../services/conductor_service.dart';
import '../screens/driver_trip_screen.dart';
import '../screens/commission_payment_screen.dart';
import '../../../../core/config/app_config.dart';

class ConductorDashboardView extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorDashboardView({super.key, required this.conductorUser});

  @override
  State<ConductorDashboardView> createState() => _ConductorDashboardViewState();
}

class _ConductorDashboardViewState extends State<ConductorDashboardView> {
  bool _isBusy = false;
  bool _isFetchingStats = false;

  // Stats state
  String _ganancia = '0.00';
  String _viajes = '0';
  String _calificacion = '5.0';
  String _horas = '0h';
  String? _vehicleType;
  bool _debePagar = false;
  String _deudaActual = '0';

  @override
  void initState() {
    super.initState();
    _vehicleType = widget.conductorUser['tipo_vehiculo'];
    _fetchStats();
    _checkCommissionDebt();
  }

  int? _tryGetConductorId() {
    final rawId = widget.conductorUser['id'];
    return int.tryParse(rawId?.toString() ?? '');
  }

  Future<void> _fetchStats() async {
    if (_isFetchingStats) return;
    _isFetchingStats = true;

    try {
      final userId = _tryGetConductorId();
      if (userId == null) return;
      final stats = await ConductorService.getEstadisticas(userId);
      if (mounted) {
        // Fetch profile info to get vehicle type if not loaded
        if (_vehicleType == null) {
          final profile = await ConductorService.getConductorInfo(userId);
          if (profile != null) {
            setState(() {
              _vehicleType = profile['tipo_vehiculo'];
            });
          }
        }

        setState(() {
          // Format currency: 2000.00 -> $ 2.000
          // Using simple replace for now if intl is not available or handled elsewhere,
          // but normally NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(value)
          // Let's manually format to ensure thousands separator
          final rawGanancia =
              double.tryParse(stats['ganancia_hoy']?.toString() ?? '0') ?? 0.0;
          // Basic formatting for user request: "2.000"
          // Using regex to add thousands separators to integer part
          final parts = rawGanancia.toStringAsFixed(0).split('.');
          final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
          final formatted = parts[0].replaceAllMapped(
            regex,
            (Match m) => '${m[1]}.',
          );

          _ganancia = formatted;
          _viajes = stats['viajes_hoy']?.toString() ?? '0';
          _calificacion = stats['calificacion']?.toString() ?? '5.0';
          _horas = stats['horas_online']?.toString() ?? '0h';
        });
      }
    } catch (e) {
      print('Error fetching stats: $e');
    } finally {
      _isFetchingStats = false;
      print('DEBUG: fetchStats completed');
    }
  }

  Future<void> _checkCommissionDebt() async {
    try {
      final userId = _tryGetConductorId();
      if (userId == null) return;
      final result = await ConductorService.getCommissionStatus(userId);
      if (result['success'] == true && mounted) {
        final data = result['data'] ?? {};
        setState(() {
          _debePagar = data['debe_pagar'] == true;
          _deudaActual = data['deuda_actual']?.toString() ?? '0';
        });
      }
    } catch (e) {
      print('Error checking commission debt: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showCommissionBlockedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFf5576c),
              size: 24,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Comisión pendiente',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'Tienes una deuda de comisión de \$$_deudaActual COP. Debes pagarla para conectarte y recibir viajes.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf5576c),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommissionPaymentScreen(
                    conductorUser: widget.conductorUser,
                  ),
                ),
              );
            },
            child: const Text('Ir a pagar'),
          ),
        ],
      ),
    );
  }

  void _toggleOnline() async {
    final statusProvider = Provider.of<ConductorStatusProvider>(
      context,
      listen: false,
    );

    if (!statusProvider.isOnline) {
      await _checkCommissionDebt();
      if (_debePagar) {
        if (mounted) {
          _showCommissionBlockedDialog();
        }
        return;
      }
    }

    try {
      await statusProvider.toggleOnline();
      if (statusProvider.isOnline) {
        _fetchStats();
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        if (message.contains('COMISION_PENDIENTE')) {
          _showCommissionBlockedDialog();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.contains('COMISION_PENDIENTE')
                  ? 'No puedes conectarte: tienes comisión pendiente.'
                  : 'Error: $e',
            ),
          ),
        );
      }
    }
  }

  void _showAvailableRequests() async {
    final userId = _tryGetConductorId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo identificar el conductor')),
        );
      }
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    final requests = await ConductorService.getAvailableRequests(userId);

    if (mounted) Navigator.pop(context); // Close loading

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20)],
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Solicitudes Activas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: requests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 60,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay solicitudes activas',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final req = requests[index];
                          final isRejected =
                              req['estado_asignacion'] == 'cancelado';

                          return InkWell(
                            onTap: () {
                              Navigator.pop(context); // Close list
                              Provider.of<ConductorStatusProvider>(
                                context,
                                listen: false,
                              ).setPendingAssignment(req);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isRejected
                                      ? Colors.red.withOpacity(0.3)
                                      : Colors.green.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage:
                                        (req['cliente_foto'] != null)
                                        ? NetworkImage(
                                            AppConfig.resolveImageUrl(
                                              req['cliente_foto'],
                                            ),
                                          )
                                        : null,
                                    child: (req['cliente_foto'] == null)
                                        ? const Icon(
                                            Icons.person,
                                            size: 20,
                                            color: Colors.white54,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${req['cliente_nombre']} ${req['cliente_apellido'] ?? ''}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.near_me,
                                              size: 12,
                                              color: Colors.white.withOpacity(
                                                0.6,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                req['direccion_recogida'] ??
                                                    'Ubicación',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.6),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (isRejected)
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Text(
                                            'RECHAZADO',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        '${req['distancia_estimada']} km',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = Provider.of<ConductorStatusProvider>(context);
    final isOnline = statusProvider.isOnline;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alerta de comisión
          if (_debePagar)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommissionPaymentScreen(
                      conductorUser: widget.conductorUser,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf5576c), Color(0xFFc0392b)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf5576c).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comisión pendiente',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Deuda: \$$_deudaActual COP • Toca para pagar',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          
          // Estado de conexión (Texto superior)
          Center(
            child: Column(
              children: [
                Text(
                  isOnline ? 'EN LÍNEA' : 'DESCONECTADO',
                  style: TextStyle(
                    color: isOnline ? Colors.greenAccent : Colors.white.withOpacity(0.6),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isOnline 
                      ? 'Buscando solicitudes cercanas...' 
                      : 'Toca el botón para empezar a recibir viajes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Botón circular principal
          _buildGoOnlineButton(isOnline),
          
          const SizedBox(height: 40),
          
          // Botón de solicitudes (si está online)
          if (isOnline)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton.icon(
                  onPressed: _showAvailableRequests,
                  icon: const Icon(Icons.format_list_bulleted_rounded, size: 20),
                  label: const Text(
                    'Ver Solicitudes Activas',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: const Color(0xFFFFFF00), // Amarillo primario
                    elevation: 10,
                    shadowColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(
                        color: const Color(0xFFFFFF00).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

          // Sección de Resumen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Resumen de hoy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Actualizado ahora',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Grid de Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildPremiumStatCard(
                  'Ganancia',
                  '\$$_ganancia',
                  Icons.account_balance_wallet_rounded,
                  const Color(0xFF00E676),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPremiumStatCard(
                  'Viajes',
                  _viajes,
                  (_vehicleType?.toLowerCase() == 'motocicleta')
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_rounded,
                  const Color(0xFFFF9100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPremiumStatCard(
                  'Calificación',
                  _calificacion,
                  Icons.star_rounded,
                  const Color(0xFFFFD700), // Dorado
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPremiumStatCard(
                  'Tiempo',
                  _horas,
                  Icons.timer_rounded,
                  const Color(0xFF29B6F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGoOnlineButton(bool isOnline) {
    return Center(
      child: GestureDetector(
        onTap: _toggleOnline,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOnline 
                ? const Color(0xFF00E676).withOpacity(0.1) 
                : const Color(0xFF161616),
            border: Border.all(
              color: isOnline 
                  ? const Color(0xFF00E676) 
                  : Colors.white.withOpacity(0.05),
              width: isOnline ? 2 : 1,
            ),
            boxShadow: isOnline
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.1),
                      blurRadius: 80,
                      spreadRadius: 30,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.02),
                      blurRadius: 30,
                      spreadRadius: -10,
                      offset: const Offset(0, -10),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: isOnline
                  ? Column(
                      key: const ValueKey('online_icon'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.radar_rounded,
                          size: 64,
                          color: Color(0xFF00E676),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'CONECTADO',
                          style: TextStyle(
                            color: const Color(0xFF00E676).withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      key: const ValueKey('offline_icon'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.power_settings_new_rounded,
                          size: 64,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'CONECTAR',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final value = double.tryParse(price.toString()) ?? 0.0;
    final parts = value.toStringAsFixed(0).split('.');
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return parts[0].replaceAllMapped(regex, (Match m) => '${m[1]}.');
  }

  Widget _buildPremiumStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Icon(
                Icons.arrow_outward_rounded, 
                color: Colors.white.withOpacity(0.15), 
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveUrl(String path) {
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConfig.baseUrl}/$cleanPath'.replaceAll(
      '//ping_go',
      '/ping_go',
    );
  }
}
