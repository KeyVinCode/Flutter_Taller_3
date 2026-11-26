import 'package:get_it/get_it.dart';

// Instancia global del service locator
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. DataSources (los entrega el Rol 2)
  // sl.registerLazySingleton<PlannerLocalDataSource>(
  //   () => PlannerLocalDataSourceImpl(),
  // );

  // 2. Repositories (los entrega el Rol 2)
  // sl.registerLazySingleton<PlannerRepository>(
  //   () => PlannerRepositoryImpl(sl()),
  // );

  // 3. UseCases
  // sl.registerLazySingleton(() => GetPlannerItems(sl()));
}
