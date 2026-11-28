import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/evento.dart';

/// Estado visual del evento derivado de sus fechas.
///
/// El esquema SQL no almacena un estado explícito; por eso se calcula
/// comparando `fechaInicio` y `fechaFin` con el momento actual.
enum EstadoEventoVisual {
  pendiente,
  enCurso,
  finalizado;

  static EstadoEventoVisual desde(Evento evento, {DateTime? ahora}) {
    final referencia = ahora ?? DateTime.now();
    if (evento.fechaFin.isBefore(referencia)) {
      return EstadoEventoVisual.finalizado;
    }
    if (!evento.fechaInicio.isAfter(referencia)) {
      return EstadoEventoVisual.enCurso;
    }
    return EstadoEventoVisual.pendiente;
  }

  String get etiqueta => switch (this) {
    EstadoEventoVisual.pendiente => 'Pendiente',
    EstadoEventoVisual.enCurso => 'En curso',
    EstadoEventoVisual.finalizado => 'Finalizado',
  };

  IconData get icono => switch (this) {
    EstadoEventoVisual.pendiente => Icons.schedule_outlined,
    EstadoEventoVisual.enCurso => Icons.play_circle_outline,
    EstadoEventoVisual.finalizado => Icons.task_alt,
  };

  Color colorPara(ColorScheme scheme) {
    final oscuro = scheme.brightness == Brightness.dark;
    return switch (this) {
      EstadoEventoVisual.pendiente =>
        oscuro ? AppColors.warningDark : AppColors.warning,
      EstadoEventoVisual.enCurso => scheme.primary,
      EstadoEventoVisual.finalizado =>
        oscuro ? AppColors.successDark : AppColors.success,
    };
  }
}

/// Chip que muestra si un evento está pendiente, en curso o finalizado.
class EventStatusChip extends StatelessWidget {
  const EventStatusChip({super.key, required this.estado});

  final EstadoEventoVisual estado;

  @override
  Widget build(BuildContext context) {
    final color = estado.colorPara(Theme.of(context).colorScheme);
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Estado: ${estado.etiqueta}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(estado.icono, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              estado.etiqueta,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
