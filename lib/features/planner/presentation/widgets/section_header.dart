import 'package:flutter/material.dart';

/// Encabezado de sección con título, subtítulo y acción opcional.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.textoAccion,
    this.onAccion,
    this.icono,
  });

  final String titulo;
  final String? subtitulo;
  final String? textoAccion;
  final VoidCallback? onAccion;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icono != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(titulo, style: textTheme.titleMedium),
              if (subtitulo != null && subtitulo!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitulo!, style: textTheme.bodySmall),
                ),
            ],
          ),
        ),
        if (textoAccion != null && onAccion != null)
          TextButton(
            onPressed: onAccion,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            child: Text(textoAccion!),
          ),
      ],
    );
  }
}
