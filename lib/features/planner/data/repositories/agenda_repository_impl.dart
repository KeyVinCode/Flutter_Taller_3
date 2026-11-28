import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../../core/errors/agenda_repository_exception.dart';
import '../../../../core/errors/authentication_required_exception.dart';
import '../../../../core/errors/postgrest_exception.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/evento.dart';
import '../../domain/repositories/agenda_repository.dart';
import '../datasources/planner_remote_data_source.dart';
import '../models/categoria_model.dart';
import '../models/evento_model.dart';

class AgendaRepositoryImpl implements AgendaRepository {
  AgendaRepositoryImpl({required this.remoteDataSource});

  final PlannerRemoteDataSource remoteDataSource;

  static final _sqlStatePattern = RegExp(r'^[0-9A-Z]{5}$');

  @override
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
  }) {
    return _manejarErrores(() async {
      final eventos = await remoteDataSource.listarEventos(
        usuarioId: usuarioId,
        desde: desde,
        hasta: hasta,
        categoriaId: categoriaId,
      );
      return List<Evento>.of(eventos);
    });
  }

  @override
  Future<Evento> crearEvento(Evento evento) {
    return _manejarErrores(
      () => remoteDataSource.crearEvento(EventoModel.fromEntity(evento)),
    );
  }

  @override
  Future<Evento> actualizarEvento(Evento evento) {
    return _manejarErrores(
      () => remoteDataSource.actualizarEvento(EventoModel.fromEntity(evento)),
    );
  }

  @override
  Future<void> eliminarEvento({required int id, required int usuarioId}) {
    return _manejarErrores(
      () => remoteDataSource.eliminarEvento(id: id, usuarioId: usuarioId),
    );
  }

  @override
  Future<List<Categoria>> listarCategorias({required int usuarioId}) {
    return _manejarErrores(() async {
      final categorias = await remoteDataSource.listarCategorias(
        usuarioId: usuarioId,
      );
      return List<Categoria>.of(categorias);
    });
  }

  @override
  Future<Categoria> crearCategoria(Categoria categoria) {
    return _manejarErrores(
      () =>
          remoteDataSource.crearCategoria(CategoriaModel.fromEntity(categoria)),
    );
  }

  Future<T> _manejarErrores<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on http.ClientException catch (error) {
      throw AgendaNetworkException(
        'No fue posible comunicarse con el servicio de agenda.',
        cause: error,
      );
    } on TimeoutException catch (error) {
      throw AgendaNetworkException(
        'La solicitud al servicio de agenda excedió el tiempo de espera.',
        cause: error,
      );
    } on AuthenticationRequiredException catch (error) {
      throw AgendaAuthenticationException(
        'Se requiere una sesión autenticada para acceder a la agenda.',
        cause: error,
      );
    } on PostgrestException catch (error) {
      final code = error.code;
      if (code != null && _sqlStatePattern.hasMatch(code)) {
        throw AgendaSqlException(
          error.message,
          sqlState: code,
          statusCode: error.statusCode,
          details: error.details,
          hint: error.hint,
          cause: error,
        );
      }
      throw AgendaApiException(
        error.message,
        statusCode: error.statusCode,
        code: code,
        details: error.details,
        hint: error.hint,
        cause: error,
      );
    } on FormatException catch (error) {
      throw AgendaDataException(
        'La respuesta de agenda no tiene el formato esperado.',
        cause: error,
      );
    }
  }
}
