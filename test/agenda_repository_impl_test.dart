import 'dart:convert';

import 'package:actividad_8flutter/core/constants/neon_data_api_config.dart';
import 'package:actividad_8flutter/core/errors/agenda_repository_exception.dart';
import 'package:actividad_8flutter/core/network/postgrest_client.dart';
import 'package:actividad_8flutter/features/planner/data/datasources/planner_remote_data_source.dart';
import 'package:actividad_8flutter/features/planner/data/repositories/agenda_repository_impl.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('devuelve eventos como entidades de dominio', () async {
    final client = _client(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode([
              {
                'id': 8,
                'usuario_id': 3,
                'categoria_id': null,
                'titulo': 'Revisión',
                'descripcion': null,
                'ubicacion': null,
                'fecha_inicio': '2026-11-26T14:00:00Z',
                'fecha_fin': '2026-11-26T15:00:00Z',
                'created_at': null,
                'updated_at': null,
              },
            ]),
          ),
          200,
        ),
      ),
    );
    addTearDown(client.close);
    final repository = AgendaRepositoryImpl(
      remoteDataSource: PlannerRemoteDataSource(client: client),
    );

    final eventos = await repository.listarEventos(usuarioId: 3);

    expect(eventos.single, isA<Evento>());
    expect(eventos.single.id, 8);
    expect(eventos.single.titulo, 'Revisión');
  });

  test('convierte errores SQL y conserva el SQLSTATE', () async {
    final client = _client(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'code': '23505',
            'message': 'duplicate key value violates unique constraint',
            'details': 'Key already exists.',
            'hint': null,
          }),
          409,
        ),
      ),
    );
    addTearDown(client.close);
    final repository = AgendaRepositoryImpl(
      remoteDataSource: PlannerRemoteDataSource(client: client),
    );

    await expectLater(
      repository.crearEvento(_newEvent()),
      throwsA(
        isA<AgendaSqlException>()
            .having((error) => error.sqlState, 'SQLSTATE', '23505')
            .having((error) => error.details, 'details', 'Key already exists.'),
      ),
    );
  });

  test('convierte errores de red en una excepción del repositorio', () async {
    final client = _client(
      MockClient((_) async => throw http.ClientException('offline')),
    );
    addTearDown(client.close);
    final repository = AgendaRepositoryImpl(
      remoteDataSource: PlannerRemoteDataSource(client: client),
    );

    await expectLater(
      repository.crearEvento(_newEvent()),
      throwsA(isA<AgendaNetworkException>()),
    );
  });
}

PostgrestClient _client(http.Client httpClient) {
  return PostgrestClient(
    config: NeonDataApiConfig(baseUrl: 'https://example.neon.tech'),
    accessTokenProvider: () async => 'jwt',
    httpClient: httpClient,
  );
}

Evento _newEvent() {
  return Evento(
    usuarioId: 3,
    titulo: 'Nueva tarea',
    fechaInicio: DateTime.utc(2026, 11, 26, 14),
    fechaFin: DateTime.utc(2026, 11, 26, 15),
  );
}
