/// Pruebas del [TimeManager] (mecánica base US-06).
///
/// Validan la representación del tiempo, la distribución válida e inválida,
/// los efectos sobre el estado y la validación del presupuesto.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/game_state.dart';
import 'package:juegoupb/engine/managers/effect.dart';
import 'package:juegoupb/engine/managers/time_manager.dart';

TimeActionDefinition _action(String id, double cost,
    {List<StatEffect> effects = const <StatEffect>[]}) {
  return TimeActionDefinition(
    id: id,
    displayName: id,
    category: TimeCategory.academic,
    cost: cost,
    effects: effects,
  );
}

void main() {
  group('TimeManager', () {
    test('representa el presupuesto y el tiempo restante', () {
      final manager = TimeManager(totalTime: 10.0);
      expect(manager.totalTime, 10.0);
      expect(manager.allocated, 0.0);
      expect(manager.remaining, 10.0);
      expect(manager.isExhausted, isFalse);
      expect(manager.actionCount, 0);
    });

    test('distribución válida aplica efectos y consume presupuesto', () {
      final manager = TimeManager(totalTime: 6.0);
      manager.registerAction(
        _action('estudio', 2.0,
            effects: const [StatEffect('preparation', 5.0)]),
      );
      final state = GameState();

      final result = manager.allocate(state, 'estudio', times: 2);
      expect(result.isOk, isTrue);
      expect(manager.allocated, 4.0);
      expect(manager.remaining, closeTo(2.0, 1e-9));
      expect(state.stat('preparation'), 10.0);
      expect(manager.usesOf('estudio'), 2);
    });

    test('distribución inválida por presupuesto no modifica nada', () {
      final manager = TimeManager(totalTime: 4.0);
      manager.registerAction(_action('clase', 3.0));
      final state = GameState();

      final result = manager.allocate(state, 'clase', times: 2);
      expect(result.status, TimeAllocationStatus.insufficientBudget);
      expect(manager.allocated, 0.0);
      expect(state.hasStats, isFalse);
    });

    test('actividad desconocida devuelve estado de error', () {
      final manager = TimeManager(totalTime: 10.0);
      final state = GameState();
      final result = manager.allocate(state, 'no_existe');
      expect(result.status, TimeAllocationStatus.unknownAction);
      expect(manager.allocated, 0.0);
    });

    test('canAllocate valida antes de asignar', () {
      final manager = TimeManager(totalTime: 5.0);
      manager.registerAction(_action('descanso', 1.0));

      expect(manager.canAllocate('descanso', times: 5), isTrue);
      expect(manager.canAllocate('descanso', times: 6), isFalse);
      expect(manager.canAllocate('no_existe'), isFalse);
      expect(manager.canAllocate('descanso', times: 0), isFalse);
    });

    test('clasifica actividades por categoría y suma por categoría', () {
      final manager = TimeManager(totalTime: 10.0);
      manager.registerActions([
        _action('estudio', 2.0),
        _action('clase', 3.0),
        const TimeActionDefinition(
          id: 'descanso',
          displayName: 'Descanso',
          category: TimeCategory.nonAcademic,
          cost: 1.0,
        ),
      ]);
      expect(manager.actionsByCategory(TimeCategory.academic).length, 2);
      expect(manager.actionsByCategory(TimeCategory.nonAcademic).length, 1);

      final state = GameState();
      manager.allocate(state, 'estudio');
      manager.allocate(state, 'clase');
      manager.allocate(state, 'descanso', times: 2);
      expect(manager.allocatedByCategory(TimeCategory.academic), 5.0);
      expect(manager.allocatedByCategory(TimeCategory.nonAcademic), 2.0);
    });

    test('reset restablece la distribución', () {
      final manager = TimeManager(totalTime: 5.0);
      manager.registerAction(_action('descanso', 1.0));
      final state = GameState();
      manager.allocate(state, 'descanso', times: 2);
      expect(manager.allocated, 2.0);

      manager.reset();
      expect(manager.allocated, 0.0);
      expect(manager.remaining, 5.0);
      expect(manager.usesOf('descanso'), 0);
    });

    test('el presupuesto agotado queda señalizado', () {
      final manager = TimeManager(totalTime: 4.0);
      manager.registerAction(_action('clase', 2.0));
      final state = GameState();
      manager.allocate(state, 'clase', times: 2);
      expect(manager.isExhausted, isTrue);
      expect(manager.allocate(state, 'clase').status,
          TimeAllocationStatus.insufficientBudget);
    });

    test('construye actividades desde mapas data-driven', () {
      final action = TimeActionDefinition.fromMap(<String, dynamic>{
        'id': 'clase',
        'displayName': 'Asistir a clase',
        'category': 'academic',
        'cost': 2,
        'effects': [
          {'stat': 'preparation', 'delta': 6},
        ],
      });
      expect(action.id, 'clase');
      expect(action.category, TimeCategory.academic);
      expect(action.cost, 2.0);
      expect(action.effects.single.statKey, 'preparation');
    });
  });
}