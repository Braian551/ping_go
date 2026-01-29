import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ping_go/src/features/conductor/services/conductor_service.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';

class ConductorRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic>? userSession;

  const ConductorRegistrationScreen({
    super.key,
    this.userSession,
  });

  @override
  State<ConductorRegistrationScreen> createState() => _ConductorRegistrationScreenState();
}

class _ConductorRegistrationScreenState extends State<ConductorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Controladores
  final _licenciaController = TextEditingController();
  final _placaController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _colorController = TextEditingController();
  
  // Variables de estado
  String _tipoVehiculo = 'motocicleta';
  DateTime? _vencimientoLicencia;
  
  // Listas
  final List<String> _tiposVehiculo = ['motocicleta', 'carro', 'furgoneta', 'camion'];

  @override
  void dispose() {
    _licenciaController.dispose();
    _placaController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 años
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFFFF00),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A1A1A),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _vencimientoLicencia) {
      setState(() {
        _vencimientoLicencia = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vencimientoLicencia == null) {
      CustomSnackbar.showError(context, message: 'Selecciona fecha de vencimiento');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener ID de usuario si no vino en props
      int? userId;
      if (widget.userSession != null && widget.userSession!['id'] != null) {
        userId = int.tryParse(widget.userSession!['id'].toString());
      } else {
        final session = await UserService.getSavedSession();
        if (session != null) {
          userId = int.tryParse(session['id'].toString());
        }
      }

      if (userId == null) {
        throw Exception('No se pudo identificar al usuario');
      }

      final result = await ConductorService.submitVerification(
        usuarioId: userId,
        numeroLicencia: _licenciaController.text,
        vencimientoLicencia: _vencimientoLicencia!.toIso8601String().split('T')[0],
        tipoVehiculo: _tipoVehiculo,
        placaVehiculo: _placaController.text,
        marcaVehiculo: _marcaController.text.isNotEmpty ? _marcaController.text : null,
        modeloVehiculo: _modeloController.text.isNotEmpty ? _modeloController.text : null,
        colorVehiculo: _colorController.text.isNotEmpty ? _colorController.text : null,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        CustomSnackbar.showSuccess(
          context, 
          message: 'Solicitud enviada correctamente',
        );
        Navigator.pop(context, true); // Retornar true para indicar éxito
      } else {
        CustomSnackbar.showError(
          context, 
          message: result['message'] ?? 'Error al enviar solicitud',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, message: 'Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          image: DecorationImage(
            image: const AssetImage('assets/images/map_bg.png'), // Placeholder or create
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Información de Licencia'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _licenciaController,
                      label: 'Número de Licencia',
                      icon: Icons.badge_outlined,
                      validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Información del Vehículo'),
                    const SizedBox(height: 16),
                    _buildDropdownType(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _placaController,
                      label: 'Placa del Vehículo',
                      icon: Icons.directions_car_outlined,
                      validator: (v) => v?.isEmpty == true ? 'Requerido' : null,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(
                          controller: _marcaController,
                          label: 'Marca',
                          icon: Icons.branding_watermark_outlined,
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(
                          controller: _modeloController,
                          label: 'Modelo',
                          icon: Icons.model_training,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _colorController,
                      label: 'Color',
                      icon: Icons.color_lens_outlined,
                    ),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFF00).withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFFF00), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFFF00).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.person_pin_circle_rounded, color: Color(0xFFFFFF00), size: 40),
        ),
        const SizedBox(height: 20),
        const Text(
          'Conviértete en Conductor',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Completa el formulario para empezar a ganar dinero con PingGo',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFFFF00),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            textCapitalization: textCapitalization,
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: Icon(icon, color: const Color(0xFFFFFF00).withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _vencimientoLicencia == null 
                    ? Colors.white.withOpacity(0.1) 
                    : const Color(0xFFFFFF00).withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: const Color(0xFFFFFF00).withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _vencimientoLicencia == null
                        ? 'Vencimiento de Licencia'
                        : '${_vencimientoLicencia!.day}/${_vencimientoLicencia!.month}/${_vencimientoLicencia!.year}',
                    style: TextStyle(
                      color: _vencimientoLicencia == null 
                          ? Colors.white.withOpacity(0.6) 
                          : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownType() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _tipoVehiculo,
              dropdownColor: const Color(0xFF1A1A1A),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFFF00)),
              isExpanded: true,
              items: _tiposVehiculo.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(
                        _getVehicleIcon(value),
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(value[0].toUpperCase() + value.substring(1)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) => setState(() => _tipoVehiculo = newValue!),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'motocicleta': return Icons.two_wheeler;
      case 'carro': return Icons.directions_car;
      case 'furgoneta': return Icons.airport_shuttle;
      case 'camion': return Icons.local_shipping;
      default: return Icons.directions_car;
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFFF00),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              )
            : const Text(
                'ENVIAR SOLICITUD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}
