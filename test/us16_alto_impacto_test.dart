import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientacion_upb/core/estado_juego.dart';
import 'package:orientacion_upb/features/decisiones/decisiones_screen.dart';
import 'package:orientacion_upb/features/dialogo/modelo/dialogo_linea.dart';
import 'package:orientacion_upb/features/dialogo/widgets/caja_dialogo.dart';

void main() {
  setUp(() {
    estadoJuego.resetear();
  });

  group('US-16: Detección y fuente única de alto impacto', () {
    test('esDecisionAltoImpacto detecta palabras clave correctas', () {
      expect(estadoJuego.esDecisionAltoImpacto('Decidió copiar en el examen'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Incurrió en plagio académico'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Optó por faltar a clase'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Decidió rendirse'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Eligió no estudiar para el parcial'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Decidió estudiar menos este fin de semana'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Quiso delegar toda la responsabilidad'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Prefirió entregar tarde'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Buscó impunidad'), isTrue);
      expect(estadoJuego.esDecisionAltoImpacto('Intentó evadir sus deberes'), isTrue);

      // Decisiones habituales no deben ser marcadas como alto impacto
      expect(estadoJuego.esDecisionAltoImpacto('Estudió en la biblioteca'), isFalse);
      expect(estadoJuego.esDecisionAltoImpacto('Repasó con sus compañeros'), isFalse);
    });

    testWidgets('DecisionesScreen resalta decisiones de alto impacto usando EstadoJuego', (tester) async {
      final decisiones = [
        'Organizó su tiempo de estudio',
        'Cometió plagio en la entrega',
      ];

      await tester.pumpWidget(MaterialApp(
        home: DecisionesScreen(
          decisionesTomadas: decisiones,
          onVolver: () {},
        ),
      ));

      expect(find.text('Organizó su tiempo de estudio'), findsOneWidget);
      expect(find.text('Cometió plagio en la entrega'), findsOneWidget);

      // Solo la de plagio debe tener la etiqueta de alto impacto
      expect(find.text('Decisión de alto impacto'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  group('US-16: Advertencia previa en CajaDialogo antes de confirmar', () {
    testWidgets('Opción regular se aplica inmediatamente sin diálogo', (tester) async {
      final lineas = [
        const DialogoLinea(
          '¿Qué deseas hacer?',
          opciones: [
            OpcionDialogo(
              'Estudiar en biblioteca',
              deltaEstres: -5,
              decisionRegistrada: 'Estudió en biblioteca',
              saltarA: 1,
            ),
          ],
        ),
        const DialogoLinea('Excelente elección.', esFinal: true),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CajaDialogo(
            lineas: lineas,
            onFinalizado: () {},
          ),
        ),
      ));

      expect(find.text('Estudiar en biblioteca'), findsOneWidget);
      await tester.tap(find.text('Estudiar en biblioteca'));
      await tester.pumpAndSettle();

      // No debe haber AlertDialog
      expect(find.byType(AlertDialog), findsNothing);
      expect(estadoJuego.nivelEstres, equals(0)); // 0 - 5 clamped to 0
      expect(estadoJuego.decisionesTomadas, contains('Estudió en biblioteca'));
      expect(find.text('Excelente elección.'), findsOneWidget);
    });

    testWidgets('Opción de alto impacto muestra advertencia y al cancelar no aplica cambios', (tester) async {
      final lineas = [
        const DialogoLinea(
          'Tienes una entrega pendiente.',
          opciones: [
            OpcionDialogo(
              'Copiar el trabajo de otro',
              deltaEstres: 15,
              decisionRegistrada: 'Decidió copiar el trabajo',
              saltarA: 1,
            ),
          ],
        ),
        const DialogoLinea('Llegaste al final.', esFinal: true),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CajaDialogo(
            lineas: lineas,
            onFinalizado: () {},
          ),
        ),
      ));

      await tester.tap(find.text('Copiar el trabajo de otro'));
      await tester.pumpAndSettle();

      // Debe aparecer el diálogo de advertencia
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Decisión de alto impacto'), findsOneWidget);

      // Aún NO se han aplicado cambios
      expect(estadoJuego.nivelEstres, equals(0));
      expect(estadoJuego.decisionesTomadas, isEmpty);

      // Cancelar
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Diálogo cerrado y el estado permanece intacto
      expect(find.byType(AlertDialog), findsNothing);
      expect(estadoJuego.nivelEstres, equals(0));
      expect(estadoJuego.decisionesTomadas, isEmpty);
      // El diálogo sigue en la pregunta inicial
      expect(find.text('Copiar el trabajo de otro'), findsOneWidget);
    });

    testWidgets('Opción de alto impacto aplica cambios al confirmar', (tester) async {
      final lineas = [
        const DialogoLinea(
          'Tienes una entrega pendiente.',
          opciones: [
            OpcionDialogo(
              'Copiar el trabajo de otro',
              deltaEstres: 15,
              decisionRegistrada: 'Decidió copiar el trabajo',
              saltarA: 1,
            ),
          ],
        ),
        const DialogoLinea('Llegaste al final.', esFinal: true),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CajaDialogo(
            lineas: lineas,
            idEscena: 'A',
            onFinalizado: () {},
          ),
        ),
      ));

      await tester.tap(find.text('Copiar el trabajo de otro'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      // Continuar
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      // Cambios aplicados
      expect(find.byType(AlertDialog), findsNothing);
      expect(estadoJuego.nivelEstres, equals(15));
      expect(estadoJuego.decisionesTomadas, contains('[A] Decidió copiar el trabajo'));
      expect(find.text('Llegaste al final.'), findsOneWidget);
    });
  });
}
