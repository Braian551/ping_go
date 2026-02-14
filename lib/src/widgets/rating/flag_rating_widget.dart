import 'package:flutter/material.dart';

/// Widget de reporte con banderas rojas (1-5)
/// Incluye campo de texto para el motivo del reporte
class FlagRatingWidget extends StatelessWidget {
  final int currentFlags;
  final ValueChanged<int>? onFlagsChanged;
  final String motivoText;
  final ValueChanged<String>? onMotivoChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool readOnly;

  const FlagRatingWidget({
    super.key,
    required this.currentFlags,
    this.onFlagsChanged,
    this.motivoText = '',
    this.onMotivoChanged,
    this.size = 40,
    this.activeColor = const Color(0xFFE53935),
    this.inactiveColor = Colors.grey,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Banderas
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final flagNumber = index + 1;
            final isActive = flagNumber <= currentFlags;
            
            return GestureDetector(
              onTap: readOnly ? null : () => onFlagsChanged?.call(flagNumber),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  scale: isActive ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isActive ? Icons.flag_rounded : Icons.flag_outlined,
                    color: isActive ? activeColor : inactiveColor,
                    size: size,
                  ),
                ),
              ),
            );
          }),
        ),
        
        // Campo de motivo (solo si hay banderas seleccionadas)
        if (currentFlags > 0 && !readOnly) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              onChanged: onMotivoChanged,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '¿Por qué reportas? (obligatorio)',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: activeColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El reporte será revisado por el administrador',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
        
        // Mostrar motivo en modo lectura
        if (readOnly && motivoText.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: activeColor.withOpacity(0.3)),
            ),
            child: Text(
              motivoText,
              style: TextStyle(color: Colors.grey[300]),
            ),
          ),
        ],
      ],
    );
  }
}
