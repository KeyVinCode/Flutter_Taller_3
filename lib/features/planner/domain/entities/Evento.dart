import 'categoria.dart';

class Evento {
  final String id;
  final String titulo;
  final String? descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final Categoria categoria;

  const Evento({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.categoria,
  });

  bool get tieneFechasValidas => !fechaFin.isBefore(fechaInicio);
}