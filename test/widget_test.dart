// Prueba de humo de la aplicación base.
//
// Verifica que la app se construya con el tema y el idioma configurados y que
// muestre la pantalla inicial del Gestor de Agenda. Se inyecta un Bloc con un
// repositorio falso porque la configuración real de Neon llega por
// `--dart-define` y no está disponible en el entorno de pruebas.

import 'package:flutter_test/flutter_test.dart';

import 'package:actividad_8flutter/features/planner/domain/entities/categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:actividad_8flutter/features/planner/domain/repositories/agenda_repository.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/actualizar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/crear_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/eliminar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_eventos.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_bloc.dart';
import 'package:actividad_8flutter/features/planner/presentation/bloc/evento_event.dart';
import 'package:actividad_8flutter/features/planner/presentation/pages/planner_home_page.dart';
import 'package:actividad_8flutter/main.dart';

void main() {
  testWidgets('la app se construye y muestra la pantalla inicial', (
    WidgetTester tester,
  ) async {
    final repositorio = _RepositorioAgendaFalso();
    final bloc = EventoBloc(
      listarEventos: ListarEventos(repositorio),
      crearEvento: CrearEvento(repositorio),
      actualizarEvento: ActualizarEvento(repositorio),
      eliminarEvento: EliminarEvento(repositorio),
      usuarioId: 1,
    );
    addTearDown(bloc.close);
    bloc.add(const CargarEventos());

    await tester.pumpWidget(PlannerApp(home: PlannerHomePage(bloc: bloc)));
    await tester.pumpAndSettle();

    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Gestor de Agenda'), findsOneWidget);
    expect(find.text('Aún no tienes eventos'), findsOneWidget);
  });
}

class _RepositorioAgendaFalso implements AgendaRepository {
  @override
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
  }) async => const <Evento>[];

  @override
  Future<Evento> crearEvento(Evento evento) async => evento;

  @override
  Future<Evento> actualizarEvento(Evento evento) async => evento;

  @override
  Future<void> eliminarEvento({
    required int id,
    required int usuarioId,
  }) async {}

  @override
  Future<List<Categoria>> listarCategorias({required int usuarioId}) async =>
      const <Categoria>[];

  @override
  Future<Categoria> crearCategoria(Categoria categoria) async => categoria;
}
