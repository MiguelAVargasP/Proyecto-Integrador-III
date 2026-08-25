/// TimeManager: gestión del tiempo del jugador (mecánica base US-06).
///
/// El jugador dispone de un presupuesto finito de tiempo (`totalTime`) que debe
/// distribuir entre actividades académicas y no académicas. Cada actividad
/// (data-driven) consume un costo de tiempo y aplica [StatEffect]s al
/// [GameState].
///
/// Responsabilidades:
/// - Representación interna del tiempo asignado/restante.
/// - Validación de la distribución (no se puede gastar más de lo disponible).
/// - Aplicación de los efectos de cada actividad al estado del jugador.
///
/// El manager es agnóstico de contenido: las actividades se registran con
/// [TimeActionDefinition]s cuyos identificadores, costos y efectos define la
/// capa de juego.
library;

import '../core/game_state.dart';
import 'effect.dart';

/// Categoría de una actividad de tiempo.
enum TimeCategory {
  /// Actividades académicas (clases, estudio, repaso).
  academic,

  /// Actividades no académicas (descanso, socialización, ejercicio).
  nonAcademic,
}

/// Definición data-driven de una actividad de tiempo.
class TimeActionDefinition {
  const TimeActionDefinition({
    required this.id,
    required this.displayName,
    required this.category,
    required this.cost,
    this.effects = const <StatEffect>[],
  }) : assert(cost > 0, 'El costo de una actividad debe ser positivo');

  /// Identificador opaco de la actividad.
  final String id;

  /// Nombre mostrable.
  final String displayName;

  /// Categoría académica o no académica.
  final TimeCategory category;

  /// Unidades de tiempo que consume cada uso.
  final double cost;

  /// Efectos sobre las estadísticas al usar la actividad.
  final List<StatEffect> effects;

  factory TimeActionDefinition.fromMap(Map<String, dynamic> map) {
    final rawCategory = map['category'] as String? ?? 'nonAcademic';
    final category = rawCategory == 'academic'
        ? TimeCategory.academic
        : TimeCategory.nonAcademic;
    final effects = (map['effects'] as List? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map(StatEffect.fromMap)
        .toList();
    return TimeActionDefinition(
      id: map['id'] as String,
      displayName: map['displayName'] as String? ?? map['id'] as String,
      category: category,
      cost: (map['cost'] as num? ?? 1).toDouble(),
      effects: effects,
    );
  }
}

/// Resultado de una asignación de tiempo.
class TimeAllocationResult {
  const TimeAllocationResult(this.status, {this.actionId, this.cost});

  /// Estado de la asignación.
  final TimeAllocationStatus status;

  /// Identificador de la actividad implicada (si aplica).
  final String? actionId;

  /// Coste total intentado (si aplica).
  final double? cost;

  bool get isOk => status == TimeAllocationStatus.ok;
}

/// Estados posibles al intentar asignar tiempo a una actividad.
enum TimeAllocationStatus {
  /// La asignación se realizó y los efectos se aplicaron.
  ok,

  /// La actividad no está registrada en el manager.
  unknownAction,

  /// No queda presupuesto suficiente para cubrir el costo de la actividad.
  insufficientBudget,
}

/// Mecánica base de distribución del tiempo.
class TimeManager {
  TimeManager({
    required this.totalTime,
    Iterable<TimeActionDefinition> actions = const <TimeActionDefinition>[],
  }) : _actions = <String, TimeActionDefinition>{
          for (final action in actions) action.id: action,
        };

  /// Presupuesto total de tiempo disponible.
  final double totalTime;

  static const double _epsilon = 1e-9;

  final Map<String, TimeActionDefinition> _actions;
  double _allocated = 0.0;
  final Map<String, int> _usageCount = <String, int>{};

  // -------------------------------------------------------------- actividades

  /// Registra una actividad por su identificador.
  void registerAction(TimeActionDefinition action) {
    _actions[action.id] = action;
  }

  /// Registra varias actividades a la vez.
  void registerActions(Iterable<TimeActionDefinition> actions) {
    for (final action in actions) {
      registerAction(action);
    }
  }

  /// Devuelve la actividad registrada bajo [id] (null si no existe).
  TimeActionDefinition? getAction(String id) => _actions[id];

  /// Indica si la actividad [id] existe.
  bool knowsAction(String id) => _actions.containsKey(id);

  /// Número de actividades registradas.
  int get actionCount => _actions.length;

  /// Todas las actividades registradas.
  Iterable<TimeActionDefinition> get actions => _actions.values;

  /// Actividades de una categoría.
  List<TimeActionDefinition> actionsByCategory(TimeCategory category) =>
      _actions.values.where((a) => a.category == category).toList();

  // ------------------------------------------------------------------ tiempo

  /// Tiempo ya asignado a actividades.
  double get allocated => _allocated;

  /// Tiempo restante disponible (nunca negativo).
  double get remaining =>
      (totalTime - _allocated).clamp(0.0, double.infinity).toDouble();

  /// Indica si el presupuesto está agotado.
  bool get isExhausted => remaining <= _epsilon;

  /// Número de usos realizados de una actividad.
  int usesOf(String actionId) => _usageCount[actionId] ?? 0;

  /// Tiempo asignado a una categoría concreta.
  double allocatedByCategory(TimeCategory category) {
    var total = 0.0;
    _usageCount.forEach((actionId, uses) {
      final action = _actions[actionId];
      if (action != null && action.category == category) {
        total += action.cost * uses;
      }
    });
    return total;
  }

  // --------------------------------------------------------------- validación

  /// Indica si la actividad [actionId] puede usarse [times] veces sin exceder
  /// el presupuesto.
  bool canAllocate(String actionId, {int times = 1}) {
    final action = _actions[actionId];
    if (action == null || times <= 0) return false;
    return _allocated + action.cost * times <= totalTime + _epsilon;
  }

  // ------------------------------------------------------------------ asignar

  /// Asigna [times] usos de [actionId] y aplica sus efectos al [state].
  ///
  /// Devuelve un [TimeAllocationResult]. En caso de error no se modifica ni el
  /// presupuesto ni el estado.
  TimeAllocationResult allocate(GameState state, String actionId,
      {int times = 1}) {
    if (times <= 0) {
      return TimeAllocationResult(TimeAllocationStatus.ok,
          actionId: actionId, cost: 0.0);
    }
    final action = _actions[actionId];
    if (action == null) {
      return TimeAllocationResult(TimeAllocationStatus.unknownAction,
          actionId: actionId);
    }
    final totalCost = action.cost * times;
    if (_allocated + totalCost > totalTime + _epsilon) {
      return TimeAllocationResult(TimeAllocationStatus.insufficientBudget,
          actionId: actionId, cost: totalCost);
    }

    // Aplicar los efectos por cada uso de la actividad.
    for (var i = 0; i < times; i++) {
      for (final effect in action.effects) {
        effect.applyTo(state);
      }
    }

    _allocated += totalCost;
    _usageCount[actionId] = (_usageCount[actionId] ?? 0) + times;
    return TimeAllocationResult(TimeAllocationStatus.ok,
        actionId: actionId, cost: totalCost);
  }

  // ------------------------------------------------------------------ reinicio

  /// Restablece la distribución (asignación y conteos) a cero.
  void reset() {
    _allocated = 0.0;
    _usageCount.clear();
  }
}
