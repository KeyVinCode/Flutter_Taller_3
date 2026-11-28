import 'package:flutter_test/flutter_test.dart';

import 'package:actividad_8flutter/core/errors/agenda_repository_exception.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:actividad_8flutter/features/planner/domain/repositories/agenda_repository.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/actualizar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/crear_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/eliminar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_eventos.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_bloc.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_event.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_state.dart';

Evento _evento({int? id = 1, String titulo = 'Reunión'}) => Evento(
  id: id,
  usuarioId: 7,
  titulo: titulo,
  fechaInicio: DateTime(2026, 11, 27, 9),
  fechaFin: DateTime(2026, 11, 27, 10),
);

class _FakeAgendaRepository implements AgendaRepository {
  List<Evento> eventos = <Evento>[_evento()];
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
  Future<List<Categoria>> listarCategorias({required int usuarioId}) async =>
      const <Categoria>[];

  @override
  Future<Categoria> crearCategoria(Categoria categoria) async => categoria;
}

EventoBloc _crearBloc(_FakeAgendaRepository repositorio) {
  return EventoBloc(
    listarEventos: ListarEventos(repositorio),
    crearEvento: CrearEvento(repositorio),
    actualizarEvento: ActualizarEvento(repositorio),
    eliminarEvento: EliminarEvento(repositorio),
    usuarioId: 7,
  );
}

Future<void> _esperar(
  EventoBloc bloc,
  bool Function(EventoState estado) condicion,
) {
  return bloc.stream.firstWhere(condicion).timeout(const Duration(seconds: 2));
}

void main() {
  late _FakeAgendaRepository repositorio;
  late EventoBloc bloc;

  setUp(() {
    repositorio = _FakeAgendaRepository();
    bloc = _crearBloc(repositorio);
  });

  tearDown(() => bloc.close());

  group('EventoBloc · carga', () {
    test('carga los eventos del usuario con el filtro recibido', () async {
      final estados = <EventoState>[];
      final suscripcion = bloc.stream.listen(estados.add);
      addTearDown(suscripcion.cancel);

      final desde = DateTime(2026, 11, 1);
      final hasta = DateTime(2026, 11, 30, 23, 59);
      bloc.add(CargarEventos(desde: desde, hasta: hasta));

      await _esperar(bloc, (estado) => estado is EventoCargado);

      expect(estados.first, isA<EventoCargando>());
      expect(estados.last, isA<EventoCargado>());
      expect((estados.last as EventoCargado).eventos, hasLength(1));
      expect(repositorio.ultimoUsuarioListado, 7);
      expect(repositorio.ultimoDesde, desde);
      expect(repositorio.ultimoHasta, hasta);
    });

    test('informa un error amigable cuando falla la carga inicial', () async {
      repositorio.fallarListado = true;
      final estados = <EventoState>[];
      final suscripcion = bloc.stream.listen(estados.add);
      addTearDown(suscripcion.cancel);

      bloc.add(const CargarEventos());
      await _esperar(bloc, (estado) => estado is EventoError);

      expect((estados.last as EventoError).mensaje, contains('servicio'));
    });

    test('RecargarEventos conserva el último filtro usado', () async {
      bloc.add(
        CargarEventos(
          desde: DateTime(2026, 11, 1),
          hasta: DateTime(2026, 11, 30),
        ),
      );
      await _esperar(bloc, (estado) => estado is EventoCargado);

      repositorio.ultimoDesde = null;
      repositorio.ultimoHasta = null;
      bloc.add(const RecargarEventos());
      await _esperar(
        bloc,
        (estado) => estado is EventoCargado && repositorio.llamadasListado == 2,
      );

      expect(repositorio.ultimoDesde, DateTime(2026, 11, 1));
      expect(repositorio.ultimoHasta, DateTime(2026, 11, 30));
    });
  });

  group('EventoBloc · operaciones', () {
    test('crear recarga la lista y emite mensaje de éxito', () async {
      bloc.add(const CargarEventos());
      await _esperar(bloc, (estado) => estado is EventoCargado);

      final estados = <EventoState>[];
      final suscripcion = bloc.stream.listen(estados.add);
      addTearDown(suscripcion.cancel);

      bloc.add(CrearEventoSolicitado(_evento(id: null, titulo: 'Nuevo')));
      await _esperar(bloc, (estado) => estado is EventoOperacionExitosa);

      expect(estados.first, isA<EventoOperacionEnCurso>());
      expect(repositorio.ultimoCreado?.titulo, 'Nuevo');
      expect(repositorio.llamadasListado, 2);

      final exito = estados.last as EventoOperacionExitosa;
      expect(exito.mensaje, 'Evento creado correctamente.');
      expect(exito.eventos, hasLength(2));
    });

    test(
      'un fallo al crear conserva la lista y no deja estado de error',
      () async {
        bloc.add(const CargarEventos());
        await _esperar(bloc, (estado) => estado is EventoCargado);
        repositorio.fallarMutacion = true;

        final estados = <EventoState>[];
        final suscripcion = bloc.stream.listen(estados.add);
        addTearDown(suscripcion.cancel);

        bloc.add(CrearEventoSolicitado(_evento(id: null, titulo: 'Nuevo')));
        await _esperar(bloc, (estado) => estado is EventoOperacionFallida);

        final fallo = estados.last as EventoOperacionFallida;
        expect(fallo.mensaje, 'No se pudo crear el evento.');
        expect(fallo.eventos, hasLength(1));
        expect(repositorio.llamadasListado, 1);
      },
    );

    test('actualizar usa el usuario de la sesión y recarga', () async {
      final actualizado = _evento(id: 1, titulo: 'Actualizado');
      bloc.add(const CargarEventos());
      await _esperar(bloc, (estado) => estado is EventoCargado);

      bloc.add(ActualizarEventoSolicitado(actualizado));
      await _esperar(bloc, (estado) => estado is EventoOperacionExitosa);

      expect(repositorio.ultimoActualizado?.titulo, 'Actualizado');
      expect(repositorio.ultimoUsuarioListado, 7);
      expect(repositorio.llamadasListado, 2);
    });

    test('eliminar envía el usuario del bloc y actualiza la lista', () async {
      bloc.add(const CargarEventos());
      await _esperar(bloc, (estado) => estado is EventoCargado);

      bloc.add(const EliminarEventoSolicitado(1));
      await _esperar(bloc, (estado) => estado is EventoOperacionExitosa);

      expect(repositorio.ultimoIdEliminado, 1);
      expect(repositorio.ultimoUsuarioEliminado, 7);

      final exito = bloc.state as EventoOperacionExitosa;
      expect(exito.mensaje, 'Evento eliminado correctamente.');
      expect(exito.eventos, isEmpty);
    });
  });
}
