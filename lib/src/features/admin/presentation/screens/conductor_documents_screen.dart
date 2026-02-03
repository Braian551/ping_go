import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/global/services/admin/admin_service.dart';
import 'package:ping_go/src/core/config/app_config.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';
import 'package:shimmer/shimmer.dart';

class ConductorDocumentsScreen extends StatefulWidget {
  const ConductorDocumentsScreen({super.key});

  @override
  State<ConductorDocumentsScreen> createState() => _ConductorDocumentsScreenState();
}

class _ConductorDocumentsScreenState extends State<ConductorDocumentsScreen> {
  List<dynamic> _conductors = [];
  List<dynamic> _filteredConductors = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConductors();
  }

  Future<void> _loadConductors() async {
    setState(() => _isLoading = true);
    try {
      final response = await AdminService.getConductorsDocs();
      if (response['success'] == true) {
        setState(() {
          _conductors = response['data'] ?? [];
          _filteredConductors = _conductors;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          CustomSnackbar.showError(context, message: response['message'] ?? 'Error al cargar');
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, message: 'Error: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _filterConductors(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredConductors = _conductors;
      } else {
        _filteredConductors = _conductors.where((c) {
          final nombre = '${c['nombre']} ${c['apellido']}'.toLowerCase();
          final placa = (c['placa_vehiculo'] ?? '').toString().toLowerCase();
          return nombre.contains(query.toLowerCase()) || placa.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? _buildShimmerList()
                : _filteredConductors.isEmpty
                    ? _buildEmptyState()
                    : _buildConductorsList(),
          ),
        ],
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
        'Documentos de Conductores',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterConductors,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o placa...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFFFFF00)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildConductorsList() {
    return RefreshIndicator(
      color: const Color(0xFFFFFF00),
      backgroundColor: const Color(0xFF1A1A1A),
      onRefresh: _loadConductors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredConductors.length,
        itemBuilder: (context, index) {
          final conductor = _filteredConductors[index];
          return _buildConductorCard(conductor);
        },
        physics: const BouncingScrollPhysics(),
      ),
    );
  }

  Widget _buildConductorCard(Map<String, dynamic> conductor) {
    final status = conductor['estado_aprobacion'] ?? 'pendiente';
    Color statusColor = Colors.orange;
    if (status == 'aprobado') statusColor = Colors.green;
    if (status == 'rechazado') statusColor = Colors.red;

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
          onTap: () => _showConductorDetails(conductor),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFFFFFF00),
                  backgroundImage: conductor['url_imagen_perfil'] != null
                      ? NetworkImage(AppConfig.resolveImageUrl(conductor['url_imagen_perfil']))
                      : null,
                  child: conductor['url_imagen_perfil'] == null
                      ? Text(
                          (conductor['nombre'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${conductor['nombre']} ${conductor['apellido']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Placa: ${conductor['placa_vehiculo'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConductorDetails(Map<String, dynamic> conductor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: const Color(0xFFFFFF00),
                          backgroundImage: conductor['url_imagen_perfil'] != null
                              ? NetworkImage(AppConfig.resolveImageUrl(conductor['url_imagen_perfil']))
                              : null,
                          child: conductor['url_imagen_perfil'] == null
                              ? Text(
                                  (conductor['nombre'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${conductor['nombre']} ${conductor['apellido']}',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                conductor['email'] ?? 'Sin email',
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                              ),
                              Text(
                                conductor['telefono'] ?? 'Sin teléfono',
                                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Información del Vehículo'),
                    _buildDetailItem(Icons.directions_car, 'Marca/Modelo', 
                      '${conductor['marca_vehiculo']} ${conductor['modelo_vehiculo']} (${conductor['ano_vehiculo'] ?? 'N/A'})'),
                    _buildDetailItem(Icons.palette, 'Color', conductor['color_vehiculo']),
                    _buildDetailItem(Icons.confirmation_number, 'Placa', conductor['placa_vehiculo']),
                    _buildDetailItem(Icons.category, 'Tipo', conductor['tipo_vehiculo']),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Documentación'),
                    _buildDetailItem(Icons.badge, 'Número de Licencia', conductor['numero_licencia']),
                    _buildDetailItem(Icons.event, 'Vencimiento Licencia', conductor['vencimiento_licencia']),
                    _buildDetailItem(Icons.security, 'Aseguradora', conductor['aseguradora'] ?? 'N/A'),
                    _buildDetailItem(Icons.policy, 'Póliza de Seguro', conductor['numero_poliza_seguro'] ?? 'N/A'),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Fotos de Documentos'),
                    const SizedBox(height: 12),
                    if (conductor['foto_licencia_frente'] != null)
                      _buildImagePreview('Licencia Frente', conductor['foto_licencia_frente']),
                    if (conductor['foto_licencia_reverso'] != null)
                      _buildImagePreview('Licencia Reverso', conductor['foto_licencia_reverso']),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(color: Color(0xFFFFFF00), fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              Text(value ?? 'No disponible', style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String label, String path) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            AppConfig.resolveImageUrl(path),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              width: double.infinity,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.broken_image, color: Colors.white24, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFF1A1A1A),
        highlightColor: const Color(0xFF2A2A2A),
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: Colors.white.withOpacity(0.2), size: 64),
          const SizedBox(height: 16),
          Text('No se encontraron conductores', style: TextStyle(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }
}
