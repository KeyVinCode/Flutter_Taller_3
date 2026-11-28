/// Validadores reutilizables para los formularios de la agenda.
///
/// Devuelven `null` cuando el valor es válido, siguiendo el contrato de
/// `TextFormField.validator`.
class Validators {
  Validators._();

  static String? requerido(String? valor, {String campo = 'Este campo'}) {
    if (valor == null || valor.trim().isEmpty) return '$campo es obligatorio.';
    return null;
  }

  static String? longitudMaxima(
    String? valor,
    int maximo, {
    String campo = 'Este campo',
  }) {
    if (valor != null && valor.trim().length > maximo) {
      return '$campo no puede superar los $maximo caracteres.';
    }
    return null;
  }

  /// Título del evento: obligatorio y máximo 150 caracteres (esquema SQL).
  static String? titulo(String? valor) =>
      requerido(valor, campo: 'El título') ??
      longitudMaxima(valor, 150, campo: 'El título');

  /// Descripción opcional, máximo 1000 caracteres.
  static String? descripcion(String? valor) =>
      longitudMaxima(valor, 1000, campo: 'La descripción');

  /// Ubicación opcional, máximo 200 caracteres (esquema SQL).
  static String? ubicacion(String? valor) =>
      longitudMaxima(valor, 200, campo: 'La ubicación');

  /// Verifica que la fecha de fin exista y no sea anterior a la de inicio.
  static String? rangoFechas(DateTime? inicio, DateTime? fin) {
    if (inicio == null) return 'Selecciona la fecha de inicio.';
    if (fin == null) return 'Selecciona la fecha de fin.';
    if (fin.isBefore(inicio)) {
      return 'La fecha de fin no puede ser anterior a la de inicio.';
    }
    return null;
  }
}
