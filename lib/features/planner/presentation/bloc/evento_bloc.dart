import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/actualizar_evento.dart';
import '../../domain/usecases/crear_evento.dart';
import '../../domain/usecases/eliminar_evento.dart';
import '../../domain/usecases/listar_eventos.dart';
import 'evento_event.dart';
import 'evento_state.dart';

/// TEMPORAL: reemplazar por el usuario de la sesión cuando exista el login.
const int _usuarioIdTemporal = 1;

class EventoBloc extends Bloc<EventoEvent, EventoState> {
  EventoBloc({
    required this.listarEventos,
    required this.crearEvento,
    required this.actualizarEvento,
    required this.eliminarEvento,
  }) : super(const EventoInicial()) {
    on<CargarEventos>(_onCargar);
    on<CrearEventoSolicitado>(
      (event, emit) => _mutar(() async {
        await crearEvento(event.evento);
      }, emit),
    );
    on<ActualizarEventoSolicitado>(
      (event, emit) => _mutar(() async {
        await actualizarEvento(event.evento);
      }, emit),
    );
    on<EliminarEventoSolicitado>(
      (event, emit) => _mutar(() async {
        await eliminarEvento(id: event.id, usuarioId: _usuarioIdTemporal);
      }, emit),
    );
  }

  final ListarEventos listarEventos;
  final CrearEvento crearEvento;
  final ActualizarEvento actualizarEvento;
  final EliminarEvento eliminarEvento;

  /// Último filtro usado, para recargar la lista después de crear/editar/borrar.
  CargarEventos _ultimoFiltro = const CargarEventos();

  Future<void> _onCargar(
    CargarEventos event,
    Emitter<EventoState> emit,
  ) async {
    _ultimoFiltro = event;
    emit(const EventoCargando());
    try {
      final eventos = await listarEventos(
        usuarioId: _usuarioIdTemporal,
        desde: event.desde,
        hasta: event.hasta,
        categoriaId: event.categoriaId,
      );
      emit(EventoCargado(eventos));
    } catch (error) {
      emit(EventoError(_mensaje(error)));
    }
  }

  Future<void> _mutar(
    Future<void> Function() accion,
    Emitter<EventoState> emit,
  ) async {
    try {
      await accion();
    } catch (error) {
      emit(EventoError(_mensaje(error)));
      return;
    }
    await _onCargar(_ultimoFiltro, emit);
  }

  String _mensaje(Object error) =>
      error is ArgumentError ? '${error.message}' : error.toString();
}