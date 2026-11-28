import 'package:flutter/material.dart';

/// Variantes visuales de [CustomButton].
enum CustomButtonVariant { primario, secundario, texto, peligro }

/// Botón reutilizable con estado de carga e icono opcional.
///
/// Mientras [cargando] es `true` el botón queda deshabilitado y muestra un
/// indicador de progreso para evitar envíos duplicados.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.cargando = false,
    this.expandido = true,
    this.variante = CustomButtonVariant.primario,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool cargando;
  final bool expandido;
  final CustomButtonVariant variante;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onPressedFinal = cargando ? null : onPressed;
    final colorContenido = switch (variante) {
      CustomButtonVariant.primario => scheme.onPrimary,
      CustomButtonVariant.peligro => scheme.onError,
      CustomButtonVariant.secundario || CustomButtonVariant.texto => null,
    };

    final contenido = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cargando)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: colorContenido ?? scheme.primary,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (cargando || icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final boton = switch (variante) {
      CustomButtonVariant.primario => FilledButton(
        onPressed: onPressedFinal,
        child: contenido,
      ),
      CustomButtonVariant.peligro => FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.error,
          foregroundColor: scheme.onError,
        ),
        onPressed: onPressedFinal,
        child: contenido,
      ),
      CustomButtonVariant.secundario => OutlinedButton(
        onPressed: onPressedFinal,
        child: contenido,
      ),
      CustomButtonVariant.texto => TextButton(
        onPressed: onPressedFinal,
        child: contenido,
      ),
    };

    if (!expandido) return boton;
    return SizedBox(width: double.infinity, child: boton);
  }
}

/// Botón de acción rápida con icono y etiqueta opcional, usado en tarjetas
/// y barras de acciones.
class IconTextButton extends StatelessWidget {
  const IconTextButton({
    super.key,
    required this.icono,
    required this.label,
    this.onPressed,
    this.color,
  });

  final IconData icono;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorFinal = color ?? Theme.of(context).colorScheme.primary;
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorFinal,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(icono, size: 18),
      label: Text(label),
    );
  }
}
