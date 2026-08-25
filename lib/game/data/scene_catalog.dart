/// Catálogo de definiciones de escenas, cargado desde datos configurables.
///
/// Sigue el principio data-driven del proyecto: las definiciones viven en
/// `scenes_data.dart` (o en JSON en el futuro) y se construyen aquí, de modo
/// que modificar el contenido no exige tocar el motor.
library;

import '../models/scene_definition.dart';
import 'scenes_data.dart';

class SceneCatalog {
  SceneCatalog._(Map<String, SceneDefinition> scenes)
      : _scenes = Map.unmodifiable(scenes);

  final Map<String, SceneDefinition> _scenes;

  /// Construye el catálogo a partir de una lista de mapas data-driven.
  factory SceneCatalog.fromData(List<Map<String, dynamic>> data) {
    final scenes = <String, SceneDefinition>{};
    for (final entry in data) {
      final definition = SceneDefinition.fromMap(entry);
      scenes[definition.id] = definition;
    }
    return SceneCatalog._(scenes);
  }

  static SceneCatalog? _defaultInstance;

  /// Catálogo por defecto del proyecto, cargado de forma diferida.
  static SceneCatalog defaultCatalog() {
    final instance = _defaultInstance;
    if (instance != null) return instance;
    final created = SceneCatalog.fromData(kScenesData);
    _defaultInstance = created;
    return created;
  }

  /// Devuelve la definición de [id] (null si no existe).
  SceneDefinition? get(String id) => _scenes[id];

  /// Indica si existe la escena [id].
  bool knows(String id) => _scenes.containsKey(id);

  /// Todas las definiciones registradas.
  Iterable<SceneDefinition> get all => _scenes.values;

  /// Número de escenas registradas.
  int get length => _scenes.length;
}