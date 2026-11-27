import '../entities/evento.dart';
import '../repositories/agenda_repository.dart';

/// Caso de uso: listar los eventos de un usuario con filtros opcionales.
class ListarEventos {
  const ListarEventos(this.repository);

  final AgendaRepository repository;

  Future<List<Evento>> call({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
  }) async {
    if (usuarioId <= 0) {
      throw ArgumentError('El usuario es obligatorio para listar eventos.');
    }
    if (desde != null && hasta != null && hasta.isBefore(desde)) {
      throw ArgumentError('El rango de fechas no es válido.');
    }
    final categoria = categoriaId;
    if (categoria != null && categoria <= 0) {
      throw ArgumentError('La categoría no es válida.');
    }
    return repository.listarEventos(
      usuarioId: usuarioId,
      desde: desde,
      hasta: hasta,
      categoriaId: categoriaId,
    );
  }
}
