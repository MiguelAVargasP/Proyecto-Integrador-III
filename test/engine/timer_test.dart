/// Pruebas unitarias del [GameTimer] del motor.
///
/// Validan comportamiento (estado inicial, cuenta atrás, fin único, reinicio
/// y límites), no cobertura artificial.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/timer.dart';

void main() {
  group('GameTimer', () {
    test('un timer nuevo inicia inactivo', () {
      final timer = GameTimer(duration: 1.0);
      expect(timer.running, isFalse);
      expect(timer.finished, isFalse);
      expect(timer.remaining, 1.0);
      expect(timer.elapsed, 0.0);
    });

    test('empieza y cuenta hacia atrás', () {
      final timer = GameTimer(duration: 1.0);
      timer.start();
      expect(timer.running, isTrue);
      expect(timer.remaining, 1.0);

      final finished = timer.update(0.4);
      expect(finished, isFalse);
      expect(timer.remaining, closeTo(0.6, 1e-9));
      expect(timer.progress, lessThan(1.0));
    });

    test('update devuelve true una sola vez al terminar', () {
      final timer = GameTimer(duration: 0.5);
      timer.start();
      expect(timer.update(0.3), isFalse);
      expect(timer.update(0.2), isTrue); // cruza a cero en este paso
      expect(timer.finished, isTrue);
      expect(timer.running, isFalse);
      // Las llamadas posteriores no se disparan de nuevo.
      expect(timer.update(0.1), isFalse);
      expect(timer.remaining, 0.0);
    });

    test('reiniciar resetea elapsed y finished', () {
      final timer = GameTimer(duration: 1.0);
      timer.start();
      timer.update(0.8);
      timer.start();
      expect(timer.remaining, 1.0);
      expect(timer.finished, isFalse);
    });

    test('progress queda acotado entre 0 y 1', () {
      final timer = GameTimer(duration: 2.0);
      timer.start();
      timer.update(1.0);
      expect(timer.progress, closeTo(0.5, 1e-9));
      timer.update(5.0);
      expect(timer.progress, 1.0);
    });

    test('stop detiene la cuenta', () {
      final timer = GameTimer(duration: 1.0);
      timer.start();
      timer.update(0.3);
      timer.stop();
      expect(timer.running, isFalse);
      expect(timer.update(1.0), isFalse);
    });

    test('deltas negativos no retroceden la cuenta', () {
      final timer = GameTimer(duration: 1.0);
      timer.start();
      timer.update(-2.0);
      expect(timer.elapsed, 0.0);
      expect(timer.running, isTrue);
    });
  });
}