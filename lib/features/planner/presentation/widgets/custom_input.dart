import 'package:flutter/material.dart';

/// Campo de texto reutilizable para los formularios de la agenda.
///
/// Aplica el estilo de `inputDecorationTheme` definido en [AppTheme] y
/// mantiene el mismo aspecto para títulos, descripciones y ubicaciones.
class CustomInput extends StatelessWidget {
  const CustomInput({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.obscureText = false,
    this.autofocus = false,
    this.onChanged,
    this.onFieldSubmitted,
  }) : assert(
         controller == null || initialValue == null,
         'Usa controller o initialValue, no ambos.',
       );

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool obscureText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLines: obscureText ? 1 : maxLines,
      maxLength: maxLength,
      enabled: enabled,
      obscureText: obscureText,
      autofocus: autofocus,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
