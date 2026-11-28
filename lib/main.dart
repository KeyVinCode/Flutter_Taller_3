import 'package:flutter/material.dart';

import 'core/di/injection_container.dart';
import 'features/planner/presentation/pages/planner_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const PlannerApp());
}

/// Aplicación base del Gestor de Agenda.
///
/// Punto de entrada del proyecto: aquí solo se configura el tema y la pantalla
/// inicial. La lógica de negocio vive en `features/planner` (Clean Architecture).
class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB)),
        useMaterial3: true,
      ),
      home: const PlannerHomePage(),
    );
  }
}