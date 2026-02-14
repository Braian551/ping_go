import 'package:flutter/material.dart';

/// Widget de calificación con estrellas (1-5)
class StarRatingWidget extends StatelessWidget {
  final int currentRating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool readOnly;

  const StarRatingWidget({
    super.key,
    required this.currentRating,
    this.onRatingChanged,
    this.size = 40,
    this.activeColor = const Color(0xFFFFD700),
    this.inactiveColor = Colors.grey,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isActive = starNumber <= currentRating;
        
        return GestureDetector(
          onTap: readOnly ? null : () => onRatingChanged?.call(starNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isActive ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isActive ? activeColor : inactiveColor,
                size: size,
              ),
            ),
          ),
        );
      }),
    );
  }
}
