import '../../domain/entities/evento.dart';

class EventoModel extends Evento {
  const EventoModel({
    super.id,
    required super.usuarioId,
    super.categoriaId,
    required super.titulo,
    super.descripcion,
    super.ubicacion,
    required super.fechaInicio,
    required super.fechaFin,
    super.createdAt,
    super.updatedAt,
  });

  factory EventoModel.fromJson(Map<String, dynamic> json) {
    return EventoModel(
      id: _asOptionalInt(json['id']),
      usuarioId: _asInt(json['usuario_id']),
      categoriaId: _asOptionalInt(json['categoria_id']),
      titulo: _asString(json['titulo'], 'titulo'),
      descripcion: _asOptionalString(json['descripcion'], 'descripcion'),
      ubicacion: _asOptionalString(json['ubicacion'], 'ubicacion'),
      fechaInicio: _asDateTime(json['fecha_inicio'], 'fecha_inicio'),
      fechaFin: _asDateTime(json['fecha_fin'], 'fecha_fin'),
      createdAt: _asOptionalDateTime(json['created_at'], 'created_at'),
      updatedAt: _asOptionalDateTime(json['updated_at'], 'updated_at'),
    );
  }

  factory EventoModel.fromEntity(Evento evento) {
    return EventoModel(
      id: evento.id,
      usuarioId: evento.usuarioId,
      categoriaId: evento.categoriaId,
      titulo: evento.titulo,
      descripcion: evento.descripcion,
      ubicacion: evento.ubicacion,
      fechaInicio: evento.fechaInicio,
      fechaFin: evento.fechaFin,
      createdAt: evento.createdAt,
      updatedAt: evento.updatedAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'usuario_id': usuarioId,
    'categoria_id': categoriaId,
    'titulo': titulo,
    'descripcion': descripcion,
    'ubicacion': ubicacion,
    'fecha_inicio': fechaInicio.toUtc().toIso8601String(),
    'fecha_fin': fechaFin.toUtc().toIso8601String(),
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };

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

  static int? _asOptionalInt(Object? value) =>
      value == null ? null : _asInt(value);

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw const FormatException('Se esperaba un identificador entero.');
  }

  static String _asString(Object? value, String field) {
    if (value is String) return value;
    throw FormatException('El campo "$field" debe ser texto.');
  }

  static String? _asOptionalString(Object? value, String field) {
    if (value == null || value is String) return value as String?;
    throw FormatException('El campo "$field" debe ser texto o nulo.');
  }

  static DateTime _asDateTime(Object? value, String field) {
    if (value is String) return DateTime.parse(value);
    throw FormatException('El campo "$field" debe ser una fecha ISO 8601.');
  }

  static DateTime? _asOptionalDateTime(Object? value, String field) =>
      value == null ? null : _asDateTime(value, field);
}
