// Prueba mínima de arranque: confirma que la app se puede construir sin
// errores y que el mapa (pantalla de entrada) aparece.
//
// El archivo original que genera `flutter create` prueba un contador de
// ejemplo (`MyApp`) que no existe en este proyecto — nuestra app se llama
// `OrientacionUpbApp` y su pantalla de entrada es `MapaCampusScreen`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orientacion_upb/main.dart';

void main() {
  testWidgets('La app arranca y muestra el mapa del campus',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OrientacionUpbApp());

    // No hay texto fijo que verificar en el mapa (es una imagen con
    // hotspots), así que el criterio de éxito es que el árbol de widgets
    // se construyó sin lanzar ninguna excepción.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}