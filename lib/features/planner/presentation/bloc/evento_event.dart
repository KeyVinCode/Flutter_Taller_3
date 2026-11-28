import '../../domain/entities/evento.dart';

sealed class EventoEvent {
  const EventoEvent();
}

class CargarEventos extends EventoEvent {
  const CargarEventos({this.desde, this.hasta, this.categoriaId});

  final DateTime? desde;
  final DateTime? hasta;
  final int? categoriaId;
}

class CrearEventoSolicitado extends EventoEvent {
  const CrearEventoSolicitado(this.evento);

  final Evento evento;
}

class ActualizarEventoSolicitado extends EventoEvent {
  const ActualizarEventoSolicitado(this.evento);

  final Evento evento;
}

class EliminarEventoSolicitado extends EventoEvent {
  const EliminarEventoSolicitado(this.id);

  final int id;
}