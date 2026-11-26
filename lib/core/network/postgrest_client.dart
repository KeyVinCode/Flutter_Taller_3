import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/neon_data_api_config.dart';
import '../errors/authentication_required_exception.dart';
import '../errors/postgrest_exception.dart';

typedef AccessTokenProvider = Future<String?> Function();

class PostgrestClient {
  PostgrestClient({
    required NeonDataApiConfig config,
    required this.accessTokenProvider,
    http.Client? httpClient,
  }) : _baseUri = config.baseUri,
       _httpClient = httpClient ?? http.Client();

  final Uri _baseUri;
  final AccessTokenProvider accessTokenProvider;
  final http.Client _httpClient;

  Future<dynamic> get(
    String table, {
    Map<String, String> queryParameters = const {},
  }) {
    return _request('GET', table, queryParameters: queryParameters);
  }

  Future<dynamic> post(String table, Map<String, Object?> body) {
    return _request('POST', table, body: body);
  }

  Future<dynamic> patch(
    String table,
    Map<String, String> queryParameters,
    Map<String, Object?> body,
  ) {
    return _request(
      'PATCH',
      table,
      queryParameters: queryParameters,
      body: body,
    );
  }

  Future<void> delete(
    String table,
    Map<String, String> queryParameters,
  ) async {
    await _request('DELETE', table, queryParameters: queryParameters);
  }

  Future<dynamic> _request(
    String method,
    String table, {
    Map<String, String> queryParameters = const {},
    Map<String, Object?>? body,
  }) async {
    final accessToken = (await accessTokenProvider())?.trim();
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthenticationRequiredException();
    }

    final uri = _baseUri
        .replace(path: '${_baseUri.path}/$table')
        .replace(queryParameters: queryParameters.isEmpty ? null : queryParameters);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    if (body != null) {
      headers['Content-Type'] = 'application/json';
      headers['Prefer'] = 'return=representation';
    }

    final response = await _httpClient.send(
      http.Request(method, uri)
        ..headers.addAll(headers)
        ..body = body == null ? '' : jsonEncode(body),
    );
    final responseBody = utf8.decode(await response.stream.toBytes());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _errorFromResponse(response.statusCode, responseBody);
    }
    if (responseBody.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(responseBody);
    } on FormatException {
      throw PostgrestException(
        statusCode: response.statusCode,
        message: 'La API devolvió una respuesta JSON no válida.',
      );
    }
  }

  PostgrestException _errorFromResponse(int statusCode, String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return PostgrestException(
          statusCode: statusCode,
          message: decoded['message']?.toString() ?? 'Error de PostgREST.',
          code: decoded['code']?.toString(),
          details: decoded['details']?.toString(),
          hint: decoded['hint']?.toString(),
        );
      }
    } on FormatException {
      // Some reverse proxies return plain-text error bodies.
    }
    return PostgrestException(
      statusCode: statusCode,
      message: body.isEmpty ? 'Error de PostgREST.' : body,
    );
  }

  void close() => _httpClient.close();
}
