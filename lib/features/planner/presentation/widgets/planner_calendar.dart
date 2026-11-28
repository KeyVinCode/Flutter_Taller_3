import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/evento.dart';

/// Resuelve el color con el que se marca un evento en el calendario.
typedef ColorEventoResolver = Color Function(Evento evento);

/// Calendario mensual interactivo del Planner.
///
/// - Semana iniciando en lunes y encabezados en español.
/// - Navegación entre meses y botón "Hoy".
/// - Selección de días y marcadores para los días con eventos.
/// - Funciona de forma controlada (con [diaSeleccionado] y [mesInicial]) o
///   autónoma (mantiene su propia selección).
class PlannerCalendar extends StatefulWidget {
  const PlannerCalendar({
    super.key,
    this.mesInicial,
    this.diaSeleccionado,
    this.eventos = const <Evento>[],
    this.colorParaEvento,
    this.onDiaSeleccionado,
    this.onMesCambiado,
    this.hoy,
  });

  final DateTime? mesInicial;
  final DateTime? diaSeleccionado;
  final List<Evento> eventos;
  final ColorEventoResolver? colorParaEvento;
  final ValueChanged<DateTime>? onDiaSeleccionado;
  final ValueChanged<DateTime>? onMesCambiado;

  /// Fecha de referencia para el indicador de "hoy" (útil en pruebas).
  final DateTime? hoy;

  /// Agrupa los eventos por día; los eventos de varios días se marcan en
  /// cada jornada que ocupan (con un límite de seguridad de un año).
  static Map<DateTime, List<Evento>> agruparPorDia(List<Evento> eventos) {
    final agrupados = <DateTime, List<Evento>>{};
    for (final evento in eventos) {
      final fin = DateFormatters.inicioDelDia(evento.fechaFin);
      var dia = DateFormatters.inicioDelDia(evento.fechaInicio);
      var dias = 0;
      while (!dia.isAfter(fin) && dias < 366) {
        agrupados.putIfAbsent(dia, () => <Evento>[]).add(evento);
        dia = DateTime(dia.year, dia.month, dia.day + 1);
        dias++;
      }
    }
    return agrupados;
  }

  /// Eventos que se solapan con el día indicado.
  static List<Evento> eventosDelDia(List<Evento> eventos, DateTime dia) {
    final inicio = DateFormatters.inicioDelDia(dia);
    final fin = DateFormatters.finDelDia(dia);
    return eventos
        .where(
          (evento) =>
              !evento.fechaInicio.isAfter(fin) &&
              !evento.fechaFin.isBefore(inicio),
        )
        .toList(growable: false);
  }

  @override
  State<PlannerCalendar> createState() => _PlannerCalendarState();
}

class _PlannerCalendarState extends State<PlannerCalendar> {
  late DateTime _hoy;
  late DateTime _mesVisible;
  DateTime? _diaSeleccionado;

  @override
  void initState() {
    super.initState();
    _hoy = DateFormatters.inicioDelDia(widget.hoy ?? DateTime.now());
    final base = widget.diaSeleccionado ?? widget.mesInicial ?? _hoy;
    _mesVisible = DateFormatters.inicioDeMes(base);
    _diaSeleccionado = widget.diaSeleccionado == null
        ? null
        : DateFormatters.inicioDelDia(widget.diaSeleccionado!);
  }

  @override
  void didUpdateWidget(covariant PlannerCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hoy != oldWidget.hoy) {
      _hoy = DateFormatters.inicioDelDia(widget.hoy ?? DateTime.now());
    }

    final mesExterno = widget.mesInicial;
    if (mesExterno != null &&
        (oldWidget.mesInicial == null ||
            !DateFormatters.esMismoMes(mesExterno, oldWidget.mesInicial!))) {
      _mesVisible = DateFormatters.inicioDeMes(mesExterno);
    }

    final diaExterno = widget.diaSeleccionado;
    if (diaExterno != null) {
      final diaAnterior = oldWidget.diaSeleccionado;
      if (diaAnterior == null ||
          !DateFormatters.esMismoDia(diaExterno, diaAnterior)) {
        _diaSeleccionado = DateFormatters.inicioDelDia(diaExterno);
        _mesVisible = DateFormatters.inicioDeMes(diaExterno);
      }
    } else if (oldWidget.diaSeleccionado != null) {
      _diaSeleccionado = null;
    }
  }

  void _cambiarMes(int desplazamiento) {
    setState(() {
      _mesVisible = DateFormatters.inicioDeMes(
        DateFormatters.agregarMeses(_mesVisible, desplazamiento),
      );
    });
    widget.onMesCambiado?.call(_mesVisible);
  }

  void _irAHoy() {
    final hoy = DateFormatters.inicioDelDia(widget.hoy ?? DateTime.now());
    setState(() {
      _hoy = hoy;
      _mesVisible = DateFormatters.inicioDeMes(hoy);
      _diaSeleccionado = hoy;
    });
    widget.onMesCambiado?.call(_mesVisible);
    widget.onDiaSeleccionado?.call(hoy);
  }

  void _seleccionarDia(DateTime dia) {
    final normalizado = DateFormatters.inicioDelDia(dia);
    setState(() => _diaSeleccionado = normalizado);
    widget.onDiaSeleccionado?.call(normalizado);
  }

  int get _totalEventosMes {
    final inicioMes = DateFormatters.inicioDeMes(_mesVisible);
    final finMes = DateFormatters.finDeMes(_mesVisible);
    return widget.eventos
        .where(
          (evento) =>
              !evento.fechaInicio.isAfter(finMes) &&
              !evento.fechaFin.isBefore(inicioMes),
        )
        .length;
  }

  String get _resumenMes {
    final total = _totalEventosMes;
    if (total == 0) return 'Sin eventos este mes';
    if (total == 1) return '1 evento este mes';
    return '$total eventos este mes';
  }

  @override
  Widget build(BuildContext context) {
    final agrupados = PlannerCalendar.agruparPorDia(widget.eventos);
    final diasDelMes = DateFormatters.diasEnMes(
      _mesVisible.year,
      _mesVisible.month,
    );
    final espaciosIniciales =
        DateTime(_mesVisible.year, _mesVisible.month).weekday - 1;
    final totalCeldas = espaciosIniciales + diasDelMes;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Mes anterior',
                  onPressed: () => _cambiarMes(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    DateFormatters.etiquetaMes(_mesVisible),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Mes siguiente',
                  onPressed: () => _cambiarMes(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final dia in DateFormatters.diasSemanaCortos)
                  Expanded(
                    child: Text(
                      dia,
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 48,
              ),
              itemCount: totalCeldas,
              itemBuilder: (context, index) {
                if (index < espaciosIniciales) {
                  return const SizedBox.shrink();
                }
                final dia = index - espaciosIniciales + 1;
                final fecha = DateTime(
                  _mesVisible.year,
                  _mesVisible.month,
                  dia,
                );
                final seleccionado =
                    _diaSeleccionado != null &&
                    DateFormatters.esMismoDia(fecha, _diaSeleccionado!);
                return _CeldaDia(
                  fecha: fecha,
                  esHoy: DateFormatters.esMismoDia(fecha, _hoy),
                  seleccionado: seleccionado,
                  eventos: agrupados[fecha] ?? const <Evento>[],
                  colorParaEvento: widget.colorParaEvento,
                  onTap: () => _seleccionarDia(fecha),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 16,
                  color: textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _resumenMes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: _irAHoy,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.today, size: 16),
                  label: const Text('Hoy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CeldaDia extends StatelessWidget {
  const _CeldaDia({
    required this.fecha,
    required this.esHoy,
    required this.seleccionado,
    required this.eventos,
    required this.onTap,
    this.colorParaEvento,
  });

  final DateTime fecha;
  final bool esHoy;
  final bool seleccionado;
  final List<Evento> eventos;
  final VoidCallback onTap;
  final ColorEventoResolver? colorParaEvento;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final visibles = eventos.take(3).toList(growable: false);
    final colorTexto = seleccionado ? scheme.onPrimary : scheme.onSurface;
    final radio = BorderRadius.circular(10);
    final mesNombre = DateFormatters.mesesLargos[fecha.month - 1];

    return Semantics(
      button: true,
      selected: seleccionado,
      label:
          'Día ${fecha.day} de $mesNombre'
          '${eventos.isEmpty ? '' : ', ${eventos.length} eventos'}'
          '${esHoy ? ', hoy' : ''}',
      child: InkWell(
        key: ValueKey('calendar-day-${fecha.day}'),
        onTap: onTap,
        borderRadius: radio,
        child: Container(
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: seleccionado
                ? scheme.primary
                : esHoy
                ? scheme.primaryContainer
                : null,
            borderRadius: radio,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${fecha.day}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorTexto,
                  fontWeight: seleccionado || esHoy
                      ? FontWeight.w800
                      : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final evento in visibles)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: seleccionado
                              ? scheme.onPrimary
                              : _colorEvento(evento, scheme),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorEvento(Evento evento, ColorScheme scheme) {
    final resolver = colorParaEvento;
    if (resolver == null) return scheme.tertiary;
    return resolver(evento);
  }
}
