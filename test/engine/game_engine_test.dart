/// Pruebas del [GameEngine]: registro de escenas, ciclo de vida y avance.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/game_engine.dart';
import 'package:juegoupb/engine/core/game_state.dart';
import 'package:juegoupb/engine/core/scene.dart';

/// Escena de prueba que registra su ciclo de vida y acumula actualizaciones.
class _TrackingScene extends GameScene {
  _TrackingScene({required super.id});

  int loadCount = 0;
  int exitCount = 0;
  int updateCount = 0;
  double lastDelta = 0.0;
  bool onLoadSyncedSceneToState = false;

  @override
  void onLoad(GameEngine engine) {
    loadCount++;
    engine.state.stageId = 'etapa_$id';
  }

  @override
  void update(GameEngine engine, double delta) {
    updateCount++;
    lastDelta = delta;
  }

  @override
  void onExit(GameEngine engine) {
    exitCount++;
  }
}

void main() {
  group('GameEngine', () {
    test('empieza sin escena activa y con estado vacío', () {
      final engine = GameEngine();
      expect(engine.current, isNull);
      expect(engine.state.stageId, isEmpty);
      expect(engine.isRunning, isFalse);
    });

    test('registra y reconoce escenas', () {
      final engine = GameEngine();
      engine.registerScene(_TrackingScene(id: 'mapa'));
      expect(engine.knowsScene('mapa'), isTrue);
      expect(engine.knowsScene('cafeteria'), isFalse);
    });

    test('changeScene invoca onLoad y fija sceneId en el estado', () {
      final engine = GameEngine();
      final mapa = _TrackingScene(id: 'mapa');
      final cafeteria = _TrackingScene(id: 'cafeteria');
      engine.registerScenes([mapa, cafeteria]);

      expect(engine.changeScene('mapa'), isTrue);
      expect(mapa.loadCount, 1);
      expect(engine.current, mapa);
      expect(engine.state.sceneId, 'mapa');

      expect(engine.changeScene('cafeteria'), isTrue);
      expect(mapa.exitCount, 1);
      expect(cafeteria.loadCount, 1);
      expect(engine.state.sceneId, 'cafeteria');
    });

    test('changeScene a un id desconocido devuelve false y no cambia', () {
      final engine = GameEngine();
      engine.registerScene(_TrackingScene(id: 'mapa'));
      expect(engine.changeScene('no_existe'), isFalse);
      expect(engine.current, isNull);
    });

    test('advance propaga la delta a la escena activa', () {
      final engine = GameEngine();
      final escena = _TrackingScene(id: 'mapa');
      engine.registerScene(escena);
      engine.changeScene('mapa');

      engine.advance(0.02);
      engine.advance(0.03);
      expect(escena.updateCount, 2);
      expect(escena.lastDelta, closeTo(0.03, 1e-12));
    });

    test('advance sin escena activa no lanza', () {
      final engine = GameEngine();
      engine.advance(0.016); // no debe fallar
      expect(engine.current, isNull);
    });

    test('resetState reemplaza el estado', () {
      final engine = GameEngine();
      engine.state.stageId = 'parcial';
      engine.resetState();
      expect(engine.state.stageId, isEmpty);
      final custom = GameState()..stageId = 'primera_clases';
      engine.resetState(custom);
      expect(engine.state.stageId, 'primera_clases');
    });

    test('unregisterScene elimina la escena del catálogo', () {
      final engine = GameEngine();
      engine.registerScene(_TrackingScene(id: 'mapa'));
      engine.unregisterScene('mapa');
      expect(engine.knowsScene('mapa'), isFalse);
    });

    test('ticker continuo avanza y puede detenerse', () async {
      final engine = GameEngine();
      final escena = _TrackingScene(id: 'mapa');
      engine.registerScene(escena);
      engine.changeScene('mapa');

      engine.startTicker(const Duration(milliseconds: 4));
      expect(engine.isRunning, isTrue);
      // Esperamos unos milisegundos reales para que el timer dispare.
      await Future<void>.delayed(const Duration(milliseconds: 40));
      engine.stopTicker();
      expect(engine.isRunning, isFalse);
      expect(escena.updateCount, greaterThan(0));
    });
  });
}