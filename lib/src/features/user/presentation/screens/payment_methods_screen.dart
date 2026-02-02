import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ping_go/src/global/services/auth/user_service.dart';

/// Pantalla de métodos de pago
/// Permite al usuario agregar, editar y eliminar métodos de pago
class PaymentMethodsScreen extends StatefulWidget {
  final bool isTab;
  const PaymentMethodsScreen({super.key, this.isTab = false});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'default_cash',
      'type': 'cash',
      'label': 'Efectivo',
      'isDefault': true,
    },
  ];

  Map<String, dynamic>? _clientStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadClientStats();
  }

  Future<void> _loadClientStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final session = await UserService.getSavedSession();
      final userId = session?['id'];
      
      if (userId != null) {
        final response = await UserService.getClientStats(userId);
        if (response['success'] == true) {
          setState(() {
            _clientStats = response['data'];
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      print('Error loading stats: $e');
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _addPaymentMethod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAddPaymentSheet(),
    );
  }

  void _setDefaultPaymentMethod(String id) {
    setState(() {
      for (var method in _paymentMethods) {
        method['isDefault'] = method['id'] == id;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Método de pago predeterminado actualizado'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deletePaymentMethod(String id) {
    if (id == 'default_cash') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar el método de pago en efectivo'),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar método de pago',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este método de pago?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((method) => method['id'] == id);
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Método de pago eliminado'),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTab) {
      return _buildTabBody();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _buildTabBody(),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTabBody() {
    return RefreshIndicator(
      onRefresh: _loadClientStats,
      color: const Color(0xFFFFFF00),
      backgroundColor: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildAnalyticsSection(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text(
                'Métodos guardados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            _paymentMethods.isEmpty
                ? _buildEmptyState()
                : _buildPaymentMethodsList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  FloatingActionButton _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _addPaymentMethod,
      backgroundColor: const Color(0xFFFFFF00),
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.black),
      label: const Text(
        'Agregar método',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (!widget.isTab) ...[
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              widget.isTab ? 'Ganancias' : 'Mis Pagos',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    final totalSpent = _clientStats?['total_spent'] ?? 0.0;
    final totalTrips = _clientStats?['total_trips'] ?? 0;
    final avgCost = _clientStats?['average_cost'] ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de gastos',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total gastado',
                  value: '\$${_formatCurrency(totalSpent)}',
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFFFFFF00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Viajes',
                  value: totalTrips.toString(),
                  icon: Icons.local_taxi_rounded,
                  color: const Color(0xFF00E676),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Promedio por viaje',
            value: '\$${_formatCurrency(avgCost)}',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF64B5F6),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card_off_rounded,
              color: Color(0xFFFFFF00),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay métodos guardados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Agrega un método de pago adicional',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _paymentMethods.length,
      itemBuilder: (context, index) {
        final method = _paymentMethods[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPaymentMethodCard(method),
        );
      },
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final methodType = method['type'] as String;
    final isDefault = method['isDefault'] as bool;
    final id = method['id'] as String;

    IconData icon;
    String title;
    String subtitle;
    Color iconColor;

    if (methodType == 'cash') {
      icon = Icons.payments_rounded;
      title = 'Efectivo';
      subtitle = 'Pagar al finalizar el viaje';
      iconColor = const Color(0xFF81C784);
    } else if (methodType == 'card') {
      icon = Icons.credit_card_rounded;
      title = '${method['cardType']} •••• ${method['lastFourDigits']}';
      subtitle = 'Vence ${method['expiryDate']}';
      iconColor = const Color(0xFF64B5F6);
    } else {
      icon = Icons.account_balance_wallet_rounded;
      title = method['walletName'] as String;
      subtitle = method['email'] as String;
      iconColor = const Color(0xFFFFB74D);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDefault
                  ? const Color(0xFFFFFF00)
                  : Colors.white.withOpacity(0.1),
              width: isDefault ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDefault)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFFFFFF00), size: 24),
                ],
              ),
              if (!isDefault || methodType != 'cash') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (!isDefault)
                      Expanded(
                        child: _buildActionButton(
                          label: 'Predeterminar',
                          icon: Icons.check_circle_outline_rounded,
                          onTap: () => _setDefaultPaymentMethod(id),
                        ),
                      ),
                    if (!isDefault && id != 'default_cash') const SizedBox(width: 12),
                    if (id != 'default_cash')
                      Expanded(
                        child: _buildActionButton(
                          label: 'Eliminar',
                          icon: Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          onTap: () => _deletePaymentMethod(id),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final buttonColor = color ?? const Color(0xFFFFFF00);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: buttonColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: buttonColor, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: buttonColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Agregar método de pago',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildPaymentOption(
                    icon: Icons.credit_card_rounded,
                    title: 'Tarjeta de crédito/débito',
                    subtitle: 'Visa, Mastercard, etc.',
                    onTap: () {
                      Navigator.pop(context);
                      _showAddCardDialog();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOption(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Billetera digital',
                    subtitle: 'PayPal, Apple Pay, etc.',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Próximamente disponible'),
                          backgroundColor: Colors.black87,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFF00).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFFFFFF00), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.2), size: 16),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Agregar tarjeta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: cardNumberController,
                label: 'Número de tarjeta',
                hint: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: expiryController,
                      label: 'Vencimiento',
                      hint: 'MM/AA',
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: cvvController,
                      label: 'CVV',
                      hint: '123',
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: nameController,
                label: 'Nombre en la tarjeta',
                hint: 'JUAN PEREZ',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (cardNumberController.text.length >= 15 &&
                  expiryController.text.length == 5 &&
                  cvvController.text.length >= 3 &&
                  nameController.text.isNotEmpty) {
                setState(() {
                  _paymentMethods.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'type': 'card',
                    'cardType': 'Visa',
                    'lastFourDigits': cardNumberController.text.substring(
                      cardNumberController.text.length - 4,
                    ),
                    'expiryDate': expiryController.text,
                    'isDefault': false,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card added successfully'),
                    backgroundColor: Color(0xFFFFFF00),
                  ),
                );
              }
            },
            child: const Text('Agregar', style: TextStyle(color: Color(0xFFFFFF00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            counterText: '',
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFFFFF00)),
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Función en desarrollo'),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
