class EventoModel {
  const EventoModel({
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

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: _asInt(json['id']),
      usuarioId: _asInt(json['usuario_id']),
      categoriaId: json['categoria_id'] == null
          ? null
          : _asInt(json['categoria_id']),
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      ubicacion: json['ubicacion'] as String?,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: DateTime.parse(json['fecha_fin'] as String),
      createdAt: _asDateTime(json['created_at']),
      updatedAt: _asDateTime(json['updated_at']),
    );
  }

  Map<String, Object?> toInsertJson() => {
    'usuario_id': usuarioId,
    'categoria_id': categoriaId,
    'titulo': titulo,
    'descripcion': descripcion,
    'ubicacion': ubicacion,
    'fecha_inicio': fechaInicio.toUtc().toIso8601String(),
    'fecha_fin': fechaFin.toUtc().toIso8601String(),
  };

  Map<String, Object?> toUpdateJson() => {
    ...toInsertJson(),
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  };

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw const FormatException('Se esperaba un identificador entero.');
  }

  static DateTime? _asDateTime(Object? value) =>
      value == null ? null : DateTime.parse(value as String);
}
