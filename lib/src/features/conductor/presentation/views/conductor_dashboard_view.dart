import 'dart:ui';
import 'package:flutter/material.dart';

class ConductorDashboardView extends StatefulWidget {
  final Map<String, dynamic> conductorUser;

  const ConductorDashboardView({super.key, required this.conductorUser});

  @override
  State<ConductorDashboardView> createState() => _ConductorDashboardViewState();
}

class _ConductorDashboardViewState extends State<ConductorDashboardView> {
  bool _isOnline = false;

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
          const SizedBox(height: 30),
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
                  '\$0.00',
                  Icons.attach_money_rounded,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGlassStatCard(
                  'Viajes',
                  '0',
                  Icons.local_taxi_rounded,
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
                  '5.0',
                  Icons.star_rounded,
                  const Color(0xFFFFFF00),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGlassStatCard(
                  'Tiempo',
                  '0h',
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
        onTap: () {
          setState(() => _isOnline = !_isOnline);
        },
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
}
