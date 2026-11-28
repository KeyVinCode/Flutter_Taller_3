import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/color_utils.dart';

/// Tipos de mensaje admitidos por [AppSnackBar].
enum AppSnackBarTipo { info, exito, error, advertencia }

/// Mensajes emergentes de confirmación, error e información.
///
/// Reemplaza los `SnackBar` sueltos para mantener colores, iconos y tiempos
/// consistentes en toda la aplicación.
class AppSnackBar {
  AppSnackBar._();

  static void info(
    BuildContext context,
    String mensaje, {
    String? accion,
    VoidCallback? onAccion,
  }) => mostrar(
    context,
    mensaje,
    tipo: AppSnackBarTipo.info,
    accion: accion,
    onAccion: onAccion,
  );

  static void exito(
    BuildContext context,
    String mensaje, {
    String? accion,
    VoidCallback? onAccion,
  }) => mostrar(
    context,
    mensaje,
    tipo: AppSnackBarTipo.exito,
    accion: accion,
    onAccion: onAccion,
  );

  static void error(
    BuildContext context,
    String mensaje, {
    String? accion,
    VoidCallback? onAccion,
  }) => mostrar(
    context,
    mensaje,
    tipo: AppSnackBarTipo.error,
    accion: accion,
    onAccion: onAccion,
  );

  static void advertencia(
    BuildContext context,
    String mensaje, {
    String? accion,
    VoidCallback? onAccion,
  }) => mostrar(
    context,
    mensaje,
    tipo: AppSnackBarTipo.advertencia,
    accion: accion,
    onAccion: onAccion,
  );

  static void mostrar(
    BuildContext context,
    String mensaje, {
    AppSnackBarTipo tipo = AppSnackBarTipo.info,
    String? accion,
    VoidCallback? onAccion,
    Duration duracion = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final scheme = Theme.of(context).colorScheme;
    final oscuro = scheme.brightness == Brightness.dark;
    final fondoExito = oscuro ? AppColors.successDark : AppColors.success;
    final fondoAdvertencia = oscuro
        ? AppColors.warningDark
        : AppColors.warning;
    final estilo = switch (tipo) {
      AppSnackBarTipo.info => (
        fondo: scheme.inverseSurface,
        texto: scheme.onInverseSurface,
        icono: Icons.info_outline,
      ),
      AppSnackBarTipo.exito => (
        fondo: fondoExito,
        texto: textoContraste(fondoExito),
        icono: Icons.check_circle_outline,
      ),
      AppSnackBarTipo.error => (
        fondo: scheme.error,
        texto: scheme.onError,
        icono: Icons.error_outline,
      ),
      AppSnackBarTipo.advertencia => (
        fondo: fondoAdvertencia,
        texto: textoContraste(fondoAdvertencia),
        icono: Icons.warning_amber_rounded,
      ),
    };

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duracion,
          backgroundColor: estilo.fondo,
          content: Row(
            children: [
              Icon(estilo.icono, size: 20, color: estilo.texto),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mensaje,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: estilo.texto),
                ),
              ),
            ],
          ),
          action: accion == null
              ? null
              : SnackBarAction(
                  label: accion,
                  textColor: estilo.texto,
                  onPressed: onAccion ?? () {},
                ),
        ),
      );
  }

  /// Oculta el mensaje visible sin esperar a que expire.
  static void ocultar(BuildContext context) {
    ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  }
}
