import 'package:actividad_8flutter/core/errors/agenda_repository_exception.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:actividad_8flutter/features/planner/domain/repositories/agenda_repository.dart';

/// Repositorio en memoria para pruebas de presentación.
class FakeAgendaRepository implements AgendaRepository {
  FakeAgendaRepository({List<Evento>? eventos, List<Categoria>? categorias})
    : eventos = List<Evento>.of(eventos ?? const <Evento>[]),
      categorias = List<Categoria>.of(categorias ?? const <Categoria>[]);

  List<Evento> eventos;
  List<Categoria> categorias;

  bool fallarListado = false;
  bool fallarMutacion = false;

  int llamadasListado = 0;
  int? ultimoUsuarioListado;
  DateTime? ultimoDesde;
  DateTime? ultimoHasta;
  Evento? ultimoCreado;
  Evento? ultimoActualizado;
  int? ultimoIdEliminado;
  int? ultimoUsuarioEliminado;

  @override
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
  }) async {
    llamadasListado++;
    ultimoUsuarioListado = usuarioId;
    ultimoDesde = desde;
    ultimoHasta = hasta;
    if (fallarListado) {
      throw const AgendaApiException('El servicio no está disponible.');
    }
    return List<Evento>.of(eventos);
  }

  @override
  Future<Evento> crearEvento(Evento evento) async {
    if (fallarMutacion) {
      throw const AgendaApiException('No se pudo crear el evento.');
    }
    ultimoCreado = evento;
    eventos = <Evento>[...eventos, evento];
    return evento;
  }

  @override
  Future<Evento> actualizarEvento(Evento evento) async {
    if (fallarMutacion) {
      throw const AgendaApiException('No se pudo actualizar el evento.');
    }
    ultimoActualizado = evento;
    eventos = eventos
        .map((actual) => actual.id == evento.id ? evento : actual)
        .toList();
    return evento;
  }

  @override
  Future<void> eliminarEvento({required int id, required int usuarioId}) async {
    if (fallarMutacion) {
      throw const AgendaApiException('No se pudo eliminar el evento.');
    }
    ultimoIdEliminado = id;
    ultimoUsuarioEliminado = usuarioId;
    eventos = eventos.where((evento) => evento.id != id).toList();
  }

  @override
  Future<List<Categoria>> listarCategorias({required int usuarioId}) async {
    if (fallarListado) {
      throw const AgendaApiException('El servicio no está disponible.');
    }
    return List<Categoria>.of(categorias);
  }

  @override
  Future<Categoria> crearCategoria(Categoria categoria) async => categoria;
}
