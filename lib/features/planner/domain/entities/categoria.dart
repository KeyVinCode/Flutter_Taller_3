/// Categoría de un evento: objeto de negocio puro.
///
/// Refleja la tabla `categorias` del esquema SQL y no depende de Flutter,
/// de la red ni de la base de datos.
class Categoria {
  const Categoria({
    this.id,
    required this.usuarioId,
    required this.nombre,
    this.colorHex = '#2196F3',
    this.createdAt,
  });

  final int? id;
  final int usuarioId;
  final String nombre;
  final String colorHex;
  final DateTime? createdAt;

  bool get tieneNombreValido => nombre.trim().isNotEmpty;
}
