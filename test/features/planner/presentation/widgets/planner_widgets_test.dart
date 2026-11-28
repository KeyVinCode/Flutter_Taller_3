// Pruebas de los widgets reutilizables del Planner (capa de presentación).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:actividad_8flutter/core/theme/app_theme.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:actividad_8flutter/features/planner/presentation/widgets/app_snackbar.dart';
import 'package:actividad_8flutter/features/planner/presentation/widgets/empty_state.dart';
import 'package:actividad_8flutter/features/planner/presentation/widgets/error_view.dart';
import 'package:actividad_8flutter/features/planner/presentation/widgets/event_card.dart';
import 'package:actividad_8flutter/features/planner/presentation/widgets/loading_view.dart';
import 'package:actividad_8flutter/features/planner/presentation/widgets/planner_calendar.dart';
import 'package:actividad_8flutter/features/planner/presentation/widgets/section_header.dart';

void main() {
  group('EventCard', () {
    testWidgets('muestra título, horario, ubicación, categoría y estado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _envolver(
          EventCard(
            evento: _evento(
              ubicacion: 'Sala 2',
              descripcion: 'Revisar avances del proyecto',
            ),
            categoria: const Categoria(
              usuarioId: 1,
              nombre: 'Trabajo',
              colorHex: '#00897B',
            ),
            ahora: DateTime(2026, 11, 1, 8),
          ),
        ),
      );

      expect(find.text('Reunión de equipo'), findsOneWidget);
      expect(find.textContaining('27 nov 2026'), findsOneWidget);
      expect(find.text('Sala 2'), findsOneWidget);
      expect(find.text('Revisar avances del proyecto'), findsOneWidget);
      expect(find.text('Trabajo'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
    });

    testWidgets('indica cuando el evento ya finalizó', (tester) async {
      await tester.pumpWidget(
        _envolver(
          EventCard(evento: _evento(), ahora: DateTime(2026, 11, 28, 12)),
        ),
      );

      expect(find.text('Finalizado'), findsOneWidget);
    });

    testWidgets('invoca onEliminar desde el menú de acciones', (tester) async {
      var eliminado = false;

      await tester.pumpWidget(
        _envolver(
          EventCard(
            evento: _evento(),
            ahora: DateTime(2026, 11, 1),
            onEliminar: () => eliminado = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(eliminado, isTrue);
    });
  });

  group('PlannerCalendar', () {
    testWidgets('muestra el mes, resume eventos y reporta selección y navegación', (
      tester,
    ) async {
      DateTime? diaSeleccionado;
      DateTime? mesReportado;

      await tester.pumpWidget(
        _envolver(
          PlannerCalendar(
            mesInicial: DateTime(2026, 11),
            hoy: DateTime(2026, 11, 1),
            eventos: [_evento()],
            onDiaSeleccionado: (dia) => diaSeleccionado = dia,
            onMesCambiado: (mes) => mesReportado = mes,
          ),
        ),
      );

      expect(find.text('Noviembre 2026'), findsOneWidget);
      expect(find.text('1 evento este mes'), findsOneWidget);
      expect(find.text('Lun'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('calendar-day-27')));
      await tester.pump();
      expect(diaSeleccionado, DateTime(2026, 11, 27));

      await tester.tap(find.byTooltip('Mes siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Diciembre 2026'), findsOneWidget);
      expect(mesReportado, DateTime(2026, 12));
    });

    testWidgets('respeta un día seleccionado externo', (tester) async {
      await tester.pumpWidget(
        _envolver(
          PlannerCalendar(
            diaSeleccionado: DateTime(2026, 10, 15),
            hoy: DateTime(2026, 11, 1),
          ),
        ),
      );

      expect(find.text('Octubre 2026'), findsOneWidget);
      expect(find.text('Sin eventos este mes'), findsOneWidget);
    });

    test('agruparPorDia marca todos los días de un evento largo', () {
      final evento = Evento(
        id: 1,
        usuarioId: 1,
        titulo: 'Congreso',
        fechaInicio: DateTime(2026, 11, 27, 9),
        fechaFin: DateTime(2026, 11, 29, 18),
      );

      final dias = PlannerCalendar.agruparPorDia([evento]);
      expect(dias.length, 3);
      expect(dias[DateTime(2026, 11, 28)]!.single.titulo, 'Congreso');

      expect(
        PlannerCalendar.eventosDelDia([evento], DateTime(2026, 11, 28)),
        hasLength(1),
      );
      expect(
        PlannerCalendar.eventosDelDia([evento], DateTime(2026, 12, 1)),
        isEmpty,
      );
    });
  });

  group('Estados y utilidades', () {
    testWidgets('EmptyState muestra el mensaje y ejecuta la acción', (
      tester,
    ) async {
      var reiniciado = false;

      await tester.pumpWidget(
        _envolver(
          EmptyState(
            titulo: 'Sin eventos',
            mensaje: 'Crea tu primer evento',
            textoAccion: 'Crear evento',
            onAccion: () => reiniciado = true,
          ),
        ),
      );

      expect(find.text('Sin eventos'), findsOneWidget);
      expect(find.text('Crea tu primer evento'), findsOneWidget);

      await tester.tap(find.text('Crear evento'));
      await tester.pump();
      expect(reiniciado, isTrue);
    });

    testWidgets('ErrorView muestra el mensaje y reintenta', (tester) async {
      var reintentos = 0;

      await tester.pumpWidget(
        _envolver(
          ErrorView(
            mensaje: 'No hay conexión',
            onReintentar: () => reintentos++,
          ),
        ),
      );

      expect(find.text('Algo salió mal'), findsOneWidget);
      expect(find.text('No hay conexión'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(reintentos, 1);
    });

    testWidgets('LoadingView muestra el indicador y el mensaje', (tester) async {
      await tester.pumpWidget(
        _envolver(const LoadingView(mensaje: 'Cargando eventos...')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando eventos...'), findsOneWidget);
    });

    testWidgets('SectionHeader muestra título, subtítulo y acción', (
      tester,
    ) async {
      var accionEjecutada = false;

      await tester.pumpWidget(
        _envolver(
          SectionHeader(
            titulo: 'Próximos eventos',
            subtitulo: '3 eventos',
            textoAccion: 'Ver todos',
            onAccion: () => accionEjecutada = true,
          ),
        ),
      );

      expect(find.text('Próximos eventos'), findsOneWidget);
      expect(find.text('3 eventos'), findsOneWidget);

      await tester.tap(find.text('Ver todos'));
      await tester.pump();
      expect(accionEjecutada, isTrue);
    });

    testWidgets('AppSnackBar muestra el mensaje con el icono del tipo', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () =>
                      AppSnackBar.exito(context, 'Evento guardado'),
                  child: const Text('Mostrar'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mostrar'));
      await tester.pump();

      expect(find.text('Evento guardado'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}

Widget _envolver(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

Evento _evento({String? ubicacion, String? descripcion, DateTime? inicio}) {
  final fechaInicio = inicio ?? DateTime(2026, 11, 27, 9);
  return Evento(
    id: 1,
    usuarioId: 1,
    categoriaId: 2,
    titulo: 'Reunión de equipo',
    descripcion: descripcion,
    ubicacion: ubicacion,
    fechaInicio: fechaInicio,
    fechaFin: fechaInicio.add(const Duration(hours: 1)),
  );
}
