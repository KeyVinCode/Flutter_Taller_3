import '../entities/evento.dart';
import '../repositories/agenda_repository.dart';

/// Caso de uso: actualizar un evento existente.
class ActualizarEvento {
  const ActualizarEvento(this.repository);

  final AgendaRepository repository;

  Future<Evento> call(Evento evento) async {
    final id = evento.id;
    if (id == null || id <= 0) {
      throw ArgumentError('El ID del evento es obligatorio para actualizar.');
    }
    if (!evento.tieneTituloValido) {
      throw ArgumentError('El título del evento no puede estar vacío.');
    }
    if (!evento.tieneFechasValidas) {
      throw ArgumentError(
        'La fecha de fin no puede ser anterior a la de inicio.',
      );
    }
    return repository.actualizarEvento(evento);
  }
}
