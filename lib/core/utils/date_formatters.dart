/// Utilidades de fecha y hora en español (es_CO).
///
/// Se implementan sin paquetes externos para que la capa de presentación no
/// dependa de configuraciones regionales adicionales. Todas las funciones
/// convierten internamente las fechas UTC a la zona horaria local.
class DateFormatters {
  DateFormatters._();

  static const List<String> mesesLargos = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static const List<String> mesesCortos = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const List<String> diasSemanaLargos = <String>[
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  /// Encabezados del calendario con la semana iniciando en lunes.
  static const List<String> diasSemanaCortos = <String>[
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];

  static String dosDigitos(int valor) => valor.toString().padLeft(2, '0');

  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return '${texto[0].toUpperCase()}${texto.substring(1)}';
  }

  /// Hora en formato de 12 horas: `8:05 a. m.` / `7:30 p. m.`.
  static String formatearHora(DateTime fecha) {
    final local = _local(fecha);
    final hora12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final sufijo = local.hour < 12 ? 'a. m.' : 'p. m.';
    return '$hora12:${dosDigitos(local.minute)} $sufijo';
  }

  /// Hora en formato de 24 horas: `08:05`.
  static String formatearHora24(DateTime fecha) {
    final local = _local(fecha);
    return '${dosDigitos(local.hour)}:${dosDigitos(local.minute)}';
  }

  /// Fecha corta: `27 nov 2026`.
  static String formatearFechaCorta(DateTime fecha) {
    final local = _local(fecha);
    return '${local.day} ${mesesCortos[local.month - 1]} ${local.year}';
  }

  /// Fecha larga: `viernes, 27 de noviembre de 2026`.
  static String formatearFechaLarga(DateTime fecha) {
    final local = _local(fecha);
    return '${diasSemanaLargos[local.weekday - 1]}, ${local.day} de '
        '${mesesLargos[local.month - 1]} de ${local.year}';
  }

  /// Fecha con hora: `27 nov 2026 · 8:05 a. m.`.
  static String formatearFechaHora(DateTime fecha) =>
      '${formatearFechaCorta(fecha)} · ${formatearHora(fecha)}';

  /// Rango legible: si es el mismo día muestra la fecha una sola vez.
  static String formatearRangoFechaHora(DateTime inicio, DateTime fin) {
    if (esMismoDia(inicio, fin)) {
      return '${formatearFechaCorta(inicio)} · '
          '${formatearHora(inicio)} – ${formatearHora(fin)}';
    }
    return '${formatearFechaHora(inicio)} – ${formatearFechaHora(fin)}';
  }

  /// Etiqueta de mes: `Noviembre 2026`.
  static String etiquetaMes(DateTime mes) =>
      '${capitalizar(mesesLargos[mes.month - 1])} ${mes.year}';

  /// Etiqueta corta de día: `Vie 27`.
  static String etiquetaDiaCorta(DateTime fecha) {
    final local = _local(fecha);
    return '${diasSemanaCortos[local.weekday - 1]} ${local.day}';
  }

  static bool esMismoDia(DateTime a, DateTime b) {
    final localA = _local(a);
    final localB = _local(b);
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  static bool esMismoMes(DateTime a, DateTime b) {
    final localA = _local(a);
    final localB = _local(b);
    return localA.year == localB.year && localA.month == localB.month;
  }

  static DateTime inicioDelDia(DateTime fecha) {
    final local = _local(fecha);
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime finDelDia(DateTime fecha) {
    final local = _local(fecha);
    return DateTime(local.year, local.month, local.day, 23, 59, 59, 999);
  }

  static DateTime inicioDeMes(DateTime fecha) {
    final local = _local(fecha);
    return DateTime(local.year, local.month);
  }

  static DateTime finDeMes(DateTime fecha) {
    final local = _local(fecha);
    return DateTime(local.year, local.month + 1, 0, 23, 59, 59, 999);
  }

  /// Cantidad de días del mes indicado (acepta meses fuera de rango 1-12).
  static int diasEnMes(int anio, int mes) => DateTime(anio, mes + 1, 0).day;

  /// Suma o resta meses conservando la hora y ajustando el día al último
  /// día válido del mes destino (31 ene + 1 mes → 28/29 feb).
  static DateTime agregarMeses(DateTime fecha, int meses) {
    final local = _local(fecha);
    final primerDiaDestino = DateTime(local.year, local.month + meses);
    final ultimoDia = diasEnMes(
      primerDiaDestino.year,
      primerDiaDestino.month,
    );
    final dia = local.day > ultimoDia ? ultimoDia : local.day;
    return DateTime(
      primerDiaDestino.year,
      primerDiaDestino.month,
      dia,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }

  static DateTime _local(DateTime fecha) => fecha.isUtc ? fecha.toLocal() : fecha;
}
