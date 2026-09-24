import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orientacion_upb/main.dart';
import 'package:orientacion_upb/features/menu_principal/menu_principal_screen.dart';
import 'package:orientacion_upb/features/mapa_navegacion/screens/mapa_campus_screen.dart';

void main() {
  testWidgets('OrientacionUpbApp arranca sin excepciones', (tester) async {
    await tester.pumpWidget(const OrientacionUpbApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('MenuPrincipalScreen muestra el menu correctamente', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MenuPrincipalScreen(
        onVolverAlMapa: () {},
      ),
    ));
    expect(find.text('Orientacion UPB'), findsOneWidget);
    expect(find.text('Ver mi progreso'), findsOneWidget);
    expect(find.text('Ver resultados'), findsOneWidget);
    expect(find.text('Ver mis decisiones'), findsOneWidget);
    expect(find.text('Reiniciar recorrido'), findsOneWidget);
    expect(find.text('Gestion del tiempo'), findsOneWidget);
  });

  testWidgets('MapaCampusScreen se construye sin excepciones', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MapaCampusScreen(),
    ));
    expect(find.byType(MapaCampusScreen), findsOneWidget);
  });
}
