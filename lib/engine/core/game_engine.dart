/// Motor del juego: estado, escenas, navegación y bucle de actualización.
///
/// El [GameEngine] es agnóstico de contenido. Administra el [GameState], el
/// catálogo de [GameScene] a través de [scenes] y el flujo entre escenas a
/// través de [navigation]. Proporciona:
///
/// - `advance(delta)`: actualización determinista, útil para pruebas y para
///   mostrar la lógica desde la capa de presentación Flutter.
/// - `startTicker(interval)`: un bucle continuo opcional (Timer de
///   `dart:async`) que llama a [advance] periódicamente.
///
/// Este motor evita el bucle de render propio de un motor basado en frames:
/// en Flutter la presentación la gestionan los widgets, y el motor solo aporta
/// lógica pura (Dart, sin `flutter`).
library;

import 'dart:async';

import 'game_state.dart';
import 'navigation_manager.dart';
import 'scene.dart';
import 'scene_manager.dart';

class GameEngine {
  GameEngine({
    GameState? state,
    SceneManager? scenes,
    NavigationManager? navigation,
  })  : state = state ?? GameState(),
        scenes = scenes ?? SceneManager(),
        navigation = navigation ?? NavigationManager();

  /// Estado global del juego, compartido por todas las escenas.
  GameState state;

  /// Catálogo de escenas y escena activa.
  final SceneManager scenes;

  /// Flujo de navegación (ir a, mapa, volver atrás).
  final NavigationManager navigation;

  bool _running = false;
  Timer? _ticker;

  /// La escena activa (null si ninguna está cargada).
  GameScene? get current => scenes.current;

  /// Indica si el ticker continuo está activo.
  bool get isRunning => _running;

  // ------------------------------------------------------------------ escenas

  /// Registra una escena en el catálogo por su identificador.
  void registerScene(GameScene scene) => scenes.register(scene);

  /// Registra varias escenas a la vez.
  void registerScenes(Iterable<GameScene> scenes) =>
      this.scenes.registerAll(scenes);

  /// Elimina una escena del catálogo (deja la activa en null si coincide).
  void unregisterScene(String id) => scenes.unregister(id);

  /// Descubre si una escena está registrada.
  bool knowsScene(String id) => scenes.knows(id);

  /// Cambia a la escena [id]. Invoca `onExit` de la actual y `onLoad` de la
  /// nueva. Devuelve `false` si el identificador no existe.
  bool changeScene(String id) {
    final previous = scenes.current;
    final next = scenes.get(id);
    if (next == null) return false;
    previous?.onExit(this);
    scenes.enter(id);
    state.sceneId = id;
    next.onLoad(this);
    return true;
  }

  // ------------------------------------------------------------- navegación

  /// Navega a [sceneId], registrando la visita (US-03/04).
  bool navigateTo(String sceneId) => navigation.goTo(this, sceneId);

  /// Navega al mapa configurado.
  bool navigateToMap() => navigation.goToMap(this);

  /// Vuelve a la escena anterior del recorrido si existe.
  bool navigateBack() => navigation.back(this);

  // ------------------------------------------------------------------ bucle

  /// Avanza la lógica de la escena activa por `delta` segundos.
  /// Es determinista y resulta la puerta para pruebas y UI.
  void advance(double delta) {
    final scene = scenes.current;
    if (scene != null) scene.update(this, delta);
  }

  /// Inicia un ticker continuo que llama a [advance] con [interval].
  void startTicker(Duration interval) {
    stopTicker();
    _ticker = Timer.periodic(interval, (t) {
      advance(interval.inMilliseconds / 1000.0);
    });
    _running = true;
  }

  /// Detiene el ticker continuo.
  void stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _running = false;
  }

  /// Restablece el estado a uno nuevo u opcionalmente te indicado.
  void resetState([GameState? newState]) {
    state = newState ?? GameState();
  }

  /// Libera el ticker (llamar al destruir el motor).
  void dispose() {
    stopTicker();
  }
}