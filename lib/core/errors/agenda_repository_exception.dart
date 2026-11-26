class AgendaRepositoryException implements Exception {
  const AgendaRepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

class AgendaNetworkException extends AgendaRepositoryException {
  const AgendaNetworkException(super.message, {super.cause});
}

class AgendaAuthenticationException extends AgendaRepositoryException {
  const AgendaAuthenticationException(super.message, {super.cause});
}

class AgendaSqlException extends AgendaRepositoryException {
  const AgendaSqlException(
    super.message, {
    required this.sqlState,
    this.statusCode,
    this.details,
    this.hint,
    super.cause,
  });

  final String sqlState;
  final int? statusCode;
  final String? details;
  final String? hint;
}

class AgendaApiException extends AgendaRepositoryException {
  const AgendaApiException(
    super.message, {
    this.statusCode,
    this.code,
    this.details,
    this.hint,
    super.cause,
  });

  final int? statusCode;
  final String? code;
  final String? details;
  final String? hint;
}

class AgendaDataException extends AgendaRepositoryException {
  const AgendaDataException(super.message, {super.cause});
}
