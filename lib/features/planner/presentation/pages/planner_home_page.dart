import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/evento.dart';
import '../bloc/evento_bloc.dart';
import '../bloc/evento_event.dart';
import '../bloc/evento_state.dart';

/// Pantalla principal del Planner: lista de eventos conectada al EventoBloc.
class PlannerHomePage extends StatelessWidget {
  const PlannerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventoBloc>(
      create: (_) => sl<EventoBloc>()..add(const CargarEventos()),
      child: const _PlannerHomeView(),
    );
  }
}

class _PlannerHomeView extends StatelessWidget {
  const _PlannerHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Planner'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<EventoBloc>().add(const CargarEventos()),
          ),
        ],
      ),
      body: BlocBuilder<EventoBloc, EventoState>(
        builder: (context, state) {
          return switch (state) {
            EventoInicial() || EventoCargando() => const Center(
              child: CircularProgressIndicator(),
            ),
            EventoError(:final mensaje) => _Error(mensaje: mensaje),
            EventoCargado(:final eventos) =>
              eventos.isEmpty
                  ? const Center(child: Text('No tienes eventos todavía.'))
                  : _ListaEventos(eventos: eventos),
          };
        },
      ),
    );
  }
}

class _ListaEventos extends StatelessWidget {
  const _ListaEventos({required this.eventos});

  final List<Evento> eventos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: eventos.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final evento = eventos[index];
        final id = evento.id;
        final ubicacion = evento.ubicacion;
        return ListTile(
          title: Text(evento.titulo),
          subtitle: Text(
            '${_formatear(evento.fechaInicio)} → ${_formatear(evento.fechaFin)}'
            '${ubicacion == null || ubicacion.isEmpty ? '' : '\n$ubicacion'}',
          ),
          isThreeLine: ubicacion != null && ubicacion.isNotEmpty,
          trailing: id == null
              ? null
              : IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => context.read<EventoBloc>().add(
                    EliminarEventoSolicitado(id),
                  ),
                ),
        );
      },
    );
  }

  static String _formatear(DateTime fecha) {
    final f = fecha.toLocal();
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.read<EventoBloc>().add(const CargarEventos()),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}