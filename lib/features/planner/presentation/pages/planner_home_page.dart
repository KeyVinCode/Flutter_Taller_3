import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/evento.dart';
import '../bloc/evento_bloc.dart';
import '../bloc/evento_event.dart';
import '../bloc/evento_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/event_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/planner_calendar.dart';
import '../widgets/section_header.dart';

/// Pantalla principal del Planner: calendario mensual + lista de eventos.
class PlannerHomePage extends StatelessWidget {
  const PlannerHomePage({super.key, this.bloc});

  /// Bloc inyectable para pruebas; en producción se obtiene del service locator.
  final EventoBloc? bloc;

  @override
  Widget build(BuildContext context) {
    final blocInyectado = bloc;
    if (blocInyectado != null) {
      return BlocProvider<EventoBloc>.value(
        value: blocInyectado,
        child: const _PlannerHomeView(),
      );
    }
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
            EventoInicial() || EventoCargando() => const LoadingView(),
            EventoError(:final mensaje) => ErrorView(
              mensaje: mensaje,
              onReintentar: () =>
                  context.read<EventoBloc>().add(const CargarEventos()),
            ),
            EventoCargado(:final eventos) => _ContenidoEventos(
              eventos: eventos,
            ),
          };
        },
      ),
    );
  }
}

class _ContenidoEventos extends StatefulWidget {
  const _ContenidoEventos({required this.eventos});

  final List<Evento> eventos;

  @override
  State<_ContenidoEventos> createState() => _ContenidoEventosState();
}

class _ContenidoEventosState extends State<_ContenidoEventos> {
  DateTime? _diaSeleccionado;

  void _alternarDia(DateTime dia) {
    final actual = _diaSeleccionado;
    setState(() {
      _diaSeleccionado = actual != null && DateFormatters.esMismoDia(actual, dia)
          ? null
          : dia;
    });
  }

  void _verTodos() => setState(() => _diaSeleccionado = null);

  void _eliminar(Evento evento) {
    final id = evento.id;
    if (id == null) return;
    context.read<EventoBloc>().add(EliminarEventoSolicitado(id));
  }

  Color _colorEvento(Evento evento) {
    final categoriaId = evento.categoriaId;
    if (categoriaId == null) return Theme.of(context).colorScheme.primary;
    return colorCategoriaPorIndice(categoriaId - 1);
  }

  String _resumen(DateTime? dia) {
    if (dia != null) return 'Eventos programados para el día seleccionado';
    final total = widget.eventos.length;
    if (total == 0) return 'Tu agenda está lista para empezar';
    if (total == 1) return '1 evento en tu agenda';
    return '$total eventos en tu agenda';
  }

  @override
  Widget build(BuildContext context) {
    final dia = _diaSeleccionado;
    final visibles = dia == null
        ? widget.eventos
        : PlannerCalendar.eventosDelDia(widget.eventos, dia);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: PlannerCalendar(
              eventos: widget.eventos,
              diaSeleccionado: dia,
              onDiaSeleccionado: _alternarDia,
              colorParaEvento: _colorEvento,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              titulo: 'Gestor de Agenda',
              subtitulo: _resumen(dia),
              icono: Icons.event_available,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(
                  titulo: dia == null ? 'Próximos eventos' : 'Eventos del día',
                  subtitulo: dia == null
                      ? '${visibles.length} eventos'
                      : DateFormatters.formatearFechaLarga(dia),
                  textoAccion: dia == null ? null : 'Ver todos',
                  onAccion: dia == null ? null : _verTodos,
                ),
                if (visibles.isEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: widget.eventos.isEmpty
                        ? const EmptyState(
                            titulo: 'Aún no tienes eventos',
                            mensaje:
                                'Crea tu primer evento y aparecerá en el '
                                'calendario y en esta lista.',
                            icono: Icons.event_available_outlined,
                          )
                        : EmptyState(
                            titulo: 'Sin eventos este día',
                            mensaje:
                                'Elige otra fecha en el calendario o revisa '
                                'todos tus eventos.',
                            icono: Icons.event_busy_outlined,
                            textoAccion: 'Ver todos',
                            onAccion: _verTodos,
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (visibles.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: visibles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final evento = visibles[index];
                return EventCard(
                  evento: evento,
                  colorCategoria: _colorEvento(evento),
                  onEliminar: evento.id == null
                      ? null
                      : () => _eliminar(evento),
                );
              },
            ),
          ),
      ],
    );
  }
}
