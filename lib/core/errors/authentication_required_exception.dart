class AuthenticationRequiredException implements Exception {
  const AuthenticationRequiredException();

  @override
  String toString() =>
      'AuthenticationRequiredException: Se requiere un JWT válido para acceder a la API.';
}
