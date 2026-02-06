import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/conductor_service.dart';
import '../screens/driver_trip_screen.dart';
import '../../../../core/config/app_config.dart';

class ConductorDashboardView extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorDashboardView({super.key, required this.conductorUser});

  @override
  State<ConductorDashboardView> createState() => _ConductorDashboardViewState();
}

class _ConductorDashboardViewState extends State<ConductorDashboardView> {
  bool _isOnline = false;
  Timer? _locationTimer;
  Timer? _assignmentTimer;
  bool _isBusy = false; // To prevent concurrent polling overlaps
  bool _isFetchingStats = false;

  // Stats state
  String _ganancia = '0.00';
  String _viajes = '0';
  String _calificacion = '5.0';
  String _horas = '0h';
  String? _vehicleType;

  @override
  void initState() {
    super.initState();
    _vehicleType = widget.conductorUser['tipo_vehiculo'];
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (_isFetchingStats) return;
    _isFetchingStats = true;

    try {
       final userId = int.parse(widget.conductorUser['id'].toString());
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
           final rawGanancia = double.tryParse(stats['ganancia']?.toString() ?? '0') ?? 0.0;
           // Basic formatting for user request: "2.000"
           // Using regex to add thousands separators to integer part
           final parts = rawGanancia.toStringAsFixed(0).split('.');
           final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
           final formatted = parts[0].replaceAllMapped(regex, (Match m) => '${m[1]}.');
           
           _ganancia = formatted;
           _viajes = stats['viajes']?.toString() ?? '0';
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

  @override
  void dispose() {
    _stopOnlineServices();
    super.dispose();
  }

  void _toggleOnline() async {
    if (_isOnline) {
      _stopOnlineServices();
      setState(() => _isOnline = false);
    } else {
      // Check permissions first
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Necesitamos permiso de ubicación para conectarte.')),
          );
        }
        return;
      }

      setState(() => _isOnline = true);
      _startOnlineServices();
    }
  }

  void _startOnlineServices() {
    // 1. Immediate location update
    _updateLocation();
    
    // 2. Scheduled location updates (every 30s)
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateLocation();
    });

    // 3. Poll for assignments (every 10s)
    _assignmentTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkPendingAssignments();
    });
    
    // Check immediately too
    _checkPendingAssignments();
    
    // Refresh stats
    _fetchStats();
  }

  void _stopOnlineServices() {
    _locationTimer?.cancel();
    _assignmentTimer?.cancel();
    _locationTimer = null;
    _assignmentTimer = null;
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );
      final userId = int.parse(widget.conductorUser['id'].toString());
      
      await ConductorService.actualizarUbicacion(
        conductorId: userId,
        latitud: position.latitude,
        longitud: position.longitude,
      );
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<void> _checkPendingAssignments() async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      final userId = int.parse(widget.conductorUser['id'].toString());
      final assignment = await ConductorService.getPendingAssignments(userId);
      
      if (assignment != null && mounted) {
        // Stop timers while showing dialog/handling request
        _stopOnlineServices(); 
        
        // Show request dialog
        _showRequestDialog(assignment);
      }
    } catch (e) {
      print('Error checking assignments: $e');
    } finally {
      _isBusy = false;
    }
  }

  void _showRequestDialog(Map<String, dynamic> assignment) {
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
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Client Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: (assignment['cliente_foto'] != null)
                          ? NetworkImage(AppConfig.resolveImageUrl(assignment['cliente_foto']))
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
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text('5.0', style: TextStyle(color: Colors.white.withOpacity(0.7))), // Placeholder rating
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Route Info
                _buildAddressRow(Icons.my_location, Colors.white, assignment['direccion_recogida'] ?? 'Ubicación actual'),
                Container(
                  margin: const EdgeInsets.only(left: 11, top: 2, bottom: 2),
                  height: 16,
                  width: 2,
                  color: Colors.grey[700],
                ),
                _buildAddressRow(Icons.location_on, const Color(0xFFFFD700), assignment['direccion_destino'] ?? 'Destino'),
                
                const SizedBox(height: 24),
                
                // Distance/Time
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoChip(Icons.straighten, '${assignment['distancia_estimada']} km'),
                    _buildInfoChip(Icons.timer, '${assignment['tiempo_estimado']} min'),
                    // _buildInfoChip(Icons.attach_money, '\$${assignment['precio_estimado']}'), // If you have price
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                           // Logic to reject
                           final userId = int.parse(widget.conductorUser['id'].toString());
                           final solicitudId = int.parse(assignment['solicitud_id'].toString());
                           
                           Navigator.pop(context); // Close dialog first

                           // Call reject API
                           await ConductorService.rejectAssignment(
                             conductorId: userId, 
                             solicitudId: solicitudId
                           );
                           
                           // Resume services
                           if (_isOnline) _startOnlineServices();
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
                        onPressed: () => _acceptAssignment(assignment),

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

  void _acceptAssignment(Map<String, dynamic> assignment) async {
    Navigator.pop(context); // Close dialog
    
    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
    );

    try {
      final conductorId = int.parse(widget.conductorUser['id'].toString());
      final solicitudId = int.parse(assignment['solicitud_id'].toString());
      
      final result = await ConductorService.aceptarSolicitud(
        conductorId: conductorId,
        solicitudId: solicitudId,
      );

      if (mounted) Navigator.pop(context); // Close loading

      if (result['success'] == true) {
        // Navigate to Trip Screen
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
                vehicleType: _vehicleType,
              ),
            ),
          ).then((_) {
            // Check if we should come back online after trip
            if (_isOnline) _startOnlineServices();
            _fetchStats();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error al aceptar')),
          );
          if (_isOnline) _startOnlineServices(); // Resume polling
        }
      }
    } catch (e) {
       if (mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
           if (_isOnline) _startOnlineServices(); // Resume polling
       }
    }
  }

  Widget _buildAddressRow(IconData icon, Color color, String text) {
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

  Widget _buildInfoChip(IconData icon, String text) {
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
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAvailableRequests() async {
    final userId = int.parse(widget.conductorUser['id'].toString());
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),),
              const SizedBox(height: 24),
              const Text(
                'Solicitudes Activas',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, size: 60, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text('No hay solicitudes activas', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        final isRejected = req['estado_asignacion'] == 'cancelado';
                        
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close list
                            _showRequestDialog(req);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isRejected ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[800],
                                  backgroundImage: (req['cliente_foto'] != null)
                                      ? NetworkImage(AppConfig.resolveImageUrl(req['cliente_foto']))
                                      : null,
                                  child: (req['cliente_foto'] == null)
                                      ? const Icon(Icons.person, size: 20, color: Colors.white54)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${req['cliente_nombre']} ${req['cliente_apellido'] ?? ''}',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.near_me, size: 12, color: Colors.white.withOpacity(0.6)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              req['direccion_recogida'] ?? 'Ubicación',
                                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
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
                                        margin: const EdgeInsets.only(bottom: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                        child: const Text('RECHAZADO', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    Text(
                                      '${req['distancia_estimada']} km',
                                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildGoOnlineButton(),
          const SizedBox(height: 20),
          if (_isOnline) 
            Center(
              child: ElevatedButton.icon(
                onPressed: _showAvailableRequests,
                icon: const Icon(Icons.list_alt),
                label: const Text('Ver Solicitudes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Resumen del día',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGlassStatCard(
                  'Ganancia',
                  '\$$_ganancia',
                  Icons.attach_money_rounded,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGlassStatCard(
                  'Viajes',
                  _viajes,
                  (_vehicleType?.toLowerCase() == 'motocicleta')
                      ? Icons.two_wheeler_rounded
                      : Icons.directions_car_rounded,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGlassStatCard(
                  'Calif.',
                  _calificacion,
                  Icons.star_rounded,
                  const Color(0xFFFFFF00),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGlassStatCard(
                  'Tiempo',
                  _horas,
                  Icons.access_time_filled_rounded,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGoOnlineButton() {
    return Center(
      child: GestureDetector(
        onTap: _toggleOnline,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100), // Circular
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isOnline 
                    ? Colors.green.withOpacity(0.15)
                    : const Color(0xFF1A1A1A).withOpacity(0.6),
                border: Border.all(
                  color: _isOnline ? Colors.green : Colors.white.withOpacity(0.1),
                  width: _isOnline ? 4 : 2,
                ),
                boxShadow: _isOnline ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isOnline ? Icons.power_settings_new_rounded : Icons.power_off_rounded,
                    size: 56,
                    color: _isOnline ? Colors.green : Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isOnline ? 'EN LÍNEA' : 'OFFLINE',
                    style: TextStyle(
                      color: _isOnline ? Colors.green : Colors.white38,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  if (!_isOnline)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Toca para conectar',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
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

  Widget _buildGlassStatCard(String label, String value, IconData icon, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveUrl(String path) {
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '${AppConfig.baseUrl}/$cleanPath'.replaceAll('//ping_go', '/ping_go');
  }
}
