import '../entities/categoria.dart';
import '../repositories/agenda_repository.dart';

/// Caso de uso: listar las categorías del usuario autenticado.
class ListarCategorias {
  const ListarCategorias(this.repository);

  final AgendaRepository repository;

  Future<List<Categoria>> call({required int usuarioId}) async {
    if (usuarioId <= 0) {
      throw ArgumentError('El usuario es obligatorio para listar categorías.');
    }
    return repository.listarCategorias(usuarioId: usuarioId);
  }
}
