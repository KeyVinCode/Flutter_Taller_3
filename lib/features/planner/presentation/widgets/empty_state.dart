import 'package:flutter/material.dart';

/// Estado vacío reutilizable con icono, mensaje y acción opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.titulo,
    this.mensaje,
    this.icono = Icons.event_busy_outlined,
    this.textoAccion,
    this.onAccion,
  });

  final String titulo;
  final String? mensaje;
  final IconData icono;
  final String? textoAccion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 40, color: scheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              if (mensaje != null && mensaje!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  mensaje!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ],
              if (textoAccion != null && onAccion != null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onAccion,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(textoAccion!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
