import '../entities/evento.dart';
import '../repositories/evento_repository.dart';

class ActualizarEvento {
  final EventoRepository repository;

  const ActualizarEvento(this.repository);

  Future<Evento> call(Evento evento) async {
    if (evento.id.trim().isEmpty) {
      throw ArgumentError('El ID del evento es obligatorio para actualizar.');
    }
    if (evento.titulo.trim().isEmpty) {
      throw ArgumentError('El título del evento no puede estar vacío.');
    }
    if (!evento.tieneFechasValidas) {
      throw ArgumentError('La fecha de fin no puede ser anterior a la de inicio.');
    }
    return repository.actualizarEvento(evento);
  }
}