class CategoriaModel {
  const CategoriaModel({
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

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['created_at'];
    return CategoriaModel(
      id: _asInt(json['id']),
      usuarioId: _asInt(json['usuario_id']),
      nombre: json['nombre'] as String,
      colorHex: (json['color_hex'] as String).trim(),
      createdAt: createdAtValue == null
          ? null
          : DateTime.parse(createdAtValue as String),
    );
  }

  Map<String, Object?> toInsertJson() => {
    'usuario_id': usuarioId,
    'nombre': nombre,
    'color_hex': colorHex,
  };

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw const FormatException('Se esperaba un identificador entero.');
  }
}
