import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:actividad_8flutter/features/planner/domain/entities/categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/actualizar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/crear_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/eliminar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_categorias.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_eventos.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_bloc.dart';
import 'package:actividad_8flutter/features/planner/presentation/pages/evento_form_page.dart';
import 'package:actividad_8flutter/main.dart';

import '../fakes/fake_agenda_repository.dart';

Evento _evento({int? id = 1, String titulo = 'Reunión de equipo'}) => Evento(
  id: id,
  usuarioId: 1,
  titulo: titulo,
  descripcion: 'Revisar avances',
  ubicacion: 'Sala 2',
  fechaInicio: DateTime(2026, 11, 27, 9),
  fechaFin: DateTime(2026, 11, 27, 10),
  createdAt: DateTime(2026, 11, 20),
);

EventoBloc _crearBloc(FakeAgendaRepository repositorio) {
  return EventoBloc(
    listarEventos: ListarEventos(repositorio),
    crearEvento: CrearEvento(repositorio),
    actualizarEvento: ActualizarEvento(repositorio),
    eliminarEvento: EliminarEvento(repositorio),
    usuarioId: 1,
  );
}

Widget _appConFormulario({
  required EventoBloc bloc,
  required ListarCategorias listarCategorias,
  Evento? evento,
}) {
  return PlannerApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push<String>(
              MaterialPageRoute<String>(
                builder: (_) => EventoFormPage(
                  bloc: bloc,
                  listarCategorias: listarCategorias,
                  evento: evento,
                ),
              ),
            ),
            child: const Text('Abrir formulario'),
          ),
        ),
      ),
    ),
  );
}

Future<void> _abrirFormulario(
  WidgetTester tester, {
  required EventoBloc bloc,
  required ListarCategorias listarCategorias,
  Evento? evento,
}) async {
  await tester.pumpWidget(
    _appConFormulario(
      bloc: bloc,
      listarCategorias: listarCategorias,
      evento: evento,
    ),
  );
  await tester.tap(find.text('Abrir formulario'));
  await tester.pumpAndSettle();
}

void _pantallaGrande(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
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
  late ListarCategorias listarCategorias;

  setUp(() {
    repositorio = FakeAgendaRepository(
      categorias: const <Categoria>[
        Categoria(id: 1, usuarioId: 1, nombre: 'Trabajo', colorHex: '#00897B'),
      ],
    );
    bloc = _crearBloc(repositorio);
    listarCategorias = ListarCategorias(repositorio);
  });

  tearDown(() => bloc.close());

  testWidgets('valida el título obligatorio antes de enviar', (tester) async {
    _pantallaGrande(tester);
    await _abrirFormulario(
      tester,
      bloc: bloc,
      listarCategorias: listarCategorias,
    );

    expect(find.text('Nuevo evento'), findsOneWidget);
    expect(find.text('Trabajo'), findsOneWidget);
    expect(find.text('Sin categoría'), findsOneWidget);

    await tester.tap(find.text('Crear evento'));
    await tester.pumpAndSettle();

    expect(find.text('El título es obligatorio.'), findsOneWidget);
    expect(repositorio.ultimoCreado, isNull);
  });

  testWidgets('crea un evento con la categoría seleccionada', (tester) async {
    _pantallaGrande(tester);
    await _abrirFormulario(
      tester,
      bloc: bloc,
      listarCategorias: listarCategorias,
    );

    await tester.enterText(find.byType(TextFormField).first, 'Nueva reunión');
    await tester.tap(find.text('Trabajo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Crear evento'));
    await _procesarOperacion(tester);

    expect(repositorio.ultimoCreado?.titulo, 'Nueva reunión');
    expect(repositorio.ultimoCreado?.categoriaId, 1);
    expect(find.text('Crear evento'), findsNothing);
  });

  testWidgets('edita un evento conservando id y fecha de creación', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final original = _evento();
    await _abrirFormulario(
      tester,
      bloc: bloc,
      listarCategorias: listarCategorias,
      evento: original,
    );

    expect(find.text('Editar evento'), findsOneWidget);
    final primerCampo = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(primerCampo.controller?.text, 'Reunión de equipo');

    await tester.enterText(
      find.byType(TextFormField).first,
      'Reunión actualizada',
    );
    await tester.tap(find.text('Guardar cambios'));
    await _procesarOperacion(tester);

    expect(repositorio.ultimoActualizado?.id, 1);
    expect(repositorio.ultimoActualizado?.titulo, 'Reunión actualizada');
    expect(repositorio.ultimoActualizado?.createdAt, original.createdAt);
  });

  testWidgets('muestra un snackbar y permanece abierto si falla el guardado', (
    tester,
  ) async {
    _pantallaGrande(tester);
    repositorio.fallarMutacion = true;
    await _abrirFormulario(
      tester,
      bloc: bloc,
      listarCategorias: listarCategorias,
    );

    await tester.enterText(find.byType(TextFormField).first, 'Evento fallido');
    await tester.tap(find.text('Crear evento'));
    await _procesarOperacion(tester);

    expect(find.text('No se pudo crear el evento.'), findsOneWidget);
    expect(find.text('Crear evento'), findsOneWidget);
  });
}
