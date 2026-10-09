import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientacion_upb/core/estado_juego.dart';
import 'package:orientacion_upb/features/resultados/resultados_screen.dart';

void main() {
  setUp(() {
    estadoJuego.resetear();
  });

  group('US-15: Fórmula de calcularResultadoFinal en EstadoJuego', () {
    test('Retorna "Bien preparado" cuando nivelEstres < 30', () {
      estadoJuego.nivelEstres = 0;
      expect(estadoJuego.calcularResultadoFinal(), equals('Bien preparado'));

      estadoJuego.nivelEstres = 29;
      expect(estadoJuego.calcularResultadoFinal(), equals('Bien preparado'));
    });

    test('Retorna "Preparación irregular" cuando 30 <= nivelEstres < 70', () {
      estadoJuego.nivelEstres = 30;
      expect(estadoJuego.calcularResultadoFinal(), equals('Preparación irregular'));

      estadoJuego.nivelEstres = 50;
      expect(estadoJuego.calcularResultadoFinal(), equals('Preparación irregular'));

      estadoJuego.nivelEstres = 69;
      expect(estadoJuego.calcularResultadoFinal(), equals('Preparación irregular'));
    });

    test('Retorna "Poco preparado" cuando nivelEstres >= 70', () {
      estadoJuego.nivelEstres = 70;
      expect(estadoJuego.calcularResultadoFinal(), equals('Poco preparado'));

      estadoJuego.nivelEstres = 100;
      expect(estadoJuego.calcularResultadoFinal(), equals('Poco preparado'));
    });
  });

  group('US-15: ResultadosScreen visualiza resultado de EstadoJuego', () {
    testWidgets('Muestra resultado delegado de estadoJuego y estadísticas', (tester) async {
      estadoJuego.nivelEstres = 25;
      estadoJuego.etapasCompletadas = 3;

      await tester.pumpWidget(MaterialApp(
        home: ResultadosScreen(
          nivelEstres: estadoJuego.nivelEstres,
          etapasCompletadas: estadoJuego.etapasCompletadas,
          totalEtapas: EstadoJuego.totalEtapas,
          decisionesTomadas: const ['Decisión 1', 'Decisión 2'],
          insigniasObtenidas: const {'FASE_2', 'FASE_3'},
          tiempoAsignadoPorActividad: const {'Estudio independiente': 4},
          onReiniciar: () {},
          onVolverAlMenu: () {},
        ),
      ));

      // Debe mostrar el título y el resultado calculado por EstadoJuego
      expect(find.text('Resultados de tu recorrido'), findsOneWidget);
      expect(find.text('Bien preparado'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('25 / 100'), findsOneWidget);
      expect(find.text('Decisión 1'), findsOneWidget);
      expect(find.text('Volver al mapa'), findsOneWidget);
      expect(find.text('Reiniciar recorrido'), findsOneWidget);
    });

    testWidgets('Muestra "Poco preparado" cuando el estrés es alto', (tester) async {
      estadoJuego.nivelEstres = 85;

      await tester.pumpWidget(MaterialApp(
        home: ResultadosScreen(
          nivelEstres: estadoJuego.nivelEstres,
          etapasCompletadas: 1,
          totalEtapas: EstadoJuego.totalEtapas,
          decisionesTomadas: const [],
          insigniasObtenidas: const {},
          tiempoAsignadoPorActividad: const {},
          onReiniciar: () {},
          onVolverAlMenu: () {},
        ),
      ));

      expect(find.text('Poco preparado'), findsOneWidget);
    });
  });
}
