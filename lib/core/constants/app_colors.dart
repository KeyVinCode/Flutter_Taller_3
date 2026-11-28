import 'package:flutter/material.dart';

/// Paleta central del Gestor de Agenda.
///
/// Los widgets de presentación deben preferir `Theme.of(context).colorScheme`
/// para respetar el modo claro/oscuro; estas constantes se usan para los
/// acentos de estado y la paleta de categorías.
class AppColors {
  AppColors._();

  /// Color semilla de la aplicación (Material 3).
  static const Color primary = Color(0xFF3949AB);

  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE1E2EA);

  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF6B6B74);

  static const Color success = Color(0xFF2E7D32);
  static const Color successDark = Color(0xFF81C784);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerDark = Color(0xFFEF9A9A);

  /// Colores disponibles para las categorías de la agenda.
  static const List<Color> categoryPalette = <Color>[
    Color(0xFF3949AB), // Índigo — general
    Color(0xFF00897B), // Verde azulado — trabajo
    Color(0xFFD81B60), // Rosa — personal
    Color(0xFFEF6C00), // Naranja — recordatorios
    Color(0xFF6A1B9A), // Púrpura — estudio
    Color(0xFF1565C0), // Azul — reuniones
    Color(0xFF2E7D32), // Verde — salud
    Color(0xFF546E7A), // Gris azulado — otros
  ];
}
