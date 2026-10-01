import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orientacion_upb/core/estado_juego.dart';
import 'package:orientacion_upb/features/dialogo/modelo/dialogo_linea.dart';
import 'package:orientacion_upb/features/dialogo/widgets/caja_dialogo.dart';

void main() {
  setUp(() {
    estadoJuego.resetear();
    estadoJuego.onInsigniaOtorgada = null;
  });

  group('US-10: Mapeo de nombres de insignias', () {
    test('nombreInsignia retorna nombres descriptivos para cada hito', () {
      expect(EstadoJuego.nombreInsignia('FASE_2'), equals('Primeras Clases'));
      expect(EstadoJuego.nombreInsignia('FASE_3'), equals('Estudio Independiente'));
      expect(EstadoJuego.nombreInsignia('D'), equals('Superviviente del Parcial'));
      expect(EstadoJuego.nombreInsignia('OTRA_INSIGNIA'), equals('OTRA_INSIGNIA'));
    });
  });

  group('US-10: Notificación visual al otorgar insignia con BuildContext', () {
    testWidgets('Muestra SnackBar al otorgar insignia por primera vez', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  estadoJuego.otorgarInsignia('FASE_2', context);
                },
                child: const Text('Ganar insignia'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Ganar insignia'));
      await tester.pumpAndSettle();

      expect(estadoJuego.insigniasObtenidas, contains('FASE_2'));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('¡Nueva insignia obtenida: Primeras Clases!'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('No dispara notificación repetida para una insignia ya obtenida', (tester) async {
      estadoJuego.insigniasObtenidas.add('FASE_2');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  estadoJuego.otorgarInsignia('FASE_2', context);
                },
                child: const Text('Ganar insignia de nuevo'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Ganar insignia de nuevo'));
      await tester.pumpAndSettle();

      // No debe presentarse SnackBar porque ya se poseía
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('US-10: Notificación desacoplada vía callback (para escenas como el parcial simulado)', () {
    test('onInsigniaOtorgada se ejecuta cuando no se provee BuildContext', () {
      String? idNotificado;
      String? nombreNotificado;

      estadoJuego.onInsigniaOtorgada = (id, nombre) {
        idNotificado = id;
        nombreNotificado = nombre;
      };

      estadoJuego.otorgarInsignia('D');

      expect(idNotificado, equals('D'));
      expect(nombreNotificado, equals('Superviviente del Parcial'));
    });
  });

  group('US-10: Integración en CajaDialogo al seleccionar opción con insignia', () {
    testWidgets('Muestra SnackBar al elegir opción que otorga insignia', (tester) async {
      final lineas = [
        const DialogoLinea(
          'Elige un camino',
          opciones: [
            OpcionDialogo(
              'Aceptar desafío',
              insignia: 'DESAFIO_ACEPTADO',
              saltarA: 1,
            ),
          ],
        ),
        const DialogoLinea('Continuación', esFinal: true),
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CajaDialogo(
            lineas: lineas,
            onFinalizado: () {},
          ),
        ),
      ));

      await tester.tap(find.text('Aceptar desafío'));
      await tester.pumpAndSettle();

      expect(estadoJuego.insigniasObtenidas, contains('DESAFIO_ACEPTADO'));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('¡Nueva insignia obtenida: DESAFIO_ACEPTADO!'), findsOneWidget);
    });
  });
}
