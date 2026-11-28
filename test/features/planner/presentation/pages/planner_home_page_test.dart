import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:actividad_8flutter/core/utils/date_formatters.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/actualizar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/crear_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/eliminar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_categorias.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_eventos.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_bloc.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_event.dart';
import 'package:actividad_8flutter/features/planner/presentation/pages/planner_home_page.dart';
import 'package:actividad_8flutter/main.dart';

import '../fakes/fake_agenda_repository.dart';

Evento _evento({int? id = 1, String titulo = 'Reunión de equipo'}) {
  final ahora = DateTime.now();
  return Evento(
    id: id,
    usuarioId: 1,
    titulo: titulo,
    fechaInicio: DateTime(ahora.year, ahora.month, 15, 9),
    fechaFin: DateTime(ahora.year, ahora.month, 15, 10),
  );
}

EventoBloc _crearBloc(FakeAgendaRepository repositorio) {
  return EventoBloc(
    listarEventos: ListarEventos(repositorio),
    crearEvento: CrearEvento(repositorio),
    actualizarEvento: ActualizarEvento(repositorio),
    eliminarEvento: EliminarEvento(repositorio),
    usuarioId: 1,
  );
}

void _pantallaGrande(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1500);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Deja correr las cadenas de `await` del bloc dentro de `testWidgets`.
Future<void> _procesarOperacion(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  await tester.pumpAndSettle();
}

void main() {
  late FakeAgendaRepository repositorio;
  late EventoBloc bloc;

  setUp(() {
    repositorio = FakeAgendaRepository(
      eventos: <Evento>[_evento()],
      categorias: const <Categoria>[
        Categoria(id: 1, usuarioId: 1, nombre: 'Trabajo', colorHex: '#00897B'),
      ],
    );
    bloc = _crearBloc(repositorio);
    bloc.add(const CargarEventos());
  });

  tearDown(() => bloc.close());

  Future<void> abrirHome(WidgetTester tester) async {
    _pantallaGrande(tester);
    await tester.pumpWidget(
      PlannerApp(
        home: PlannerHomePage(
          bloc: bloc,
          listarCategorias: ListarCategorias(repositorio),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('el FAB abre el formulario para crear un evento', (tester) async {
    await abrirHome(tester);

    await tester.tap(find.byKey(const ValueKey('fab-nuevo-evento')));
    await tester.pumpAndSettle();

    expect(find.text('Crear evento'), findsOneWidget);
    expect(find.text('Detalles del evento'), findsOneWidget);
    expect(find.text('Nuevo evento'), findsOneWidget);
  });

  testWidgets('tocar una tarjeta abre el formulario de edición', (
    tester,
  ) async {
    await abrirHome(tester);

    await tester.tap(find.text('Reunión de equipo'));
    await tester.pumpAndSettle();

    expect(find.text('Editar evento'), findsOneWidget);
    final campo = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(campo.controller?.text, 'Reunión de equipo');
  });

  testWidgets('crear desde el FAB refresca la lista y muestra un snackbar', (
    tester,
  ) async {
    await abrirHome(tester);

    await tester.tap(find.byKey(const ValueKey('fab-nuevo-evento')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Cita médica');
    await tester.tap(find.text('Crear evento'));
    await _procesarOperacion(tester);

    expect(repositorio.ultimoCreado?.titulo, 'Cita médica');
    expect(find.text('Cita médica'), findsOneWidget);
    expect(find.text('Evento creado correctamente.'), findsOneWidget);
  });

  testWidgets('cancelar la confirmación no elimina el evento', (tester) async {
    await abrirHome(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar evento'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cancelar-eliminar')));
    await tester.pumpAndSettle();

    expect(repositorio.ultimoIdEliminado, isNull);
    expect(find.text('Reunión de equipo'), findsOneWidget);
  });

  testWidgets(
    'confirmar la eliminación muestra snackbar y actualiza la lista',
    (tester) async {
      await abrirHome(tester);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirmar-eliminar')));
      await _procesarOperacion(tester);

      expect(repositorio.ultimoIdEliminado, 1);
      expect(find.text('Evento eliminado correctamente.'), findsOneWidget);
      expect(find.text('Aún no tienes eventos'), findsOneWidget);
    },
  );

  testWidgets('un fallo al eliminar conserva la lista y muestra el error', (
    tester,
  ) async {
    await abrirHome(tester);
    repositorio.fallarMutacion = true;

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirmar-eliminar')));
    await _procesarOperacion(tester);

    expect(find.text('No se pudo eliminar el evento.'), findsOneWidget);
    expect(find.text('Reunión de equipo'), findsOneWidget);
  });

  testWidgets('cambiar de mes recarga el rango visible', (tester) async {
    await abrirHome(tester);

    final siguiente = DateFormatters.agregarMeses(DateTime.now(), 1);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(repositorio.ultimoDesde, DateFormatters.inicioDeMes(siguiente));
    expect(repositorio.ultimoHasta, DateFormatters.finDeMes(siguiente));
    expect(find.text(DateFormatters.etiquetaMes(siguiente)), findsOneWidget);
  });

  testWidgets('el mes visible se conserva aunque la lista quede vacía', (
    tester,
  ) async {
    await abrirHome(tester);
    repositorio.eventos = <Evento>[];
    bloc.add(const RecargarEventos());
    await _procesarOperacion(tester);
    expect(find.text('Aún no tienes eventos'), findsOneWidget);

    final siguiente = DateFormatters.agregarMeses(DateTime.now(), 3);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byIcon(Icons.chevron_right));
      await _procesarOperacion(tester);
    }

    expect(find.text(DateFormatters.etiquetaMes(siguiente)), findsOneWidget);
    expect(repositorio.ultimoDesde, DateFormatters.inicioDeMes(siguiente));
  });
}
