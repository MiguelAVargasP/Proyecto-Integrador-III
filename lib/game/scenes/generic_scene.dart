/// Escena de contenido genérica (data-driven).
///
/// Resuelve su definición desde un [SceneCatalog] al cargar. En el futuro la
/// capa de presentación usará `displayName`, `description` y `background` para
/// renderizar el escenario tipo novela visual.
library;

import '../../engine/core/game_engine.dart';
import '../../engine/core/scene.dart';
import '../data/scene_catalog.dart';
import '../models/scene_definition.dart';

class GenericScene extends GameScene {
  GenericScene({required super.id, SceneCatalog? catalog})
      : _catalog = catalog ?? SceneCatalog.defaultCatalog();

  final SceneCatalog _catalog;
  SceneDefinition? _definition;

  /// Definición resuelta al cargar (null si la escena no está en el catálogo).
  SceneDefinition? get definition => _definition;

  /// Nombre mostrable (cae al id si no hay definición).
  String get displayName => _definition?.displayName ?? id;

  /// Indica si la escena tiene definición en el catálogo.
  bool get hasDefinition => _definition != null;

  @override
  void onLoad(GameEngine engine) {
    _definition = _catalog.get(id);
  }
}