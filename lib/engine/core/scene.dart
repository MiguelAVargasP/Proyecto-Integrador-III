/// Escena base del motor.
///
/// Una escena agrupa una fase concreta de la experiencia (mapa, escenario,
/// gestión del tiempo, decisiones, resultados...) y su ciclo de vida. El motor
/// solo requiere que una escena exponga [onLoad], [update] y [onExit]; las
/// subclases de la capa de juego definen el contenido.
///
/// Las escenas son agnósticas del contenido: trabajan con el [GameEngine] y su
/// [GameState] a través de la interfaz pública, nunca con identificadores de
/// contenido específico.
library;

import 'game_engine.dart';

abstract class GameScene {
  const GameScene({required this.id});

  /// Identificador (opaco, definido por la capa de juego) de esta escena.
  final String id;

  /// Se invoca al colocar la escena como activa.
  void onLoad(GameEngine engine) {}

  /// Actualiza la lógica de la escena cada paso/tiempo.
  void update(GameEngine engine, double delta) {}

  /// Se invoca al abandonar la escena hacia otra.
  void onExit(GameEngine engine) {}
}