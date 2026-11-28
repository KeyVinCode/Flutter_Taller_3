import 'package:get_it/get_it.dart';

import '../../features/planner/data/datasources/planner_remote_data_source.dart';
import '../../features/planner/data/repositories/agenda_repository_impl.dart';
import '../../features/planner/domain/repositories/agenda_repository.dart';
import '../../features/planner/domain/usecases/actualizar_evento.dart';
import '../../features/planner/domain/usecases/crear_evento.dart';
import '../../features/planner/domain/usecases/eliminar_evento.dart';
import '../../features/planner/domain/usecases/listar_eventos.dart';
import '../../features/planner/presentation/bloc/evento_bloc.dart';
import '../constants/neon_data_api_config.dart';
import '../network/postgrest_client.dart';

/// Instancia global del service locator.
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<PostgrestClient>(
    () => PostgrestClient(
      config: NeonDataApiConfig.fromEnvironment(),
      accessTokenProvider: _accessToken,
    ),
  );

  // DataSources
  sl.registerLazySingleton<PlannerRemoteDataSource>(
    () => PlannerRemoteDataSource(client: sl<PostgrestClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AgendaRepository>(
    () => AgendaRepositoryImpl(remoteDataSource: sl<PlannerRemoteDataSource>()),
  );

  // UseCases
  sl.registerLazySingleton<ListarEventos>(
    () => ListarEventos(sl<AgendaRepository>()),
  );
  sl.registerLazySingleton<CrearEvento>(
    () => CrearEvento(sl<AgendaRepository>()),
  );
  sl.registerLazySingleton<ActualizarEvento>(
    () => ActualizarEvento(sl<AgendaRepository>()),
  );
  sl.registerLazySingleton<EliminarEvento>(
    () => EliminarEvento(sl<AgendaRepository>()),
  );

  // Bloc (factory: cada pantalla crea su propia instancia)
  sl.registerFactory<EventoBloc>(
    () => EventoBloc(
      listarEventos: sl<ListarEventos>(),
      crearEvento: sl<CrearEvento>(),
      actualizarEvento: sl<ActualizarEvento>(),
      eliminarEvento: sl<EliminarEvento>(),
    ),
  );
}

/// Token temporal hasta que exista la pantalla de login.
/// Se define con --dart-define=NEON_ACCESS_TOKEN=... (nunca escrito en el código).
Future<String?> _accessToken() async {
  const token = String.fromEnvironment('NEON_ACCESS_TOKEN');
  return token.isEmpty ? null : token;
}