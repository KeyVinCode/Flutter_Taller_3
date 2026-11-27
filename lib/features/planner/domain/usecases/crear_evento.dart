import '../entities/evento.dart';
import '../repositories/agenda_repository.dart';

/// Caso de uso: crear un evento de la agenda.
class CrearEvento {
  const CrearEvento(this.repository);

  final AgendaRepository repository;

  Future<Evento> call(Evento evento) async {
    if (evento.usuarioId <= 0) {
      throw ArgumentError('El usuario es obligatorio para crear un evento.');
    }
    if (!evento.tieneTituloValido) {
      throw ArgumentError('El título del evento no puede estar vacío.');
    }
    if (!evento.tieneFechasValidas) {
      throw ArgumentError(
        'La fecha de fin no puede ser anterior a la de inicio.',
      );
    }
    final categoriaId = evento.categoriaId;
    if (categoriaId != null && categoriaId <= 0) {
      throw ArgumentError('La categoría del evento no es válida.');
    }
    return repository.crearEvento(evento);
  }
}
