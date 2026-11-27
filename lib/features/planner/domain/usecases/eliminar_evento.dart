import '../repositories/evento_repository.dart';

class EliminarEvento {
  final EventoRepository repository;

  const EliminarEvento(this.repository);

  Future<void> call(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('El ID del evento es obligatorio para eliminar.');
    }
    return repository.eliminarEvento(id);
  }
}