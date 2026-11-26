import 'dart:convert';

import 'package:actividad_8flutter/core/constants/neon_data_api_config.dart';
import 'package:actividad_8flutter/core/errors/authentication_required_exception.dart';
import 'package:actividad_8flutter/core/network/postgrest_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('envía JWT y consulta filtros a la ruta PostgREST configurada', () async {
    http.Request? capturedRequest;
    final client = PostgrestClient(
      config: NeonDataApiConfig(
        baseUrl: 'https://example.neon.tech/rest/v1/',
      ),
      accessTokenProvider: () async => 'signed-user-token',
      httpClient: MockClient((request) async {
        capturedRequest = request;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode([
            {
              'id': 12,
              'usuario_id': 4,
              'titulo': 'Reunión',
              'fecha_inicio': '2026-11-26T14:00:00Z',
              'fecha_fin': '2026-11-26T15:00:00Z',
            },
            ]),
          ),
          200,
        );
      }),
    );
    addTearDown(client.close);

    final result = await client.get(
      'eventos',
      queryParameters: {'usuario_id': 'eq.4', 'select': '*'},
    );

    expect(result, isA<List<dynamic>>());
    expect(capturedRequest!.url.path, '/rest/v1/eventos');
    expect(capturedRequest!.url.queryParameters['usuario_id'], 'eq.4');
    expect(
      capturedRequest!.headers['authorization'],
      'Bearer signed-user-token',
    );
  });

  test('no realiza solicitudes si no hay JWT', () async {
    var requestSent = false;
    final client = PostgrestClient(
      config: NeonDataApiConfig(baseUrl: 'https://example.neon.tech'),
      accessTokenProvider: () async => null,
      httpClient: MockClient((_) async {
        requestSent = true;
        return http.Response('[]', 200);
      }),
    );
    addTearDown(client.close);

    await expectLater(
      client.get('eventos'),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    expect(requestSent, isFalse);
  });
}
