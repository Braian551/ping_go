import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/conductor_service.dart';

/// Pantalla para pagar comisión: muestra datos de cuenta, deuda y permite subir comprobante
class CommissionPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const CommissionPaymentScreen({super.key, required this.conductorUser});

  @override
  State<CommissionPaymentScreen> createState() =>
      _CommissionPaymentScreenState();
}

class _CommissionPaymentScreenState extends State<CommissionPaymentScreen> {
  bool _loading = true;
  bool _submitting = false;
  Map<String, dynamic> _data = {};
  File? _selectedImage;
  final _copFormat = NumberFormat('#,###', 'es_CO');

  @override
  void initState() {
    super.initState();
    _loadCommissionStatus();
  }

  Future<void> _loadCommissionStatus() async {
    setState(() => _loading = true);
    final userId = widget.conductorUser['id'];
    final conductorId = int.tryParse(userId?.toString() ?? '0') ?? 0;
    if (conductorId == 0) {
      setState(() => _loading = false);
      return;
    }

    final result = await ConductorService.getCommissionStatus(conductorId);
    if (mounted) {
      setState(() {
        _data = result['success'] == true ? (result['data'] ?? {}) : {};
        _loading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      setState(() => _selectedImage = File(xFile.path));
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                ),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                ),
                title: const Text(
                  'Elegir de galería',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una imagen del comprobante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final userId = widget.conductorUser['id'];
    final conductorId = int.tryParse(userId?.toString() ?? '0') ?? 0;

    final result = await ConductorService.submitCommissionPayment(
      conductorId: conductorId,
      filePath: _selectedImage!.path,
    );

    if (mounted) {
      setState(() => _submitting = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Comprobante enviado exitosamente',
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Error al enviar el comprobante',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Pagar Comisión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.8)),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFFF00)),
            )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final deuda =
        double.tryParse(_data['deuda_actual']?.toString() ?? '0') ?? 0;
    final cuenta = _data['cuenta_app']?.toString() ?? '';
    final pagoPendiente = _data['pago_pendiente'] == true;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Debt card
        _buildInfoCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Deuda Actual',
          value: '\$${_copFormat.format(deuda)} COP',
          color: const Color(0xFFf5576c),
        ),
        const SizedBox(height: 16),

        // Bank account card
        if (cuenta.isNotEmpty) ...[
          _buildInfoCard(
            icon: Icons.account_balance_rounded,
            title: 'Cuenta para Transferencia',
            value: cuenta,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
        ],

        // Pending payment notice
        if (pagoPendiente) ...[
          _buildPendingNotice(),
          const SizedBox(height: 16),
        ],

        // Upload section
        if (!pagoPendiente) ...[
          _buildUploadSection(),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFF00),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: const Color(
                  0xFFFFFF00,
                ).withOpacity(0.3),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Enviar Comprobante',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],

        const SizedBox(height: 16),
        // Instructions
        _buildInstructions(),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

  Widget _buildPendingNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFF00).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFFF00).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: Color(0xFFFFFF00), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comprobante en Revisión',
                  style: TextStyle(
                    color: Color(0xFFFFFF00),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ya enviaste un comprobante de pago. Espera la aprobación del administrador.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comprobante de Transferencia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sube una foto clara del comprobante de tu transferencia bancaria.',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _showImageSourcePicker,
          child: Container(
            width: double.infinity,
            height: _selectedImage != null ? 280 : 160,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedImage != null
                    ? const Color(0xFF4CAF50).withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
                width: 2,
                style: _selectedImage != null
                    ? BorderStyle.solid
                    : BorderStyle.none,
              ),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_selectedImage!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Toca para seleccionar imagen',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'JPG, PNG o WebP (máx 5MB)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Instrucciones',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInstruction(
            '1. Realiza la transferencia al número de cuenta indicado arriba.',
          ),
          _buildInstruction(
            '2. Toma una foto o captura de pantalla del comprobante.',
          ),
          _buildInstruction(
            '3. Sube la imagen y envía. Un administrador revisará tu pago.',
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}
