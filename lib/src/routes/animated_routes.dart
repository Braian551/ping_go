import 'package:flutter/material.dart';

/// Una ruta de página reutilizable que desvanece y desliza la nueva página desde abajo (o desde el offset dado).
/// Úsala en lugar de MaterialPageRoute para animaciones de entrada más suaves.
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Offset beginOffset;

  FadeSlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 350),
    this.beginOffset = const Offset(0, 0.08), // ligero movimiento hacia arriba
    super.settings,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: SlideTransition(
                position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
                child: child,
              ),
            );
          },
        );
}
