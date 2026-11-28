import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/evento.dart';
import '../../domain/usecases/listar_categorias.dart';
import '../bloc/evento_bloc.dart';
import '../bloc/evento_event.dart';
import '../bloc/evento_state.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/event_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/planner_calendar.dart';
import '../widgets/section_header.dart';
import 'evento_form_page.dart';

CargarEventos _filtroMes(DateTime mes) => CargarEventos(
  desde: DateFormatters.inicioDeMes(mes),
  hasta: DateFormatters.finDeMes(mes),
);

/// Pantalla principal del Planner: calendario mensual + lista de eventos.
class PlannerHomePage extends StatelessWidget {
  const PlannerHomePage({super.key, this.bloc, this.listarCategorias});

  /// Bloc inyectable para pruebas; en producción se obtiene del service locator.
  final EventoBloc? bloc;

  /// Caso de uso inyectable para pruebas del formulario.
  final ListarCategorias? listarCategorias;

  @override
  Widget build(BuildContext context) {
    final blocInyectado = bloc;
    if (blocInyectado != null) {
      return BlocProvider<EventoBloc>.value(
        value: blocInyectado,
        child: _PlannerHomeView(listarCategorias: listarCategorias),
      );
    }
    return BlocProvider<EventoBloc>(
      create: (_) => sl<EventoBloc>()..add(_filtroMes(DateTime.now())),
      child: _PlannerHomeView(listarCategorias: listarCategorias),
    );
  }
}

class _PlannerHomeView extends StatefulWidget {
  const _PlannerHomeView({this.listarCategorias});

  final ListarCategorias? listarCategorias;

  @override
  State<_PlannerHomeView> createState() => _PlannerHomeViewState();
}

class _PlannerHomeViewState extends State<_PlannerHomeView> {
  DateTime _mesVisible = DateFormatters.inicioDeMes(DateTime.now());

  Future<void> _abrirFormulario(BuildContext context, [Evento? evento]) async {
    final bloc = context.read<EventoBloc>();
    final casoUso = widget.listarCategorias ?? sl<ListarCategorias>();
    final mensaje = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => EventoFormPage(
          bloc: bloc,
          listarCategorias: casoUso,
          evento: evento,
        ),
      ),
    );
    if (!context.mounted || mensaje == null) return;
    AppSnackBar.exito(context, mensaje);
  }

  void _cambiarMes(DateTime mes) {
    final normalizado = DateFormatters.inicioDeMes(mes);
    setState(() => _mesVisible = normalizado);
    context.read<EventoBloc>().add(_filtroMes(normalizado));
  }

  Widget _contenido(List<Evento> eventos, {bool actualizando = false}) {
    return _ContenidoEventos(
      eventos: eventos,
      actualizando: actualizando,
      mesVisible: _mesVisible,
      onMesCambiado: _cambiarMes,
      onAbrirFormulario: (evento) => _abrirFormulario(context, evento),
    );
  }

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
                context.read<EventoBloc>().add(const RecargarEventos()),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<EventoBloc, EventoState>(
        builder: (context, state) => FloatingActionButton.extended(
          key: const ValueKey('fab-nuevo-evento'),
          onPressed: state is EventoOperacionEnCurso
              ? null
              : () => _abrirFormulario(context),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo evento'),
        ),
      ),
      body: BlocListener<EventoBloc, EventoState>(
        listenWhen: (_, actual) =>
            (actual is EventoOperacionExitosa &&
                actual.origen == EventoOrigenOperacion.lista) ||
            actual is EventoOperacionFallida,
        listener: (context, state) {
          // Cuando el formulario está encima, él se encarga de los mensajes.
          if (ModalRoute.of(context)?.isCurrent != true) return;
          switch (state) {
            case EventoOperacionExitosa(:final mensaje):
              AppSnackBar.exito(context, mensaje);
              break;
            case EventoOperacionFallida(:final mensaje):
              AppSnackBar.error(context, mensaje);
              break;
            default:
              break;
          }
        },
        child: BlocBuilder<EventoBloc, EventoState>(
          builder: (context, state) {
            return switch (state) {
              EventoInicial() => const LoadingView(),
              EventoError(:final mensaje) => ErrorView(
                mensaje: mensaje,
                onReintentar: () =>
                    context.read<EventoBloc>().add(const RecargarEventos()),
              ),
              EventoCargando(:final eventos) when eventos.isEmpty =>
                const LoadingView(),
              EventoCargando(:final eventos) => _contenido(
                eventos,
                actualizando: true,
              ),
              EventoCargado(:final eventos) => _contenido(eventos),
              EventoOperacionEnCurso(:final eventos) => _contenido(
                eventos,
                actualizando: true,
              ),
              EventoOperacionExitosa(:final eventos) => _contenido(eventos),
              EventoOperacionFallida(:final eventos) => _contenido(eventos),
            };
          },
        ),
      ),
    );
  }
}

class _ContenidoEventos extends StatefulWidget {
  const _ContenidoEventos({
    required this.eventos,
    required this.mesVisible,
    required this.onMesCambiado,
    required this.onAbrirFormulario,
    this.actualizando = false,
  });

  final List<Evento> eventos;
  final DateTime mesVisible;
  final ValueChanged<DateTime> onMesCambiado;
  final ValueChanged<Evento?> onAbrirFormulario;
  final bool actualizando;

  @override
  State<_ContenidoEventos> createState() => _ContenidoEventosState();
}

class _ContenidoEventosState extends State<_ContenidoEventos> {
  DateTime? _diaSeleccionado;

  void _alternarDia(DateTime dia) {
    final actual = _diaSeleccionado;
    setState(() {
      _diaSeleccionado =
          actual != null && DateFormatters.esMismoDia(actual, dia) ? null : dia;
    });
  }

  void _verTodos() => setState(() => _diaSeleccionado = null);

  void _cambiarMes(DateTime mes) {
    final normalizado = DateFormatters.inicioDeMes(mes);
    setState(() {
      final dia = _diaSeleccionado;
      if (dia != null && !DateFormatters.esMismoMes(dia, normalizado)) {
        _diaSeleccionado = null;
      }
    });
    widget.onMesCambiado(normalizado);
  }

  Future<void> _eliminar(Evento evento) async {
    final id = evento.id;
    if (id == null) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar evento'),
        content: Text(
          '¿Seguro que deseas eliminar "${evento.titulo}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          CustomButton(
            key: const ValueKey('cancelar-eliminar'),
            label: 'Cancelar',
            variante: CustomButtonVariant.texto,
            expandido: false,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          CustomButton(
            key: const ValueKey('confirmar-eliminar'),
            label: 'Eliminar',
            icon: Icons.delete_outline,
            variante: CustomButtonVariant.peligro,
            expandido: false,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;
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
        if (widget.actualizando)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(minHeight: 2),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: PlannerCalendar(
              eventos: widget.eventos,
              mesInicial: widget.mesVisible,
              diaSeleccionado: dia,
              onDiaSeleccionado: _alternarDia,
              onMesCambiado: _cambiarMes,
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
                final accionesHabilitadas =
                    !widget.actualizando && evento.id != null;
                return EventCard(
                  evento: evento,
                  colorCategoria: _colorEvento(evento),
                  onTap: widget.actualizando
                      ? null
                      : () => widget.onAbrirFormulario(evento),
                  onEditar: widget.actualizando
                      ? null
                      : () => widget.onAbrirFormulario(evento),
                  onEliminar: accionesHabilitadas
                      ? () => _eliminar(evento)
                      : null,
                );
              },
            ),
          ),
      ],
    );
  }
}
