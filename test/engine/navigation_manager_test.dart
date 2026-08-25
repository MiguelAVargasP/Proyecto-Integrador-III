/// Pruebas del [NavigationManager]: ir a, mapa, historial y volver atrás.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/game_engine.dart';
import 'package:juegoupb/engine/core/navigation_manager.dart';
import 'package:juegoupb/engine/core/scene.dart';

class _Scene extends GameScene {
  _Scene({required super.id});
}

void main() {
  group('NavigationManager', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine();
      engine.registerScenes([
        _Scene(id: 'map'),
        _Scene(id: 'cafeteria'),
        _Scene(id: 'biblioteca'),
      ]);
    });

    test('goTo navega y registra la escena visitada en el estado', () {
      expect(engine.navigateTo('cafeteria'), isTrue);
      expect(engine.current?.id, 'cafeteria');
      expect(engine.state.sceneId, 'cafeteria');
      expect(engine.state.visitedScenes, ['cafeteria']);
      expect(engine.navigation.history, ['cafeteria']);
    });

    test('goTo a un id desconocido devuelve false y no registra nada', () {
      expect(engine.navigateTo('nope'), isFalse);
      expect(engine.current, isNull);
      expect(engine.state.visitedScenes, isEmpty);
      expect(engine.navigation.history, isEmpty);
    });

    test('goToMap navega al id de mapa configurado', () {
      expect(engine.navigateToMap(), isTrue);
      expect(engine.current?.id, 'map');
    });

    test('el historial conserva el orden de navegación', () {
      engine.navigateTo('cafeteria');
      engine.navigateTo('biblioteca');
      engine.navigateToMap();
      expect(engine.navigation.history, ['cafeteria', 'biblioteca', 'map']);
    });

    test('back vuelve a la escena anterior', () {
      engine.navigateTo('cafeteria');
      engine.navigateTo('biblioteca');
      expect(engine.navigateBack(), isTrue);
      expect(engine.current?.id, 'cafeteria');
      expect(engine.navigation.history, ['cafeteria']);
    });

    test('back sin suficiente historial devuelve false', () {
      engine.navigateTo('cafeteria');
      expect(engine.navigateBack(), isFalse);
      expect(engine.current?.id, 'cafeteria');
    });

    test('reset limpia el historial', () {
      engine.navigateTo('cafeteria');
      engine.navigation.reset();
      expect(engine.navigation.history, isEmpty);
    });
  });
}