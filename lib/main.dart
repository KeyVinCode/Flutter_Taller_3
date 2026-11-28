import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/planner/presentation/pages/planner_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const PlannerApp());
}

/// Aplicación base del Gestor de Agenda.
///
/// Punto de entrada del proyecto: aquí solo se configura el tema, el idioma y
/// la pantalla inicial. La lógica de negocio vive en `features/planner`
/// (Clean Architecture).
class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key, this.home});

  /// Permite inyectar la pantalla inicial en pruebas.
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Agenda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('es', 'CO'),
      supportedLocales: const <Locale>[Locale('es', 'CO'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home ?? const PlannerHomePage(),
    );
  }
}
