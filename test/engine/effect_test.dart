/// Pruebas del [StatEffect]: aplicación al estado y construcción desde datos.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/game_state.dart';
import 'package:juegoupb/engine/managers/effect.dart';

void main() {
  group('StatEffect', () {
    test('aplica un delta a la estadística indicada', () {
      final state = GameState()..setStat('stress', 40.0);
      const effect = StatEffect('stress', 10.0);
      effect.applyTo(state);
      expect(state.stat('stress'), 50.0);
    });

    test('respeta los límites configurados', () {
      final state = GameState();
      const effect = StatEffect('stress', -200.0, min: 0.0, max: 100.0);
      effect.applyTo(state);
      expect(state.stat('stress'), 0.0);
    });

    test('se construye desde un mapa data-driven', () {
      final effect = StatEffect.fromMap(<String, dynamic>{
        'stat': 'preparation',
        'delta': 5,
        'min': 0,
        'max': 100,
      });
      expect(effect.statKey, 'preparation');
      expect(effect.delta, 5.0);
      expect(effect.max, 100.0);
    });
  });
}