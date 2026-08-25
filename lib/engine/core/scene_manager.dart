/// SceneManager: catálogo de escenas y escena activa del motor.
///
/// Responsabilidad única: registrar, consultar y activar [GameScene]s. No
/// conoce el estado del juego ni el flujo de navegación; esas son
/// responsabilidad de [GameEngine] y [NavigationManager].
///
/// El manager es agnóstico de contenido: solo trabaja con identificadores
/// opacos.
library;

import 'scene.dart';

class SceneManager {
  final Map<String, GameScene> _scenes = <String, GameScene>{};
  GameScene? _current;

  /// La escena activa (null si ninguna está activa).
  GameScene? get current => _current;

  /// Número de escenas registradas.
  int get length => _scenes.length;

  /// Identificadores de las escenas registradas.
  Iterable<String> get ids => _scenes.keys;

  /// Registra una escena por su identificador.
  void register(GameScene scene) {
    _scenes[scene.id] = scene;
  }

  /// Registra varias escenas a la vez.
  void registerAll(Iterable<GameScene> scenes) {
    for (final scene in scenes) {
      register(scene);
    }
  }

  /// Devuelve la escena registrada bajo [id] (null si no existe).
  GameScene? get(String id) => _scenes[id];

  /// Indica si [id] está registrado.
  bool knows(String id) => _scenes.containsKey(id);

  /// Marca la escena [id] como activa y la devuelve; null si no existe.
  GameScene? enter(String id) {
    final next = _scenes[id];
    if (next == null) return null;
    _current = next;
    return next;
  }

  /// Elimina la escena [id]. Si era la activa, la activa pasa a null.
  /// Devuelve true si se eliminó.
  bool unregister(String id) {
    final removed = _scenes.remove(id) != null;
    if (removed && _current?.id == id) {
      _current = null;
    }
    return removed;
  }
}