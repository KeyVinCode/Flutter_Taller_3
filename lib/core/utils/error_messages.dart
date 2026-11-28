import '../errors/agenda_repository_exception.dart';

/// Convierte cualquier error en un mensaje apto para mostrar al usuario.
///
/// Evita exponer `toString()` con detalles internos (nombres de tablas,
/// respuestas HTTP o rutas de archivos) en snackbars y pantallas de error.
String mensajeError(Object error) {
  if (error is AgendaRepositoryException) return error.message;

  if (error is ArgumentError) {
    final mensaje = error.message;
    if (mensaje is String && mensaje.trim().isNotEmpty) return mensaje;
    return 'Los datos enviados no son válidos.';
  }

  if (error is FormatException) {
    return 'La respuesta del servicio no tiene el formato esperado.';
  }

  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
