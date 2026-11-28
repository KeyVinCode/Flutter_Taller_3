import '../entities/categoria.dart';
import '../repositories/agenda_repository.dart';

/// Caso de uso: crear una categoría para organizar los eventos.
class CrearCategoria {
  const CrearCategoria(this.repository);

  final AgendaRepository repository;

  Future<Categoria> call(Categoria categoria) async {
    if (categoria.usuarioId <= 0) {
      throw ArgumentError(
        'El usuario es obligatorio para crear una categoría.',
      );
    }
    if (!categoria.tieneNombreValido) {
      throw ArgumentError('El nombre de la categoría no puede estar vacío.');
    }
    return repository.crearCategoria(categoria);
  }
}
