import '../entities/categoria.dart';
import '../entities/evento.dart';

abstract interface class AgendaRepository {
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
  });

  Future<Evento> crearEvento(Evento evento);

  Future<Evento> actualizarEvento(Evento evento);

  Future<void> eliminarEvento({required int id, required int usuarioId});

  Future<List<Categoria>> listarCategorias({required int usuarioId});

  Future<Categoria> crearCategoria(Categoria categoria);
}
