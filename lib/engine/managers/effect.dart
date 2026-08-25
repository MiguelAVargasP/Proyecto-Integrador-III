/// Efecto genérico sobre una estadística del [GameState].
///
/// Un [StatEffect] describe cómo una acción (decisión, distribución de tiempo,
/// consecuencia) modifica una estadística concreta del jugador. Es la unidad
/// básica que [TimeManager] y, en fases futuras, [DecisionManager] y
/// [ConsequenceManager] aplican al estado.
///
/// Es agnóstico de contenido: solo trabaja con una clave de estadística y un
/// delta, ambos definidos por la capa de juego.
library;

import '../core/game_state.dart';

class StatEffect {
  const StatEffect(
    this.statKey,
    this.delta, {
    this.min = 0.0,
    this.max = 100.0,
  });

  /// Clave de la estadística que se modifica (ej. 'stress', 'preparation').
  final String statKey;

  /// Variación aplicada a la estadística.
  final double delta;

  /// Límite inferior del resultado (acotado en el estado).
  final double min;

  /// Límite superior del resultado (acotado en el estado).
  final double max;

  /// Aplica el efecto al [state].
  void applyTo(GameState state) {
    state.modifyStat(statKey, delta, min: min, max: max);
  }

  /// Construye un efecto desde un mapa data-driven.
  factory StatEffect.fromMap(Map<String, dynamic> map) {
    return StatEffect(
      map['stat'] as String,
      (map['delta'] as num).toDouble(),
      min: (map['min'] as num?)?.toDouble() ?? 0.0,
      max: (map['max'] as num?)?.toDouble() ?? 100.0,
    );
  }
}