/// Pruebas del [GameState] del motor: estadísticas, registros y serialización.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/game_state.dart';

void main() {
  group('GameState', () {
    test('estado por defecto es agnóstico y vacío', () {
      final state = GameState();
      expect(state.stageId, isEmpty);
      expect(state.sceneId, isEmpty);
      expect(state.stats, isEmpty);
      expect(state.progressIndex, 0);
      expect(state.hasStats, isFalse);
      expect(state.isFinished, isFalse);
    });

    test('setStat acota el valor entre min y max', () {
      final state = GameState();
      final above = state.setStat('stress', 150.0);
      final below = state.setStat('preparation', -10.0);
      expect(above, 100.0);
      expect(below, 0.0);
    });

    test('modifyStat acumula y conserva el límite', () {
      final state = GameState();
      state.modifyStat('performance', 30.0);
      state.modifyStat('performance', 40.0);
      expect(state.stat('performance'), 70.0);
      state.modifyStat('performance', 50.0); // excede el máximo
      expect(state.stat('performance'), 100.0);
      expect(state.stat('inexistente', fallback: 5.0), 5.0);
    });

    test('registro de escenas visitadas no duplica', () {
      final state = GameState();
      state.recordVisitedScene('cafeteria');
      state.recordVisitedScene('cafeteria');
      state.recordVisitedScene('biblioteca');
      expect(state.visitedScenes, ['cafeteria', 'biblioteca']);
    });

    test('el historial de decisiones conserva el orden', () {
      final state = GameState();
      state.recordDecision('ir_a_clase');
      state.recordDecision('estudiar_en_biblioteca');
      expect(state.decisionLog, ['ir_a_clase', 'estudiar_en_biblioteca']);
    });

    test('las insignias no se duplican', () {
      final state = GameState();
      state.awardBadge('primera_etapa');
      state.awardBadge('primera_etapa');
      expect(state.badges, ['primera_etapa']);
    });

    test('toJson/fromJson preserva el estado completo', () {
      final state = GameState();
      state.stageId = 'primeras_clases';
      state.sceneId = 'mapa';
      state.progressIndex = 2;
      state.setStat('stress', 40.0);
      state.setStat('preparation', 65.0);
      state.strings['nombre'] = 'Estudiante';
      state.recordVisitedScene('biblioteca');
      state.recordDecision('ayudar_companero');
      state.awardBadge('hito_1');
      state.isFinished = true;

      final restored = GameState.fromJson(state.toJson());
      expect(restored.stageId, 'primeras_clases');
      expect(restored.sceneId, 'mapa');
      expect(restored.progressIndex, 2);
      expect(restored.stat('stress'), 40.0);
      expect(restored.stat('preparation'), 65.0);
      expect(restored.strings['nombre'], 'Estudiante');
      expect(restored.visitedScenes, ['biblioteca']);
      expect(restored.decisionLog, ['ayudar_companero']);
      expect(restored.badges, ['hito_1']);
      expect(restored.isFinished, isTrue);
    });

    test('encode/decode (string JSON) es de ida y vuelta', () {
      final state = GameState();
      state.stats['stress'] = 55.0;
      final restored = GameState.decode(state.encode());
      expect(restored.stat('stress'), 55.0);
      expect(restored.schemaVersion, kGameStateSchemaVersion);
    });
  });
}