import 'dart:convert';

import 'package:actividad_8flutter/core/constants/neon_data_api_config.dart';
import 'package:actividad_8flutter/core/network/postgrest_client.dart';
import 'package:actividad_8flutter/features/planner/data/datasources/planner_remote_data_source.dart';
import 'package:actividad_8flutter/features/planner/data/models/evento_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('mapea columnas SQL al listar eventos del usuario', () async {
    final client = PostgrestClient(
      config: NeonDataApiConfig(baseUrl: 'https://example.neon.tech'),
      accessTokenProvider: () async => 'jwt',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/eventos');
        expect(request.url.queryParameters['usuario_id'], 'eq.5');
        expect(request.url.queryParameters['categoria_id'], 'eq.2');
        expect(
          request.url.queryParameters['fecha_inicio'],
          'gte.2026-11-01T00:00:00.000Z',
        );
        return http.Response.bytes(
          utf8.encode(
            jsonEncode([
              {
                'id': 9,
                'usuario_id': 5,
                'categoria_id': 2,
                'titulo': 'Planificación',
                'descripcion': null,
                'ubicacion': 'Sala 1',
                'fecha_inicio': '2026-11-26T14:00:00Z',
                'fecha_fin': '2026-11-26T15:00:00Z',
                'created_at': '2026-11-01T09:00:00Z',
                'updated_at': '2026-11-01T09:00:00Z',
              },
            ]),
          ),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final dataSource = PlannerRemoteDataSource(client: client);

    final eventos = await dataSource.listarEventos(
      usuarioId: 5,
      desde: DateTime.utc(2026, 11),
      categoriaId: 2,
    );

    expect(eventos, hasLength(1));
    expect(eventos.single.id, 9);
    expect(eventos.single.ubicacion, 'Sala 1');
    expect(eventos.single.fechaInicio, DateTime.utc(2026, 11, 26, 14));
  });

  test('crea eventos con las columnas esperadas por el esquema SQL', () async {
    final client = PostgrestClient(
      config: NeonDataApiConfig(baseUrl: 'https://example.neon.tech'),
      accessTokenProvider: () async => 'jwt',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/eventos');
        expect(jsonDecode(request.body), {
          'usuario_id': 5,
          'categoria_id': null,
          'titulo': 'Nueva tarea',
          'descripcion': null,
          'ubicacion': null,
          'fecha_inicio': '2026-11-26T14:00:00.000Z',
          'fecha_fin': '2026-11-26T15:00:00.000Z',
        });
        return http.Response(
          jsonEncode([
            {
              'id': 10,
              'usuario_id': 5,
              'categoria_id': null,
              'titulo': 'Nueva tarea',
              'descripcion': null,
              'ubicacion': null,
              'fecha_inicio': '2026-11-26T14:00:00Z',
              'fecha_fin': '2026-11-26T15:00:00Z',
              'created_at': '2026-11-20T10:00:00Z',
              'updated_at': '2026-11-20T10:00:00Z',
            },
          ]),
          201,
        );
      }),
    );
    addTearDown(client.close);
    final dataSource = PlannerRemoteDataSource(client: client);

    final evento = await dataSource.crearEvento(
      EventoModel(
        usuarioId: 5,
        titulo: 'Nueva tarea',
        fechaInicio: DateTime.utc(2026, 11, 26, 14),
        fechaFin: DateTime.utc(2026, 11, 26, 15),
      ),
    );

    expect(evento.id, 10);
    expect(evento.usuarioId, 5);
  });
}
