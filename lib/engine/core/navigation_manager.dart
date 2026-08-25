/// NavigationManager: flujo de navegación entre escenas.
///
/// Responsabilidades:
/// - [goTo]: navegar a una escena y registrar la visita en el [GameState].
/// - [goToMap]: volver al mapa (el id del mapa es configuración).
/// - [back]: volver a la escena anterior del recorrido.
///
/// El manager no conoce contenido: el id del mapa se inyecta en la
/// construcción (por defecto `'map'`, convención definida por la capa de
/// juego). El historial apoya la mecánica "volver al mapa" (US-03) y el
/// registro de escenas visitadas (US-04).
library;

import 'game_engine.dart';

class NavigationManager {
  NavigationManager({this.mapSceneId = 'map'});

  /// Identificador de la escena de mapa (configuración, no contenido).
  final String mapSceneId;

  final List<String> _history = <String>[];

  /// Recorrido de escenas visitadas en esta sesión.
  List<String> get history => List.unmodifiable(_history);

  /// Navega a [sceneId]. Registra la visita en el estado y el historial.
  /// Devuelve false si el id no está registrado.
  bool goTo(GameEngine engine, String sceneId) {
    if (!engine.changeScene(sceneId)) return false;
    _history.add(sceneId);
    engine.state.recordVisitedScene(sceneId);
    return true;
  }

  /// Navega al mapa configurado.
  bool goToMap(GameEngine engine) => goTo(engine, mapSceneId);

  /// Vuelve a la escena anterior del recorrido si existe.
  bool back(GameEngine engine) {
    if (_history.length < 2) return false;
    _history.removeLast();
    final previous = _history.last;
    if (!engine.changeScene(previous)) return false;
    engine.state.recordVisitedScene(previous);
    return true;
  }

  /// Limpia el historial de navegación.
  void reset() => _history.clear();
}