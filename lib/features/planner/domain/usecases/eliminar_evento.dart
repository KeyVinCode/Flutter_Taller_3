import '../repositories/agenda_repository.dart';

/// Caso de uso: eliminar un evento del usuario autenticado.
class EliminarEvento {
  const EliminarEvento(this.repository);

  final AgendaRepository repository;

  Future<void> call({required int id, required int usuarioId}) async {
    if (id <= 0) {
      throw ArgumentError('El ID del evento es obligatorio para eliminar.');
    }
    if (usuarioId <= 0) {
      throw ArgumentError('El usuario es obligatorio para eliminar un evento.');
    }
    return repository.eliminarEvento(id: id, usuarioId: usuarioId);
  }
}
