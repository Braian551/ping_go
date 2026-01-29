import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/global/services/admin/admin_service.dart';
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
}
