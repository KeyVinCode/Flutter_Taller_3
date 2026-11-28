import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Convierte un color HEX (`#RRGGBB` o `#AARRGGBB`) en un [Color].
///
/// Si el valor es nulo o inválido devuelve [fallback], de modo que la UI nunca
/// falla por un dato inconsistente proveniente de la base de datos.
Color colorDesdeHex(String? hex, {Color fallback = AppColors.primary}) {
  if (hex == null) return fallback;

  var valor = hex.trim();
  if (valor.startsWith('#')) valor = valor.substring(1);
  if (valor.length == 6) valor = 'FF$valor';
  if (valor.length != 8) return fallback;

  final parsed = int.tryParse(valor, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

/// Devuelve blanco o negro (con transparencia) según el contraste del fondo.
Color textoContraste(Color fondo) =>
    ThemeData.estimateBrightnessForColor(fondo) == Brightness.dark
    ? Colors.white
    : Colors.black87;

/// Color de la paleta de categorías según su posición.
Color colorCategoriaPorIndice(int indice) {
  final total = AppColors.categoryPalette.length;
  return AppColors.categoryPalette[indice.abs() % total];
}
