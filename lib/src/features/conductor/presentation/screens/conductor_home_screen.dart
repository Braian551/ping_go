import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/conductor_status_provider.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import '../../services/conductor_service.dart';
import '../widgets/conductor_app_bar.dart';
import '../widgets/conductor_bottom_nav.dart';
import '../views/conductor_dashboard_view.dart';
import '../views/conductor_map_view.dart';
import '../views/conductor_statistics_view.dart';
import '../views/conductor_history_view.dart';
import '../views/conductor_profile_view.dart';
import '../../models/vehicle_model.dart';
import 'commission_payment_screen.dart';
import '../../../../core/config/app_config.dart';
import 'driver_trip_screen.dart';

class ConductorHomeScreen extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorHomeScreen({super.key, required this.conductorUser});

  @override
  State<ConductorHomeScreen> createState() => _ConductorHomeScreenState();
}

class _ConductorHomeScreenState extends State<ConductorHomeScreen> {
  int _currentIndex = 0;
  late Map<String, dynamic> _currentUser;

  int? _tryCurrentUserId() {
    final raw = _currentUser['id'];
    return int.tryParse(raw?.toString() ?? '');
  }

  void _syncStatusProviderIdentity() {
    final userId = _tryCurrentUserId();
    if (userId == null || userId <= 0) return;

    final statusProvider = Provider.of<ConductorStatusProvider>(
      context,
      listen: false,
    );
    statusProvider.initialize(userId, _currentUser['tipo_vehiculo']);
  }

  @override
  void initState() {
    super.initState();
    _currentUser = widget.conductorUser;
    // Force refresh to get latest data (including profile image if not in session)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserData();
      _checkLocationPermissions();
      _checkCommissionAlert();

      // Initialize Global Status Provider
      _syncStatusProviderIdentity();
    });
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationDialog(
          'Servicios de ubicación desactivados',
          'Por favor, activa el GPS para poder trabajar como conductor.',
          onAction: () => Geolocator.openLocationSettings(),
        );
      }
      return;
    }

    // 2. Verificar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Es obligatorio permitir la ubicación para usar el modo conductor.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationDialog(
          'Permisos de ubicación denegados',
          'Has denegado permanentemente los permisos. Debes activarlos desde la configuración para poder recibir viajes.',
          onAction: () => Geolocator.openAppSettings(),
        );
      }
      return;
    }
  }

  void _showLocationDialog(
    String title,
    String message, {
    required VoidCallback onAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAction();
            },
            child: const Text(
              'CONFIGURAR',
              style: TextStyle(color: Color(0xFFFFFF00)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshUserData() async {
    try {
      final sess = await UserService.getSavedSession();
      if (sess != null) {
        final userId = sess['id'] as int?;
        final email = sess['email'] as String?;
        if (userId != null) {
          final profile = await UserService.getProfile(
            userId: userId,
            email: email,
          );
          if (profile != null && profile['success'] == true) {
            Map<String, dynamic> updatedUser = Map<String, dynamic>.from(
              profile['user'],
            );

            // Si es conductor, obtener info adicional (como tipo_vehiculo)
            if (updatedUser['tipo_usuario'] == 'conductor') {
              final condInfo = await ConductorService.getConductorInfo(userId);
              if (condInfo != null) {
                updatedUser.addAll(condInfo);
              }
            }

            if (mounted) {
              setState(() {
                // Combinar con los datos actuales para no perder nada
                _currentUser = {..._currentUser, ...updatedUser};
              });
              _syncStatusProviderIdentity();
            }
          }
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  /// Verifica si el conductor debe pagar comisión y muestra alerta
  Future<void> _checkCommissionAlert() async {
    try {
      final userId = _currentUser['id'];
      if (userId == null) return;
      final conductorId = int.tryParse(userId.toString()) ?? 0;
      if (conductorId == 0) return;

      final result = await ConductorService.getCommissionStatus(conductorId);
      if (result['success'] == true && result['data']?['debe_pagar'] == true) {
        if (!mounted) return;
        final data = result['data'];
        final deuda = data['deuda_actual']?.toString() ?? '0';
        final cuenta = data['cuenta_app']?.toString() ?? '';
        final tienePagoPendiente = data['pago_pendiente'] == true;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFf5576c),
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Comisión Pendiente',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu deuda de comisión es de \$$deuda COP.',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (tienePagoPendiente)
                  const Text(
                    'Ya enviaste un comprobante. Espera la aprobación del administrador.',
                    style: TextStyle(color: Color(0xFFFFFF00), fontSize: 13),
                  )
                else
                  const Text(
                    'Debes realizar el pago por transferencia y subir el comprobante.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              if (!tienePagoPendiente)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFF00),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _currentIndex = 4); // Go to Perfil
                  },
                  child: const Text('Ir a Pagar'),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error checking commission alert: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: ConductorAppBar(conductorUser: _currentUser),
      body: Consumer<ConductorStatusProvider>(
        builder: (context, statusProvider, _) {
          // Listen for new assignments and show dialog if found
          if (statusProvider.pendingAssignment != null &&
              !statusProvider.isBusy) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showGlobalRequestDialog(
                context,
                statusProvider,
                statusProvider.pendingAssignment!,
              );
            });
          }

          return SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBody(),
            ),
          );
        },
      ),
      bottomNavigationBar: ConductorBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return ConductorDashboardView(
          key: const ValueKey(0),
          conductorUser: _currentUser,
        );
      case 1:
        return ConductorMapView(
          key: const ValueKey(1),
          vehicleType: _currentUser['tipo_vehiculo'] != null
              ? VehicleType.fromString(_currentUser['tipo_vehiculo'].toString())
              : null,
        );
      case 2:
        return ConductorStatisticsView(
          key: const ValueKey(2),
          conductorUser: _currentUser,
        );
      case 3:
        return ConductorHistoryView(
          key: const ValueKey(3),
          conductorUser: _currentUser,
        );
      case 4:
        return ConductorProfileView(
          key: const ValueKey(4),
          conductorUser: _currentUser,
          onProfileUpdate: _refreshUserData,
        );
      default:
        return ConductorDashboardView(
          key: const ValueKey(0),
          conductorUser: _currentUser,
        );
    }
  }

  void _showGlobalRequestDialog(
    BuildContext context,
    ConductorStatusProvider statusProvider,
    Map<String, dynamic> assignment,
  ) {
    statusProvider.setBusy(true);

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¡Nueva Solicitud!',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Client Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: (assignment['cliente_foto'] != null)
                          ? NetworkImage(
                              AppConfig.resolveImageUrl(
                                assignment['cliente_foto'],
                              ),
                            )
                          : null,
                      backgroundColor: Colors.grey[800],
                      child: (assignment['cliente_foto'] == null)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${assignment['cliente_nombre']} ${assignment['cliente_apellido'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (double.tryParse(
                                        assignment['cliente_calificacion']
                                                ?.toString() ??
                                            '5.0',
                                      ) ??
                                      5.0)
                                  .toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Route Info
                _buildDialogAddressRow(
                  Icons.my_location,
                  Colors.white,
                  assignment['direccion_recogida'] ?? 'Ubicación actual',
                ),
                Container(
                  margin: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
                  height: 16,
                  width: 2,
                  color: Colors.grey[700],
                ),
                _buildDialogAddressRow(
                  Icons.location_on,
                  const Color(0xFFFFD700),
                  assignment['direccion_destino'] ?? 'Destino',
                ),

                const SizedBox(height: 24),

                // Price
                Center(
                  child: Text(
                    '\$ ${_formatDialogPrice(_resolveAssignmentPrice(assignment))}',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Text(
                  'Precio Estimado',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogInfoChip(
                      Icons.straighten,
                      '${assignment['distancia_estimada']} km',
                    ),
                    _buildDialogInfoChip(
                      Icons.timer,
                      '${assignment['tiempo_estimado'] ?? 0} min',
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final userId =
                              int.tryParse(
                                _currentUser['id']?.toString() ?? '0',
                              ) ??
                              0;
                          final solicitudId =
                              int.tryParse(
                                assignment['solicitud_id']?.toString() ?? '0',
                              ) ??
                              0;

                          Navigator.pop(context);
                          statusProvider.clearPendingAssignment();
                          statusProvider.setBusy(false);

                          await ConductorService.rejectAssignment(
                            conductorId: userId,
                            solicitudId: solicitudId,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Rechazar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptGlobalAssignment(
                          statusProvider,
                          assignment,
                          dialogContext: context,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Aceptar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _acceptGlobalAssignment(
    ConductorStatusProvider statusProvider,
    Map<String, dynamic> assignment, {
    required BuildContext dialogContext,
  }) async {
    Navigator.pop(dialogContext);

    if (!mounted) return;
    var isLoadingVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
      ),
    );

    try {
      final conductorId =
          int.tryParse(_currentUser['id']?.toString() ?? '0') ?? 0;
      final solicitudId =
          int.tryParse(assignment['solicitud_id']?.toString() ?? '0') ?? 0;

      final result = await ConductorService.aceptarSolicitud(
        conductorId: conductorId,
        solicitudId: solicitudId,
      );

      if (mounted && isLoadingVisible) {
        Navigator.pop(context);
        isLoadingVisible = false;
      }

      if (result['success'] == true) {
        statusProvider.clearPendingAssignment();
        statusProvider.setBusy(false);

        if (mounted) {
          final position = await Geolocator.getCurrentPosition();
          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DriverTripScreen(
                tripData: assignment,
                conductorLocation: position,
                conductorId: conductorId,
                vehicleType: _currentUser['tipo_vehiculo'],
              ),
            ),
          );
        }
      } else {
        statusProvider.clearPendingAssignment();
        statusProvider.setBusy(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error al aceptar')),
          );
        }
      }
    } catch (e) {
      statusProvider.clearPendingAssignment();
      statusProvider.setBusy(false);
      if (mounted && isLoadingVisible) {
        Navigator.pop(context);
        isLoadingVisible = false;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildDialogAddressRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDialogInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDialogPrice(dynamic price) {
    if (price == null) return '0';
    final value = double.tryParse(price.toString()) ?? 0.0;
    final parts = value.toStringAsFixed(0).split('.');
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return parts[0].replaceAllMapped(regex, (Match m) => '${m[1]}.');
  }

  dynamic _resolveAssignmentPrice(Map<String, dynamic> assignment) {
    const keys = [
      'precio_estimado',
      'precio',
      'precio_aproximado',
      'monto_total',
      'tarifa_base',
      'precio_final',
    ];

    for (final key in keys) {
      final value = assignment[key];
      if (value == null) continue;
      final text = value.toString().trim().toLowerCase();
      if (text.isEmpty || text == 'null') continue;
      return value;
    }

    return null;
  }
}
