// Prueba de humo de la aplicación base.
//
// Verifica que la app se construya sin errores y que muestre la pantalla
// inicial del Gestor de Agenda.

import 'package:flutter_test/flutter_test.dart';

import 'package:actividad_8flutter/main.dart';

void main() {
  testWidgets('la app se construye y muestra la pantalla inicial', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PlannerApp());

    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Gestor de Agenda'), findsOneWidget);
  });
}
