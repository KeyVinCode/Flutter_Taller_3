import 'package:flutter/material.dart';

import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/evento.dart';
import 'category_chip.dart';
import 'event_status_chip.dart';

/// Tarjeta reutilizable para mostrar un evento de la agenda.
///
/// Muestra la fecha destacada, el rango horario, la ubicación, la categoría
/// (con su color) y el estado calculado a partir de las fechas.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.evento,
    this.categoria,
    this.colorCategoria,
    this.onTap,
    this.onEditar,
    this.onEliminar,
    this.ahora,
  });

  final Evento evento;
  final Categoria? categoria;

  /// Permite forzar el color cuando la categoría no está cargada.
  final Color? colorCategoria;
  final VoidCallback? onTap;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  /// Fecha de referencia para calcular el estado (útil en pruebas).
  final DateTime? ahora;

  @override
  Widget build(BuildContext context) {
    final estado = EstadoEventoVisual.desde(evento, ahora: ahora);
    final color = _colorCategoria(context);
    final textTheme = Theme.of(context).textTheme;
    final categoriaActual = categoria;
    final descripcion = evento.descripcion?.trim() ?? '';
    final ubicacion = evento.ubicacion?.trim() ?? '';
    final finalizado = estado == EstadoEventoVisual.finalizado;

    return Semantics(
      container: true,
      button: onTap != null,
      label:
          '${evento.titulo}. '
          '${DateFormatters.formatearRangoFechaHora(evento.fechaInicio, evento.fechaFin)}. '
          '${estado.etiqueta}',
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: color, width: 6)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FechaBadge(fecha: evento.fechaInicio, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: finalizado
                              ? textTheme.bodySmall?.color
                              : null,
                          decoration: finalizado
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _LineaIcono(
                        icono: Icons.schedule,
                        texto: DateFormatters.formatearRangoFechaHora(
                          evento.fechaInicio,
                          evento.fechaFin,
                        ),
                      ),
                      if (ubicacion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _LineaIcono(
                          icono: Icons.place_outlined,
                          texto: ubicacion,
                        ),
                      ],
                      if (descripcion.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          EventStatusChip(estado: estado),
                          if (categoriaActual != null)
                            CategoryChip(
                              nombre: categoriaActual.nombre,
                              color: color,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onEditar != null || onEliminar != null)
                  _MenuAcciones(
                    onEditar: onEditar,
                    onEliminar: onEliminar,
                  )
                else if (onTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, right: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorCategoria(BuildContext context) {
    final colorExplicito = colorCategoria;
    if (colorExplicito != null) return colorExplicito;
    final categoriaActual = categoria;
    if (categoriaActual != null) return colorDesdeHex(categoriaActual.colorHex);
    return Theme.of(context).colorScheme.primary;
  }
}

class _FechaBadge extends StatelessWidget {
  const _FechaBadge({required this.fecha, required this.color});

  final DateTime fecha;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final local = fecha.toLocal();
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 52,
      height: 58,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${local.day}',
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormatters.mesesCortos[local.month - 1].toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineaIcono extends StatelessWidget {
  const _LineaIcono({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 15, color: textTheme.bodySmall?.color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _MenuAcciones extends StatelessWidget {
  const _MenuAcciones({this.onEditar, this.onEliminar});

  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colorSecundario = Theme.of(context).textTheme.bodySmall?.color;

    return PopupMenuButton<String>(
      tooltip: 'Opciones del evento',
      icon: Icon(Icons.more_vert, color: colorSecundario),
      onSelected: (valor) {
        if (valor == 'editar') {
          onEditar?.call();
        } else if (valor == 'eliminar') {
          onEliminar?.call();
        }
      },
      itemBuilder: (context) => [
        if (onEditar != null)
          const PopupMenuItem<String>(
            value: 'editar',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 10),
                Text('Editar'),
              ],
            ),
          ),
        if (onEliminar != null)
          PopupMenuItem<String>(
            value: 'eliminar',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: scheme.error),
                const SizedBox(width: 10),
                Text('Eliminar', style: TextStyle(color: scheme.error)),
              ],
            ),
          ),
      ],
    );
  }
}

