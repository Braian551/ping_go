// Esta es una prueba básica de widget de Flutter.
//
// Para realizar una interacción con un widget en tu prueba, usa la utilidad WidgetTester
// en el paquete flutter_test. Por ejemplo, puedes enviar gestos de toque y desplazamiento.
// También puedes usar WidgetTester para encontrar widgets hijos en el árbol de widgets,
// leer texto y verificar que los valores de las propiedades de los widgets sean correctos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ping_go/main.dart';

void main() {
  testWidgets('App smoke test builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(enableDatabaseInit: false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
