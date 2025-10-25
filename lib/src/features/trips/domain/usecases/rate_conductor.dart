import 'package:ping_go/src/core/error/result.dart';
import 'package:ping_go/src/core/error/failures.dart';
import '../repositories/trip_repository.dart';

/// Use Case: Calificar Conductor
/// 
/// Encapsula la lógica de negocio para que un usuario califique al conductor.
class RateConductor {
  final TripRepository repository;

  RateConductor(this.repository);

  /// Ejecutar el caso de uso
  Future<Result<void>> call({
    required int tripId,
    required int calificacion,
    String? comentario,
  }) async {
    if (tripId <= 0) {
      return Error(ValidationFailure('ID de viaje inválido'));
    }

    if (calificacion < 1 || calificacion > 5) {
      return Error(
        ValidationFailure('La calificación debe estar entre 1 y 5'),
      );
    }

    return await repository.rateConductor(
      tripId: tripId,
      calificacion: calificacion,
      comentario: comentario,
    );
  }
}
