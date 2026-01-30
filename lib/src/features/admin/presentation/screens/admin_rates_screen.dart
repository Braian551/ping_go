import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ping_go/src/global/services/admin/admin_service.dart';
import 'package:ping_go/src/widgets/snackbars/custom_snackbar.dart';
import 'package:intl/intl.dart';

class AdminRatesScreen extends StatefulWidget {
  const AdminRatesScreen({super.key});

  @override
  State<AdminRatesScreen> createState() => _AdminRatesScreenState();
}

class _AdminRatesScreenState extends State<AdminRatesScreen> {
  bool _isLoading = true;
  List<dynamic> _rates = [];
  
  // Cache de controladores para edición
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    for (var group in _controllers.values) {
      for (var controller in group.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);
    try {
      final result = await AdminService.getRates();
      if (result['success'] == true) {
        setState(() {
          _rates = result['data'] ?? [];
          _initializeControllers();
          _isLoading = false;
        });
      } else {
        if (mounted) CustomSnackbar.showError(context, message: result['message']);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) CustomSnackbar.showError(context, message: 'Error cargando tarifas: $e');
      setState(() => _isLoading = false);
    }
  }

  final _currencyFormat = NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 0);

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final numValue = double.tryParse(value.toString()) ?? 0;
    return _currencyFormat.format(numValue).trim();
  }

  double _parseNumber(String text) {
    // Eliminar puntos de separador de miles para parsear correctamente
    final cleanText = text.replaceAll('.', '').replaceAll(',', '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  void _initializeControllers() {
    _controllers.clear();
    for (var rate in _rates) {
      final type = rate['tipo_vehiculo'].toString();
      _controllers[type] = {
        'base': TextEditingController(text: _formatNumber(rate['tarifa_base'])),
        'km': TextEditingController(text: _formatNumber(rate['tarifa_km'])),
        'min': TextEditingController(text: _formatNumber(rate['tarifa_min'])),
        'comision': TextEditingController(text: rate['comision'].toString()), // Comisión suele ser pequeña/decimal
      };
    }
  }

  Future<void> _updateRate(String type) async {
    final controllers = _controllers[type];
    if (controllers == null) return;

    final base = _parseNumber(controllers['base']!.text);
    final km = _parseNumber(controllers['km']!.text);
    final min = _parseNumber(controllers['min']!.text);
    final comision = double.tryParse(controllers['comision']!.text) ?? 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFFF00))),
    );

    try {
      final result = await AdminService.updateRate(
        tipoVehiculo: type,
        base: base,
        km: km,
        min: min,
        comision: comision,
      );

      if (mounted) Navigator.pop(context); // Cerrar loader

      if (result['success'] == true) {
        if (mounted) CustomSnackbar.showSuccess(context, message: 'Tarifa actualizada correctamente');
      } else {
        if (mounted) CustomSnackbar.showError(context, message: result['message'] ?? 'Error al actualizar');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        CustomSnackbar.showError(context, message: 'Error: $e');
      }
    }
  }

  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Restablecer Tarifas', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Desea restablecer todas las tarifas a los valores predeterminados en Pesos Colombianos (COP)?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restablecer', style: TextStyle(color: Color(0xFFFFFF00))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final result = await AdminService.resetRates();
        if (result['success'] == true) {
          if (mounted) CustomSnackbar.showSuccess(context, message: 'Tarifas restablecidas a COP');
          _loadRates(); // Recargar datos
        } else {
          if (mounted) CustomSnackbar.showError(context, message: result['message']);
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) CustomSnackbar.showError(context, message: 'Error: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFF00)))
              : RefreshIndicator(
                  onRefresh: _loadRates,
                  color: const Color(0xFFFFFF00),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(20),
                    itemCount: _rates.length,
                    itemBuilder: (context, index) {
                      final rate = _rates[index];
                      return _buildRateCard(rate);
                    },
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          tooltip: 'Restablecer valores a COP',
          onPressed: _resetToDefault,
        ),
      ],
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
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
      title: const Text(
        'Tarifas y Comisiones',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRateCard(Map<String, dynamic> rate) {
    final type = rate['tipo_vehiculo'].toString();
    final controllers = _controllers[type]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFF00).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getVehicleIcon(type),
                        color: const Color(0xFFFFFF00),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: controllers['base']!,
                        label: 'Tarifa Base',
                        prefix: 'COP',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: controllers['km']!,
                        label: 'x Km',
                        prefix: 'COP',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: controllers['min']!,
                        label: 'x Minuto',
                        prefix: 'COP',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        controller: controllers['comision']!,
                        label: 'Comisión',
                        prefix: '%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateRate(type),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFF00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String prefix,
  }) {
    final isPercent = prefix == '%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Text(
                prefix,
                style: const TextStyle(
                  color: Color(0xFFFFFF00), 
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: isPercent ? [] : [
                    CurrencyInputFormatter(formatter: _currencyFormat)
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motocicleta': return Icons.two_wheeler;
      case 'carro': return Icons.directions_car;
      default: return Icons.directions_car;
    }
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat formatter;

  CurrencyInputFormatter({required this.formatter});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final double value = double.tryParse(cleanText) ?? 0;
    
    final formatted = formatter.format(value).trim();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
