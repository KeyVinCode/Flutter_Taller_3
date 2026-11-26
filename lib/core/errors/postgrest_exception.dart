class PostgrestException implements Exception {
  const PostgrestException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
    this.hint,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final String? details;
  final String? hint;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' (HTTP $statusCode)';
    final errorCode = code == null ? '' : ' [$code]';
    final errorDetails = details == null ? '' : ' $details';
    final errorHint = hint == null ? '' : ' Sugerencia: $hint';
    return 'PostgrestException$status$errorCode: $message'
        '$errorDetails$errorHint';
  }
}
