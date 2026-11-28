/// Sesión del usuario autenticado en la aplicación.
///
/// Mientras el login no exista, los valores se leen de `--dart-define`:
/// - `NEON_USUARIO_ID` (por defecto `1`).
/// - `NEON_ACCESS_TOKEN` (token JWT de Neon; puede estar vacío en desarrollo).
///
/// Al integrar autenticación real solo se reemplaza esta clase: el resto de la
/// aplicación (bloc, repositorios y formularios) consume [usuarioId] y
/// [accessToken] sin conocer el origen.
class SesionActual {
  const SesionActual({this.usuarioId = 1, this.accessToken});

  /// Usuario dueño de la agenda.
  final int usuarioId;

  /// Token enviado al backend; `null` cuando no hay sesión autenticada.
  final String? accessToken;

  /// Construye la sesión a partir de los valores definidos en tiempo de
  /// compilación.
  factory SesionActual.desdeEntorno() {
    const token = String.fromEnvironment('NEON_ACCESS_TOKEN');
    return SesionActual(
      usuarioId: const int.fromEnvironment('NEON_USUARIO_ID', defaultValue: 1),
      accessToken: token.isEmpty ? null : token,
    );
  }
}
