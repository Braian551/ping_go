import 'dart:ui';
import 'package:ping_go/src/core/config/app_config.dart';
import '../../../../routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/trip_detail_sheet.dart';
import 'package:ping_go/src/widgets/auth_wrapper.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import 'package:ping_go/src/features/conductor/services/conductor_service.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/trip_request_service.dart';

import 'edit_profile_screen.dart';
import 'payment_methods_screen.dart';

class HomeUserScreen extends StatefulWidget {
  const HomeUserScreen({super.key});

  @override
  State<HomeUserScreen> createState() => _HomeUserScreenState();
}

class _HomeUserScreenState extends State<HomeUserScreen> with TickerProviderStateMixin {
  String? _userName;
  Map<String, dynamic>? _currentUser;
  String? _conductorStatus; // 'pendiente', 'aprobado', 'rechazado', or null
  bool _loading = true;
  int _selectedIndex = 0;
  int _totalViajes = 0;
  late AnimationController _animationController;
  late AnimationController _navAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _navScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
    _requestLocationPermissionOnFirstRun();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _navAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _navScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _navAnimationController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _requestLocationPermissionOnFirstRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRequestedLocation = prefs.getBool('has_requested_location') ?? false;
      
      if (!hasRequestedLocation) {
        // Esperar un poco para que la UI se cargue primero
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (!mounted) return;
        
        // Verificar servicios de ubicación
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Activa los servicios de ubicación para usar Ping Go'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          await prefs.setBool('has_requested_location', true);
          return;
        }
        
        // Solicitar permisos
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.denied || 
            permission == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Necesitamos tu ubicación para ofrecerte viajes cerca de ti'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Permiso otorgado
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Ubicación activada! Ahora puedes solicitar viajes'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
        
        // Marcar como solicitado para no volver a preguntar
        await prefs.setBool('has_requested_location', true);
      }
    } catch (e) {
      // Ignorar errores silenciosamente
      print('Error requesting location: $e');
    }
  }

  Future<void> _loadUserData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final sess = await UserService.getSavedSession();
      if (sess != null) {
        final id = sess['id'] as int?;
        final email = sess['email'] as String?;
        final profile = await UserService.getProfile(userId: id, email: email);
        if (profile != null && profile['success'] == true) {
          final user = profile['user'];
          final name = user != null ? user['nombre'] as String? : null;
          
          // Verificar estado de conductor
          String? status;
          if (id != null) {
             try {
               final conductorProfile = await ConductorService.getConductorProfile(id);
               if (conductorProfile['success'] == true && conductorProfile['data'] != null) {
                 status = conductorProfile['data']['estado_aprobacion'];
               }
             } catch (_) {}
          }

            if (mounted) {
              setState(() {
                _userName = name ?? 'Usuario';
                _currentUser = user; 
                _conductorStatus = status;
              });
              
              // Cargar estadísticas
              if (id != null) {
                try {
                  final stats = await TripRequestService.getUserStats(id);
                  if (mounted) {
                    setState(() {
                      _totalViajes = stats['total_viajes'] ?? 0;
                      _loading = false;
                    });
                  }
                } catch (_) {
                   if (mounted) setState(() => _loading = false);
                }
              } else {
                 if (mounted) setState(() => _loading = false);
              }

              _animationController.forward();
              return;
            }
        }
      }
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map) {
          final emailArg = args['email'] as String?;
          final idArg = args['userId'] as int?;
          if (emailArg != null || idArg != null) {
            final profile = await UserService.getProfile(userId: idArg, email: emailArg);
            if (profile != null && profile['success'] == true) {
              final user = profile['user'];
              final name = user != null ? user['nombre'] as String? : null;
              
              // Verificar estado de conductor
              String? status;
              if (idArg != null) {
                 try {
                   final conductorProfile = await ConductorService.getConductorProfile(idArg);
                   if (conductorProfile['success'] == true && conductorProfile['data'] != null) {
                     status = conductorProfile['data']['estado_aprobacion'];
                   }
                 } catch (_) {}
              }

              if (mounted) {
                setState(() {
                  _userName = name ?? 'Usuario';
                  _currentUser = user;
                  _conductorStatus = status;
                  _loading = false;
                });
                if (idArg != null && emailArg != null) {
                  await UserService.saveSession({'id': idArg, 'email': emailArg});
                }
                _animationController.forward();
                return;
              }
            }
          }
        }
      } catch (_) {}
      if (mounted) {
        setState(() {
          _userName = 'Usuario';
          _loading = false;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(),
      body: _loading ? _buildShimmerLoading() : _buildBody(),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Future<void> _loadUserStats() async {
    if (_currentUser == null || _currentUser!['id'] == null) return;
    try {
      final id = int.tryParse(_currentUser!['id'].toString()) ?? 0;
      final stats = await TripRequestService.getUserStats(id);
      if (mounted) {
        setState(() {
          _totalViajes = stats['total_viajes'] ?? 0;
        });
      }
    } catch (_) {}
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFF00).withOpacity(0.1),
            ),
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFF00),
                    Color(0xFFFFFF00),
                  ],
                ).createShader(bounds);
              },
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'PingGo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [],
    );
  }

  Widget _buildShimmerLoading() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildShimmerBox(height: 80, width: double.infinity),
            const SizedBox(height: 30),
            _buildShimmerBox(height: 24, width: 150),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildShimmerBox(height: 160)),
                const SizedBox(width: 16),
                Expanded(child: _buildShimmerBox(height: 160)),
              ],
            ),
            const SizedBox(height: 30),
            _buildShimmerBox(height: 24, width: 180),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                      child: _buildShimmerBox(height: 120),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildShimmerBox(height: 24, width: 200),
            const SizedBox(height: 16),
            _buildShimmerBox(height: 120, width: double.infinity),
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
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildContent();
      case 1:
        return _buildTripHistoryTab();
      case 2:
        return _buildPaymentsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildContent();
    }
  }

  Widget _buildTripHistoryTab() {
    return SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _currentUser != null && _currentUser!['id'] != null
            ? TripRequestService.getUserHistory(int.tryParse(_currentUser!['id'].toString()) ?? 0)
            : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }

          if (snapshot.hasError) {
             return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final history = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Historial de viajes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (history.isEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: Colors.white.withOpacity(0.3),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sin viajes registrados',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tus viajes aparecerán aquí',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...history.map((trip) => _buildHistoryItem(trip)),
                  const SizedBox(height: 80), // Padding inferrior para navbar
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> trip) {
    final estado = trip['estado'] ?? 'desconocido';
    final fecha = trip['fecha'] ?? '';
    final origen = trip['origen'] ?? 'Origen desconocido';
    final destino = trip['destino'] ?? 'Destino desconocido';
    final costo = double.tryParse(trip['costo']?.toString() ?? '0') ?? 0.0;
    final conductor = trip['conductor'];

    Color statusColor = Colors.grey;
    if (estado == 'completada' || estado == 'finalizado') statusColor = Colors.green;
    else if (estado == 'cancelada') statusColor = Colors.red;
    else if (estado == 'pendiente') statusColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => TripDetailSheet(trip: trip),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        estado.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '\$${_formatCurrency(costo)}',
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.circle, color: Color(0xFFFFD700), size: 12),
                        Container(width: 2, height: 24, color: Colors.grey.withOpacity(0.3)),
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(origen, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 16),
                          Text(destino, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                if (conductor != null) ...[
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: conductor['foto'] != null 
                          ? NetworkImage(_resolveUrl(conductor['foto']))
                          : null,
                        child: conductor['foto'] == null 
                          ? const Icon(Icons.person, size: 14, color: Colors.white)
                          : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conductor['nombre'] ?? 'Conductor',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        fecha,
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  String _resolveUrl(String path) {
    return AppConfig.resolveImageUrl(path);
  }

  Widget _buildPaymentsTab() {
    return const PaymentMethodsScreen(isTab: true);
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildProfileStats(),
                  const SizedBox(height: 24),
                  _buildProfileMenu(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  // Profile Image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFFF00).withOpacity(0.1),
                      image: (_currentUser != null && 
                              _currentUser!['url_imagen_perfil'] != null)
                          ? DecorationImage(
                              image: NetworkImage(
                                AppConfig.resolveImageUrl(_currentUser!['url_imagen_perfil'])
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (_currentUser == null || _currentUser!['url_imagen_perfil'] == null)
                        ? Center(
                            child: Text(
                              _userName != null && _userName!.isNotEmpty ? _userName![0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Color(0xFFFFFF00),
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  // Edit Button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        if (_currentUser != null) {
                           final result = await Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => EditProfileScreen(user: _currentUser!),
                             ),
                           );
                           if (result == true) {
                             // Reload data if updated
                             setState(() => _loading = true);
                             _loadUserData();
                           }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFF00),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, color: Colors.black, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _userName ?? 'Usuario',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.route,
            title: 'Viajes',
            value: '$_totalViajes',
            color: const Color(0xFFFFFF00),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Column(
      children: [
        _buildDynamicConductorButton(),
        const SizedBox(height: 12),
        _buildProfileMenuItem(
          icon: Icons.settings,
          title: 'Configuración',
          onTap: () => CustomSnackbar.showInfo(context, message: 'Función en desarrollo'),
        ),
        const SizedBox(height: 12),
        _buildProfileMenuItem(
          icon: Icons.help_outline,
          title: 'Ayuda y soporte',
          onTap: () => CustomSnackbar.showInfo(context, message: 'Función en desarrollo'),
        ),
        const SizedBox(height: 12),
        _buildProfileMenuItem(
          icon: Icons.logout,
          title: 'Cerrar sesión',
          isLogout: true,
          onTap: () async {
            await UserService.clearSession();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    Color? customColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLogout 
                  ? Colors.red.withOpacity(0.1) 
                  : const Color(0xFF1A1A1A).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLogout 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.2)
                        : (customColor?.withOpacity(0.2) ?? const Color(0xFFFFFF00).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon, 
                    color: isLogout 
                        ? Colors.red 
                        : (customColor ?? const Color(0xFFFFFF00)), 
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isLogout 
                          ? Colors.red 
                          : (customColor ?? Colors.white),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios, 
                  color: isLogout 
                      ? Colors.red.withOpacity(0.5)
                      : (customColor?.withOpacity(0.5) ?? Colors.white.withOpacity(0.3)), 
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildLocationCard(),
                const SizedBox(height: 30),
                _buildServiceCards(),
                const SizedBox(height: 30),
                _buildRecentActivity(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting = 'Buenos días';
    if (hour >= 12 && hour < 18) {
      greeting = 'Buenas tardes';
    } else if (hour >= 18) {
      greeting = 'Buenas noches';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userName ?? 'Usuario',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.selectDestination);
      },
      child: ClipRRect(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFF00),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFF00).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.search, color: Colors.black, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '¿A dónde vas?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Qué necesitas hoy?',
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
              child: _ModernServiceCard(
                icon: Icons.motorcycle,
                title: 'Viaje',
                subtitle: 'Rápido y seguro',
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.selectDestination);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ModernServiceCard(
                icon: Icons.local_shipping_outlined,
                title: 'Envío',
                subtitle: 'Entrega express',
                onTap: () {
                  CustomSnackbar.show(
                    context, 
                    message: 'Función en desarrollo',
                    type: SnackbarType.info,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acceso rápido',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _QuickActionItem(
                icon: Icons.history,
                label: 'Historial',
                onTap: () {
                  Navigator.pushNamed(context, '/trip_history');
                },
              ),
              _QuickActionItem(
                icon: Icons.star_outline,
                label: 'Favoritos',
                onTap: () {
                  Navigator.pushNamed(context, '/favorite_places');
                },
              ),
              _QuickActionItem(
                icon: Icons.help_outline,
                label: 'Ayuda',
                onTap: () {
                  Navigator.pushNamed(context, '/help');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad reciente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1; // Ir a la pestaña de historial
                });
              },
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  color: Color(0xFFFFFF00),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _currentUser != null && _currentUser!['id'] != null
              ? TripRequestService.getUserHistory(int.tryParse(_currentUser!['id'].toString()) ?? 0)
              : Future.value([]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerBox(height: 120, width: double.infinity);
            }

            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.route,
                            color: Colors.white.withOpacity(0.3),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sin actividad reciente',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tus viajes y envíos aparecerán aquí',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Mostrar los últimos 2-3 items
            final recentHistory = history.take(2).toList();
            return Column(
              children: recentHistory.map((trip) => _buildRecentActivityItem(trip)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivityItem(Map<String, dynamic> trip) {
    final estado = trip['estado'] ?? 'desconocido';
    final fecha = trip['fecha'] ?? '';
    final destino = trip['destino'] ?? 'Destino desconocido';
    final costo = double.tryParse(trip['costo']?.toString() ?? '0') ?? 0.0;

    Color statusColor = Colors.grey;
    if (estado == 'completada' || estado == 'finalizado') statusColor = Colors.green;
    else if (estado == 'cancelada') statusColor = Colors.red;
    else if (estado == 'pendiente') statusColor = Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => TripDetailSheet(trip: trip),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFF00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_outlined, color: Color(0xFFFFFF00), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destino,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fecha,
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_formatCurrency(costo)}',
                      style: const TextStyle(color: Color(0xFFFFFF00), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        estado.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNav() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.95),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Inicio'),
                  _buildNavItem(1, Icons.receipt_long_rounded, 'Pedidos'),
                  _buildNavItem(2, Icons.credit_card_rounded, 'Ganancias'),
                  _buildNavItem(3, Icons.person_rounded, 'Perfil'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
          _navAnimationController.reset();
          _navAnimationController.forward();
          if (index == 3) {
            _loadUserStats();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFFF00) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ScaleTransition(
            scale: isSelected ? _navScaleAnimation : const AlwaysStoppedAnimation(1.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBeDriverTap() async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFFF00)),
      ),
    );

    try {
      final session = await UserService.getSavedSession();
      if (session == null || session['id'] == null) {
        if (mounted) Navigator.pop(context); // Cerrar loader
        return;
      }

      final userId = int.parse(session['id'].toString());
      final result = await ConductorService.getConductorProfile(userId);

      if (!mounted) return;
      Navigator.pop(context); // Cerrar loader

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        final status = data['estado_aprobacion'];
        final aprobado = data['aprobado'] == 1 || data['aprobado'] == true;

        if (aprobado && status == 'aprobado') {
          // Ya es conductor aprobado
          Navigator.pushReplacementNamed(
            context, 
            RouteNames.conductorHome,
            arguments: {'conductor_user': session},
          );
        } else if (status == 'pendiente') {
          _showStatusDialog(
            title: 'Solicitud en Revisión',
            description: 'Tu solicitud está siendo procesada por nuestro equipo. Te notificaremos cuando haya una actualización.',
            icon: Icons.hourglass_top_rounded,
            color: Colors.orange,
          );
        } else if (status == 'rechazado') {
          final motivo = data['motivo_rechazo'] ?? 'No especificado';
          _showStatusDialog(
            title: 'Solicitud Rechazada',
            description: 'Motivo: $motivo\n\nPuedes corregir tu información y enviar una nueva solicitud.',
            icon: Icons.cancel_outlined,
            color: Colors.red,
            actionLabel: 'Intentar de nuevo',
            onAction: () {
              Navigator.pop(context); // Cerrar dialogo actual
              Navigator.pushNamed(context, RouteNames.conductorRegistration);
            },
          );
        }
      } else {
        // No hay solicitud previa o error (asumimos no hay solicitud si data es null)
        // Ir a registro
        Navigator.pushNamed(context, RouteNames.conductorRegistration);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loader si hay error
        CustomSnackbar.showError(context, message: 'Error al verificar estado: $e');
      }
    }
  }

  void _showStatusDialog({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    showDialog(
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
                color: const Color(0xFF1A1A1A).withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (actionLabel != null && onAction != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            actionLabel,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 16,
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

  Widget _buildDynamicConductorButton() {
    IconData icon = Icons.drive_eta;
    String title = 'Ser conductor';
    Color? colorOverride;

    if (_conductorStatus == 'pendiente') {
      icon = Icons.hourglass_top_rounded;
      title = 'Solicitud en proceso';
      colorOverride = Colors.orange;
    } else if (_conductorStatus == 'aprobado') {
      icon = Icons.directions_car_filled;
      title = 'Modo Conductor';
      colorOverride = Colors.green;
    } else if (_conductorStatus == 'rechazado') {
      icon = Icons.error_outline_rounded;
      title = 'Solicitud rechazada';
      colorOverride = Colors.red;
    }

    return _buildProfileMenuItem(
      icon: icon,
      title: title,
      onTap: _handleBeDriverTap,
      customColor: colorOverride,
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
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
                color: const Color(0xFF1A1A1A).withOpacity(0.95),
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
                      color: const Color(0xFFFFFF00).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFFFFFF00),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    feature,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esta función estará disponible próximamente.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: const Color(0xFFFFFF00),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
}

// Tarjeta de Servicio Moderna con glassmorphism
class _ModernServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModernServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFF00),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFF00).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.black, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
      ),
    );
  }
}

// Elemento de Acción Rápida
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFF00).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFFFFFF00), size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
