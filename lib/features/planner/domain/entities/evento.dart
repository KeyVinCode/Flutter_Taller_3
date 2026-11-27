/// Evento de la agenda: objeto de negocio puro.
///
/// Refleja la tabla `eventos` del esquema SQL y no depende de Flutter,
/// de la red ni de la base de datos.
class Evento {
  const Evento({
    this.id,
    required this.usuarioId,
    this.categoriaId,
    required this.titulo,
    this.descripcion,
    this.ubicacion,
    required this.fechaInicio,
    required this.fechaFin,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int usuarioId;
  final int? categoriaId;
  final String titulo;
  final String? descripcion;
  final String? ubicacion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get tieneTituloValido => titulo.trim().isNotEmpty;

  bool get tieneFechasValidas => !fechaFin.isBefore(fechaInicio);
}
