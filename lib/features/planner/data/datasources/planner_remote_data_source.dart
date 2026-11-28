import '../../../../core/network/postgrest_client.dart';
import '../models/categoria_model.dart';
import '../models/evento_model.dart';

class PlannerRemoteDataSource {
  const PlannerRemoteDataSource({required this.client});

  final PostgrestClient client;

  Future<List<EventoModel>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
  }) async {
    final query = <String, String>{
      'select': '*',
      'usuario_id': 'eq.$usuarioId',
      'order': 'fecha_inicio.asc',
    };
    if (desde != null) {
      query['fecha_fin'] = 'gte.${desde.toUtc().toIso8601String()}';
    }
    if (hasta != null) {
      query['fecha_inicio'] = 'lte.${hasta.toUtc().toIso8601String()}';
    }
    if (categoriaId != null) {
      query['categoria_id'] = 'eq.$categoriaId';
    }

    final rows = await client.get('eventos', queryParameters: query);
    return _asRows(rows).map(EventoModel.fromJson).toList(growable: false);
  }

  Future<EventoModel> crearEvento(EventoModel evento) async {
    final result = await client.post('eventos', evento.toInsertJson());
    return EventoModel.fromJson(_asSingleRow(result));
  }

  Future<EventoModel> actualizarEvento(EventoModel evento) async {
    final id = evento.id;
    if (id == null) {
      throw ArgumentError.value(evento.id, 'evento.id', 'No puede ser nulo.');
    }
    final result = await client.patch('eventos', {
      'id': 'eq.$id',
      'usuario_id': 'eq.${evento.usuarioId}',
    }, evento.toUpdateJson());
    return EventoModel.fromJson(_asSingleRow(result));
  }

  Future<void> eliminarEvento({required int id, required int usuarioId}) {
    return client.delete('eventos', {
      'id': 'eq.$id',
      'usuario_id': 'eq.$usuarioId',
    });
  }

  Future<List<CategoriaModel>> listarCategorias({
    required int usuarioId,
  }) async {
    final rows = await client.get(
      'categorias',
      queryParameters: {
        'select': '*',
        'usuario_id': 'eq.$usuarioId',
        'order': 'nombre.asc',
      },
    );
    return _asRows(rows).map(CategoriaModel.fromJson).toList(growable: false);
  }

  Future<CategoriaModel> crearCategoria(CategoriaModel categoria) async {
    final result = await client.post('categorias', categoria.toInsertJson());
    return CategoriaModel.fromJson(_asSingleRow(result));
  }

  List<Map<String, dynamic>> _asRows(dynamic result) {
    if (result is! List) {
      throw const FormatException('La API debía devolver una lista de filas.');
    }
    return result
        .map((row) {
          if (row is! Map) {
            throw const FormatException('La API devolvió una fila no válida.');
          }
          return Map<String, dynamic>.from(row);
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _asSingleRow(dynamic result) {
    if (result is List && result.length == 1 && result.single is Map) {
      return Map<String, dynamic>.from(result.single as Map);
    }
    throw const FormatException('La API debía devolver exactamente una fila.');
  }
}
