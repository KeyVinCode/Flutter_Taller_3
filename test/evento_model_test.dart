import 'package:actividad_8flutter/features/planner/data/models/evento_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializa y reconstruye todos los campos del esquema eventos', () {
    final model = EventoModel(
      id: 8,
      usuarioId: 3,
      categoriaId: 2,
      titulo: 'Revisión',
      descripcion: 'Descripción',
      ubicacion: 'Sala 4',
      fechaInicio: DateTime.utc(2026, 11, 26, 14),
      fechaFin: DateTime.utc(2026, 11, 26, 15),
      createdAt: DateTime.utc(2026, 11, 20, 10),
      updatedAt: DateTime.utc(2026, 11, 21, 11),
    );

    final json = model.toJson();
    final decoded = EventoModel.fromJson(json);

    expect(decoded.toJson(), json);
    expect(decoded.id, 8);
    expect(decoded.usuarioId, 3);
    expect(decoded.categoriaId, 2);
    expect(decoded.fechaInicio, DateTime.utc(2026, 11, 26, 14));
  });

  test('permite serializar un evento nuevo sin identificadores generados', () {
    final model = EventoModel(
      usuarioId: 3,
      titulo: 'Nueva tarea',
      fechaInicio: DateTime.utc(2026, 11, 26, 14),
      fechaFin: DateTime.utc(2026, 11, 26, 15),
    );

    final decoded = EventoModel.fromJson(model.toJson());

    expect(decoded.id, isNull);
    expect(decoded.createdAt, isNull);
    expect(decoded.updatedAt, isNull);
  });
}
