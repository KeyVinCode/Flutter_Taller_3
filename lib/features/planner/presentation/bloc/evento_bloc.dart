import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_messages.dart';
import '../../domain/entities/evento.dart';
import '../../domain/usecases/actualizar_evento.dart';
import '../../domain/usecases/crear_evento.dart';
import '../../domain/usecases/eliminar_evento.dart';
import '../../domain/usecases/listar_eventos.dart';
import 'evento_event.dart';
import 'evento_state.dart';

class EventoBloc extends Bloc<EventoEvent, EventoState> {
  EventoBloc({
    required this.listarEventos,
    required this.crearEvento,
    required this.actualizarEvento,
    required this.eliminarEvento,
    required this.usuarioId,
  }) : super(const EventoInicial()) {
    on<CargarEventos>(_onCargar);
    on<RecargarEventos>((_, emit) => _onCargar(_ultimoFiltro, emit));
    on<CrearEventoSolicitado>(
      (event, emit) => _mutar(
        mensajeExito: 'Evento creado correctamente.',
        origen: EventoOrigenOperacion.formulario,
        accion: () => crearEvento(event.evento),
        emit: emit,
      ),
    );
    on<ActualizarEventoSolicitado>(
      (event, emit) => _mutar(
        mensajeExito: 'Evento actualizado correctamente.',
        origen: EventoOrigenOperacion.formulario,
        accion: () => actualizarEvento(event.evento),
        emit: emit,
      ),
    );
    on<EliminarEventoSolicitado>(
      (event, emit) => _mutar(
        mensajeExito: 'Evento eliminado correctamente.',
        origen: EventoOrigenOperacion.lista,
        accion: () => eliminarEvento(id: event.id, usuarioId: usuarioId),
        emit: emit,
      ),
    );
  }

  final ListarEventos listarEventos;
  final CrearEvento crearEvento;
  final ActualizarEvento actualizarEvento;
  final EliminarEvento eliminarEvento;

  /// Usuario dueño de la agenda (inyectado desde `SesionActual`).
  final int usuarioId;

  /// Último filtro usado, para recargar la lista después de crear/editar/borrar.
  CargarEventos _ultimoFiltro = const CargarEventos();

  Future<void> _onCargar(CargarEventos event, Emitter<EventoState> emit) async {
    _ultimoFiltro = event;
    final previos = state.eventos;
    emit(EventoCargando(eventos: previos));
    try {
      final eventos = await _listar(event);
      emit(EventoCargado(eventos));
    } catch (error) {
      final mensaje = mensajeError(error);
      if (previos.isEmpty) {
        emit(EventoError(mensaje));
      } else {
        emit(
          EventoOperacionFallida(
            previos,
            'No se pudo actualizar la agenda: $mensaje',
          ),
        );
      }
    }
  }

  Future<List<Evento>> _listar(CargarEventos filtro) {
    return listarEventos(
      usuarioId: usuarioId,
      desde: filtro.desde,
      hasta: filtro.hasta,
      categoriaId: filtro.categoriaId,
    );
  }

  Future<void> _mutar({
    required String mensajeExito,
    required EventoOrigenOperacion origen,
    required Future<void> Function() accion,
    required Emitter<EventoState> emit,
  }) async {
    final previos = state.eventos;
    emit(EventoOperacionEnCurso(previos));

    try {
      await accion();
    } catch (error) {
      emit(
        EventoOperacionFallida(previos, mensajeError(error), origen: origen),
      );
      return;
    }

    // La escritura ya se completó: si la recarga falla no se debe mostrar un
    // error que invite a repetir la operación (crearía duplicados). Se conserva
    // la lista anterior y el usuario puede recargar manualmente.
    var actualizados = previos;
    try {
      actualizados = await _listar(_ultimoFiltro);
    } catch (_) {
      // Se ignora intencionalmente; el mensaje de éxito sigue siendo válido.
    }
    emit(EventoOperacionExitosa(actualizados, mensajeExito, origen: origen));
  }
}
