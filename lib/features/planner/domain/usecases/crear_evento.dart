import '../entities/evento.dart';
import '../repositories/evento_repository.dart';

class CrearEvento {
  final EventoRepository repository;

  const CrearEvento(this.repository);

  Future<Evento> call(Evento evento) async {
    if (evento.titulo.trim().isEmpty) {
      throw ArgumentError('El título del evento no puede estar vacío.');
    }
    if (!evento.tieneFechasValidas) {
      throw ArgumentError('La fecha de fin no puede ser anterior a la de inicio.');
    }
    return repository.crearEvento(evento);
  }
}