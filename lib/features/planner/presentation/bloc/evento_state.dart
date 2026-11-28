import '../../domain/entities/evento.dart';

sealed class EventoState {
  const EventoState();
}

class EventoInicial extends EventoState {
  const EventoInicial();
}

class EventoCargando extends EventoState {
  const EventoCargando();
}

class EventoCargado extends EventoState {
  const EventoCargado(this.eventos);

  final List<Evento> eventos;
}

class EventoError extends EventoState {
  const EventoError(this.mensaje);

  final String mensaje;
}