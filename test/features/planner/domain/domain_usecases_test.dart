import 'package:actividad_8flutter/features/planner/domain/entities/categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/entities/evento.dart';
import 'package:actividad_8flutter/features/planner/domain/repositories/agenda_repository.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/actualizar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/crear_categoria.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/crear_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/eliminar_evento.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_categorias.dart';
import 'package:actividad_8flutter/features/planner/domain/usecases/listar_eventos.dart';
import 'package:flutter_test/flutter_test.dart';

Evento _evento({
  int? id,
  int usuarioId = 1,
  int? categoriaId,
  String titulo = 'Reunión de equipo',
  DateTime? inicio,
  DateTime? fin,
}) {
  return Evento(
    id: id,
    usuarioId: usuarioId,
    categoriaId: categoriaId,
    titulo: titulo,
    fechaInicio: inicio ?? DateTime(2026, 11, 26, 9),
    fechaFin: fin ?? DateTime(2026, 11, 26, 10),
  );
}

class _FakeAgendaRepository implements AgendaRepository {
  final List<String> llamadas = <String>[];

  Evento? ultimoCreado;
  Evento? ultimoActualizado;
  int? ultimoIdEliminado;
  int? ultimoUsuarioEliminado;
  int? ultimoUsuarioListado;
  DateTime? ultimoDesde;
  DateTime? ultimoHasta;
  int? ultimaCategoria;

  @override
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    DateTime? desde,
    DateTime? hasta,
    int? categoriaId,
  }) async {
    llamadas.add('listarEventos');
    ultimoUsuarioListado = usuarioId;
    ultimoDesde = desde;
    ultimoHasta = hasta;
    ultimaCategoria = categoriaId;
    return <Evento>[_evento()];
  }

  @override
  Future<Evento> crearEvento(Evento evento) async {
    llamadas.add('crearEvento');
    ultimoCreado = evento;
    return evento;
  }

  @override
  Future<Evento> actualizarEvento(Evento evento) async {
    llamadas.add('actualizarEvento');
    ultimoActualizado = evento;
    return evento;
  }

  @override
  Future<void> eliminarEvento({required int id, required int usuarioId}) async {
    llamadas.add('eliminarEvento');
    ultimoIdEliminado = id;
    ultimoUsuarioEliminado = usuarioId;
  }

  @override
  Future<List<Categoria>> listarCategorias({required int usuarioId}) async {
    llamadas.add('listarCategorias');
    return const <Categoria>[Categoria(id: 1, usuarioId: 1, nombre: 'Trabajo')];
  }

  @override
  Future<Categoria> crearCategoria(Categoria categoria) async {
    llamadas.add('crearCategoria');
    return categoria;
  }
}

void main() {
  late _FakeAgendaRepository repository;

  setUp(() {
    repository = _FakeAgendaRepository();
  });

  group('Entidades de dominio', () {
    test('Evento valida que la fecha de fin no sea anterior al inicio', () {
      final valido = _evento();
      final invalido = _evento(
        inicio: DateTime(2026, 11, 26, 12),
        fin: DateTime(2026, 11, 26, 10),
      );

      expect(valido.tieneFechasValidas, isTrue);
      expect(invalido.tieneFechasValidas, isFalse);
    });

    test('Evento valida que el título no esté vacío', () {
      expect(_evento().tieneTituloValido, isTrue);
      expect(_evento(titulo: '   ').tieneTituloValido, isFalse);
    });

    test('Categoria conserva los campos del esquema SQL', () {
      const categoria = Categoria(
        id: 3,
        usuarioId: 1,
        nombre: 'Trabajo',
        colorHex: '#3949AB',
      );

      expect(categoria.tieneNombreValido, isTrue);
      expect(categoria.colorHex, '#3949AB');
      expect(
        const Categoria(usuarioId: 1, nombre: '').tieneNombreValido,
        isFalse,
      );
    });
  });

  group('CrearEvento', () {
    test('delega en el repositorio cuando el evento es válido', () async {
      final evento = _evento(categoriaId: 2);

      final resultado = await CrearEvento(repository)(evento);

      expect(resultado, same(evento));
      expect(repository.llamadas, ['crearEvento']);
      expect(repository.ultimoCreado, same(evento));
    });

    test('rechaza título vacío sin tocar el repositorio', () async {
      await expectLater(
        CrearEvento(repository)(_evento(titulo: '')),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });

    test('rechaza fechas invertidas sin tocar el repositorio', () async {
      await expectLater(
        CrearEvento(repository)(
          _evento(
            inicio: DateTime(2026, 11, 26, 12),
            fin: DateTime(2026, 11, 26, 10),
          ),
        ),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });

    test('rechaza un usuario inválido sin tocar el repositorio', () async {
      await expectLater(
        CrearEvento(repository)(_evento(usuarioId: 0)),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });
  });

  group('ActualizarEvento', () {
    test('exige que el evento tenga id', () async {
      await expectLater(
        ActualizarEvento(repository)(_evento()),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });

    test('delega en el repositorio cuando el id es válido', () async {
      final evento = _evento(id: 10);

      final resultado = await ActualizarEvento(repository)(evento);

      expect(resultado.id, 10);
      expect(repository.llamadas, ['actualizarEvento']);
      expect(repository.ultimoActualizado, same(evento));
    });
  });

  group('EliminarEvento', () {
    test('envía id y usuario al repositorio', () async {
      await EliminarEvento(repository)(id: 7, usuarioId: 1);

      expect(repository.llamadas, ['eliminarEvento']);
      expect(repository.ultimoIdEliminado, 7);
      expect(repository.ultimoUsuarioEliminado, 1);
    });

    test('rechaza id inválido sin tocar el repositorio', () async {
      await expectLater(
        EliminarEvento(repository)(id: 0, usuarioId: 1),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });
  });

  group('ListarEventos', () {
    test('delega los filtros al repositorio', () async {
      final desde = DateTime(2026, 11, 1);
      final hasta = DateTime(2026, 11, 30);

      final eventos = await ListarEventos(repository)(
        usuarioId: 1,
        desde: desde,
        hasta: hasta,
        categoriaId: 2,
      );

      expect(eventos, hasLength(1));
      expect(repository.llamadas, ['listarEventos']);
      expect(repository.ultimoUsuarioListado, 1);
      expect(repository.ultimoDesde, desde);
      expect(repository.ultimoHasta, hasta);
      expect(repository.ultimaCategoria, 2);
    });

    test('rechaza un rango de fechas invertido', () async {
      await expectLater(
        ListarEventos(repository)(
          usuarioId: 1,
          desde: DateTime(2026, 11, 30),
          hasta: DateTime(2026, 11, 1),
        ),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });
  });

  group('ListarCategorias', () {
    test('delega en el repositorio con el usuario indicado', () async {
      final categorias = await ListarCategorias(repository)(usuarioId: 1);

      expect(categorias, hasLength(1));
      expect(categorias.single.nombre, 'Trabajo');
      expect(repository.llamadas, ['listarCategorias']);
    });

    test('rechaza un usuario inválido', () async {
      await expectLater(
        ListarCategorias(repository)(usuarioId: 0),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });
  });

  group('CrearCategoria', () {
    test('delega en el repositorio cuando el nombre es válido', () async {
      const categoria = Categoria(usuarioId: 1, nombre: 'Personal');

      final resultado = await CrearCategoria(repository)(categoria);

      expect(resultado, same(categoria));
      expect(repository.llamadas, ['crearCategoria']);
    });

    test('rechaza un nombre vacío', () async {
      await expectLater(
        CrearCategoria(repository)(
          const Categoria(usuarioId: 1, nombre: '   '),
        ),
        throwsArgumentError,
      );
      expect(repository.llamadas, isEmpty);
    });
  });
}
