import 'package:flutter/material.dart';

/// Indicador de carga centralizado con mensaje opcional.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.mensaje = 'Cargando tu agenda...'});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    final mensajeFinal = mensaje;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (mensajeFinal != null && mensajeFinal.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                mensajeFinal,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
