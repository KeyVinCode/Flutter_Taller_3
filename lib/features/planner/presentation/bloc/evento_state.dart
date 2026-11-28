import '../../domain/entities/evento.dart';

/// Origen de una operación de escritura, para que el formulario y la lista
/// muestren el feedback una sola vez.
enum EventoOrigenOperacion { lista, formulario }

/// Estado base del planner.
///
/// Los estados que conservan [eventos] permiten que la pantalla siga mostrando
/// el calendario y la lista mientras se ejecuta una operación o se recarga un
/// mes. [EventoError] se reserva para fallos de carga sin datos previos.
sealed class EventoState {
  const EventoState();

  /// Última lista conocida de eventos.
  List<Evento> get eventos => const <Evento>[];
}

class EventoInicial extends EventoState {
  const EventoInicial();
}

class EventoCargando extends EventoState {
  const EventoCargando({this.eventos = const <Evento>[]});

  @override
  final List<Evento> eventos;
}

class EventoCargado extends EventoState {
  const EventoCargado(this.eventos);

  @override
  final List<Evento> eventos;
}

/// Operación de escritura (crear, actualizar o eliminar) en curso.
class EventoOperacionEnCurso extends EventoState {
  const EventoOperacionEnCurso(this.eventos);

  @override
  final List<Evento> eventos;
}

/// Operación completada; [mensaje] se muestra en un snackbar.
class EventoOperacionExitosa extends EventoState {
  const EventoOperacionExitosa(
    this.eventos,
    this.mensaje, {
    this.origen = EventoOrigenOperacion.lista,
  });

  @override
  final List<Evento> eventos;

  final String mensaje;
  final EventoOrigenOperacion origen;
}

/// Operación fallida; la lista anterior se conserva para no perder el contexto.
class EventoOperacionFallida extends EventoState {
  const EventoOperacionFallida(
    this.eventos,
    this.mensaje, {
    this.origen = EventoOrigenOperacion.lista,
  });

  @override
  final List<Evento> eventos;

  final String mensaje;
  final EventoOrigenOperacion origen;
}

class EventoError extends EventoState {
  const EventoError(this.mensaje);

  final String mensaje;
}
