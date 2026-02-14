import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import 'package:intl/intl.dart';

/// Pantalla para gestionar banderas rojas (reportes)
class BanderasRojasScreen extends StatefulWidget {
  final int? targetUserId;
  final String? targetUserName;

  const BanderasRojasScreen({
    super.key,
    this.targetUserId,
    this.targetUserName,
  });

  @override
  State<BanderasRojasScreen> createState() => _BanderasRojasScreenState();
}

class _BanderasRojasScreenState extends State<BanderasRojasScreen> {
  List<Map<String, dynamic>> _banderas = [];
  bool _isLoading = true;
  bool _soloPendientes = true;
  int _pendientesCount = 0;

  @override
  void initState() {
    super.initState();
    // Si estamos viendo el historial de un usuario específico, mostrar todo por defecto
    if (widget.targetUserId != null) {
      _soloPendientes = false;
    }
    _loadBanderas();
  }

  Future<void> _loadBanderas() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await AdminService.getBanderas(
        soloPendientes: _soloPendientes,
        calificadoId: widget.targetUserId,
      );
      
      if (result['success'] == true && mounted) {
        setState(() {
          _banderas = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _pendientesCount = result['pendientes_count'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando reportes: $e')),
        );
      }
    }
  }

  Future<void> _markAsReviewed(int calificacionId, int index) async {
    final success = await AdminService.markBanderaRevisada(calificacionId);
    
    if (success && mounted) {
      setState(() {
        _banderas[index]['revisado_admin'] = 1;
        _pendientesCount = (_pendientesCount - 1).clamp(0, 9999);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte marcado como revisado'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.targetUserName != null 
                    ? 'Reportes de ${widget.targetUserName}' 
                    : 'Reportes', 
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_pendientesCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_pendientesCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Filtro
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() => _soloPendientes = value);
              _loadBanderas();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: true,
                child: Row(
                  children: [
                    Icon(Icons.pending, color: _soloPendientes ? Colors.amber : Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Solo pendientes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: false,
                child: Row(
                  children: [
                    Icon(Icons.list, color: !_soloPendientes ? Colors.amber : Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Todos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _banderas.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadBanderas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _banderas.length,
                    itemBuilder: (context, index) => _buildBanderaCard(_banderas[index], index),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            _soloPendientes ? 'No hay reportes pendientes' : 'No hay reportes',
            style: TextStyle(color: Colors.grey[400], fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildBanderaCard(Map<String, dynamic> bandera, int index) {
    final isRevisada = bandera['revisado_admin'] == 1;
    final calificadorTipo = bandera['calificador_tipo'] ?? '';
    final calificadoTipo = bandera['calificado_tipo'] ?? '';
    
    // Determinar quién reportó a quién
    final reportador = '${bandera['calificador_nombre']} ${bandera['calificador_apellido']}';
    final reportado = '${bandera['calificado_nombre']} ${bandera['calificado_apellido']}';
    final esClienteReportando = calificadorTipo == 'cliente';
    
    return Card(
      color: isRevisada ? Colors.grey[850] : Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRevisada ? Colors.grey[700]! : const Color(0xFFE53935),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      bandera['calificacion'] ?? 1,
                      (_) => const Icon(Icons.flag, color: Color(0xFFE53935), size: 16),
                    ),
                  ),
                ),
                const Spacer(),
                if (isRevisada)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text('Revisado', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pending, color: Colors.orange, size: 14),
                        SizedBox(width: 4),
                        Text('Pendiente', style: TextStyle(color: Colors.orange, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Quién reportó a quién
            Row(
              children: [
                Icon(
                  esClienteReportando ? Icons.person : Icons.drive_eta,
                  color: Colors.grey[500],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      children: [
                        TextSpan(
                          text: reportador,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: esClienteReportando ? ' (cliente)' : ' (conductor)',
                        ),
                        const TextSpan(text: ' reportó a '),
                        TextSpan(
                          text: reportado,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: calificadoTipo == 'cliente' ? ' (cliente)' : ' (conductor)',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Motivo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Motivo:',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bandera['motivo_bandera'] ?? 'Sin motivo especificado',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Fecha y viaje
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(bandera['creado_en']),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.route, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Viaje #${bandera['solicitud_id']}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
            
            // Botón marcar como revisado
            if (!isRevisada) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _markAsReviewed(bandera['id'], index),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Marcar como revisado'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
