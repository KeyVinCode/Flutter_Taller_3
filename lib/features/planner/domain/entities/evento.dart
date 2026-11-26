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
}
