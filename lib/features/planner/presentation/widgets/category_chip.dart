import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Chip de categoría con color identificador.
///
/// Puede usarse solo para mostrar información o como selector al recibir
/// [onTap] (el estado visual se controla con [seleccionado]).
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.nombre,
    this.color = AppColors.primary,
    this.icono = Icons.label_outline,
    this.seleccionado = false,
    this.onTap,
  });

  final String nombre;
  final Color color;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fondo = color.withValues(alpha: seleccionado ? 0.18 : 0.08);
    final borde = color.withValues(alpha: seleccionado ? 0.7 : 0.25);

    final contenido = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(label: 'Categoría $nombre', child: contenido);
    }

    return Semantics(
      button: true,
      selected: seleccionado,
      label: 'Categoría $nombre',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: contenido,
      ),
    );
  }
}
