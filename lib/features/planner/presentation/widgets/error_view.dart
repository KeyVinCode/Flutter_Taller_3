import 'package:flutter/material.dart';

/// Vista de error reutilizable con acción de reintento.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.mensaje,
    this.titulo = 'Algo salió mal',
    this.icono = Icons.cloud_off_outlined,
    this.textoReintentar = 'Reintentar',
    this.onReintentar,
  });

  final String mensaje;
  final String titulo;
  final IconData icono;
  final String textoReintentar;
  final VoidCallback? onReintentar;

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
                  color: scheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 40, color: scheme.onErrorContainer),
              ),
              const SizedBox(height: 20),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
              if (onReintentar != null) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onReintentar,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(textoReintentar),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
