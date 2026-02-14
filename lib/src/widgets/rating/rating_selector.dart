import 'package:flutter/material.dart';
import 'star_rating_widget.dart';
import 'flag_rating_widget.dart';

/// Tipo de calificación
enum TipoCalificacion { estrellas, bandera }

/// Selector que permite elegir entre estrellas (positivo) o banderas (reporte)
class RatingSelector extends StatefulWidget {
  final int initialRating;
  final TipoCalificacion initialTipo;
  final String initialMotivo;
  final Function(int rating, TipoCalificacion tipo, String motivo)? onChanged;
  final bool showToggle;

  const RatingSelector({
    super.key,
    this.initialRating = 0,
    this.initialTipo = TipoCalificacion.estrellas,
    this.initialMotivo = '',
    this.onChanged,
    this.showToggle = true,
  });

  @override
  State<RatingSelector> createState() => _RatingSelectorState();
}

class _RatingSelectorState extends State<RatingSelector> {
  late TipoCalificacion _tipo;
  late int _rating;
  late String _motivo;

  @override
  void initState() {
    super.initState();
    _tipo = widget.initialTipo;
    _rating = widget.initialRating;
    _motivo = widget.initialMotivo;
  }

  void _notifyChange() {
    widget.onChanged?.call(_rating, _tipo, _motivo);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título según tipo
        Text(
          _tipo == TipoCalificacion.estrellas
              ? '¿Cómo fue tu experiencia?'
              : '¿Cuál fue el problema?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Widget de calificación según tipo
        if (_tipo == TipoCalificacion.estrellas)
          StarRatingWidget(
            currentRating: _rating,
            onRatingChanged: (value) {
              setState(() => _rating = value);
              _notifyChange();
            },
          )
        else
          FlagRatingWidget(
            currentFlags: _rating,
            motivoText: _motivo,
            onFlagsChanged: (value) {
              setState(() => _rating = value);
              _notifyChange();
            },
            onMotivoChanged: (value) {
              setState(() => _motivo = value);
              _notifyChange();
            },
          ),
        
        const SizedBox(height: 20),
        
        // Toggle entre modos (opcional)
        if (widget.showToggle)
          GestureDetector(
            onTap: () {
              setState(() {
                _tipo = _tipo == TipoCalificacion.estrellas
                    ? TipoCalificacion.bandera
                    : TipoCalificacion.estrellas;
                _rating = 0;
                _motivo = '';
              });
              _notifyChange();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _tipo == TipoCalificacion.bandera
                      ? const Color(0xFFE53935)
                      : Colors.grey[700]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _tipo == TipoCalificacion.estrellas
                        ? Icons.flag_outlined
                        : Icons.star_outline_rounded,
                    size: 18,
                    color: _tipo == TipoCalificacion.bandera
                        ? const Color(0xFFE53935)
                        : Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tipo == TipoCalificacion.estrellas
                        ? 'Reportar problema'
                        : 'Calificar con estrellas',
                    style: TextStyle(
                      color: _tipo == TipoCalificacion.bandera
                          ? const Color(0xFFE53935)
                          : Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
