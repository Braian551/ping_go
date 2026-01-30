import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/global/services/admin/admin_service.dart';
import 'package:ping_go/src/global/config/api_config.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';
import 'package:shimmer/shimmer.dart';

class PendingDriversScreen extends StatefulWidget {
  final int adminId;

  const PendingDriversScreen({
    super.key,
    required this.adminId,
  });

  @override
  State<PendingDriversScreen> createState() => _PendingDriversScreenState();
}

class _PendingDriversScreenState extends State<PendingDriversScreen> {
  List<dynamic> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingDrivers();
  }

  Future<void> _loadPendingDrivers() async {
    setState(() => _isLoading = true);
    try {
      final response = await AdminService.getPendingConductors();
      if (response['success'] == true) {
        setState(() {
          _drivers = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        CustomSnackbar.showError(context, message: response['message'] ?? 'Error al cargar');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      CustomSnackbar.showError(context, message: 'Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveDriver(int conductorId) async {
    try {
      // Mostrar confirmación
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Confirmar Aprobación', style: TextStyle(color: Colors.white)),
          content: const Text(
            '¿Estás seguro de aprobar a este conductor? Se cambiará su rol y podrá acceder a la app de conductor.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isLoading = true);
      final response = await AdminService.approveConductor(
        conductorId: conductorId,
        adminId: widget.adminId,
      );

      if (response['success'] == true) {
        CustomSnackbar.showSuccess(context, message: 'Conductor aprobado correctamente');
        _loadPendingDrivers(); // Recargar lista
      } else {
        CustomSnackbar.showError(context, message: response['message'] ?? 'Error al aprobar');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      CustomSnackbar.showError(context, message: 'Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectDriver(int conductorId) async {
    final reasonController = TextEditingController();
    
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Rechazar Solicitud', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el motivo del rechazo para notificar al usuario:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ej: Licencia ilegible, Placa incorrecta...',
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await AdminService.rejectConductor(
        conductorId: conductorId,
        motivo: reason,
      );

      if (response['success'] == true) {
        CustomSnackbar.showSuccess(context, message: 'Solicitud rechazada');
        _loadPendingDrivers();
      } else {
        CustomSnackbar.showError(context, message: response['message'] ?? 'Error al rechazar');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      CustomSnackbar.showError(context, message: 'Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: SafeArea( // Usando SafeArea para evitar solapamiento con AppBar
          child: _isLoading 
            ? _buildShimmerList()
            : _drivers.isEmpty 
                ? _buildEmptyState()
                : _buildDriversList(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Solicitudes de Conductores',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white.withOpacity(0.3), size: 64),
          const SizedBox(height: 16),
          Text(
            'No hay solicitudes pendientes',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFF1A1A1A),
          highlightColor: const Color(0xFF2A2A2A),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriversList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _drivers.length,
      itemBuilder: (context, index) {
        final driver = _drivers[index];
        return _buildDriverCard(driver);
      },
      physics: const BouncingScrollPhysics(),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDriverDetails(driver),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con info de usuario
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFFFF00),
                      child: Text(
                        (driver['nombre'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
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
                            driver['email'] ?? 'Sin email',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: const Text(
                        'Pendiente',
                        style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Detalles del vehículo y licencia
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.badge, 'Licencia:', driver['numero_licencia']),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, 'Vence:', driver['vencimiento_licencia']),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.directions_car, 'Vehículo:', 
                        '${driver['tipo_vehiculo']} - ${driver['marca_vehiculo']} ${driver['modelo_vehiculo']}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.confirmation_number, 'Placa:', driver['placa_vehiculo']),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              // Botones de acción
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectDriver(int.parse(driver['id'].toString())),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approveDriver(int.parse(driver['id'].toString())),
                        icon: const Icon(Icons.check, color: Colors.black),
                        label: const Text('Aprobar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFF00),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverDetails(Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFFFFFF00),
                          backgroundImage: driver['url_imagen_perfil'] != null
                              ? NetworkImage(driver['url_imagen_perfil'])
                              : null,
                          child: driver['url_imagen_perfil'] == null
                              ? Text(
                                  (driver['nombre'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${driver['nombre']} ${driver['apellido']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                driver['email'] ?? 'Sin email',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              if (driver['telefono'] != null)
                                Text(
                                  driver['telefono'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    
                    _buildSectionTitle('Información del Vehículo'),
                    _buildDetailItem(Icons.directions_car, 'Vehículo', 
                      '${driver['marca_vehiculo']} ${driver['modelo_vehiculo']} (${driver['ano_vehiculo'] ?? 'N/A'})'),
                    _buildDetailItem(Icons.palette, 'Color', driver['color_vehiculo']),
                    _buildDetailItem(Icons.confirmation_number, 'Placa', driver['placa_vehiculo']),
                    _buildDetailItem(Icons.numbers, 'Tipo', driver['tipo_vehiculo']),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Licencia y Seguro'),
                    _buildDetailItem(Icons.badge, 'No. Licencia', driver['numero_licencia']),
                    _buildDetailItem(Icons.event, 'Vence Licencia', driver['vencimiento_licencia']),
                    _buildDetailItem(Icons.security, 'Aseguradora', driver['aseguradora'] ?? 'No registrada'),
                    _buildDetailItem(Icons.policy, 'Póliza', driver['numero_poliza_seguro'] ?? 'No registrada'),
                    _buildDetailItem(Icons.event_available, 'Vence Seguro', driver['vencimiento_seguro'] ?? 'No registrado'),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Documentos'),
                    const SizedBox(height: 12),
                    if (driver['foto_licencia_frente'] != null)
                      _buildImagePreview('Licencia Frente', driver['foto_licencia_frente']),
                    if (driver['foto_licencia_reverso'] != null)
                      _buildImagePreview('Licencia Reverso', driver['foto_licencia_reverso']),

                    const SizedBox(height: 30),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _rejectDriver(int.parse(driver['id'].toString()));
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _approveDriver(int.parse(driver['id'].toString()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFF00),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Aprobar', 
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFFFF00),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String label, String relativePath) {
    // Construir URL correcta eliminando '/backend-deploy' si existe en la baseUrl para apuntar a la raíz
    // Esto asume que la estructura es ping_go/backend-deploy y ping_go/uploads
    final baseUrl = 'http://10.0.2.2/ping_go'; // Fallback
    // Idealmente deberíamos importar ApiConfig y procesarlo, pero por simplicidad y robustez aquí:
    
    // Una forma más segura usando ApiConfig real si está disponible
    // String rootUrl = ApiConfig.baseUrl.replaceAll('/backend-deploy', '');
    
    // Hardcoded for now based on known structure or getting from ApiConfig via import if possible.
    // Assuming context knows ApiConfig or we import it.
    // For this snippet, I'll assume we need to import ApiConfig which is already imported in many files.
    // But since I can't easily see imports here, I'll rely on the user having ApiConfig. import is at top.
    
    // The relative path in DB is uploads/conductores/...
    // We need to fetch from http://IP/ping_go/uploads/...
    // ApiConfig.baseUrl is http://IP/ping_go/backend-deploy
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _buildImageUrl(relativePath),
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / 
                          loadingProgress.expectedTotalBytes!
                        : null,
                    color: const Color(0xFFFFFF00),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.white54, size: 40),
                      SizedBox(height: 8),
                      Text('Error cargando imagen', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _buildImageUrl(String relativePath) {
    // ApiConfig.baseUrl example: http://10.0.2.2/ping_go/backend-deploy
    // We want: http://10.0.2.2/ping_go/{relativePath}
    String baseUrl = ApiConfig.baseUrl;
    if (baseUrl.endsWith('/backend-deploy')) {
      baseUrl = baseUrl.replaceAll('/backend-deploy', '');
    }
    // Remove trailing slash if exists to avoid double slash
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    // Correct relative path if it starts with slash (though typically it doesn't from DB)
    if (relativePath.startsWith('/')) {
      relativePath = relativePath.substring(1);
    }
    
    return '$baseUrl/$relativePath';
  }
}
