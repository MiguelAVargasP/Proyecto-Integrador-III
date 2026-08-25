# Changelog — juegoupb

Todas las modificaciones importantes del proyecto se registran aquí.

Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.1.0/).

## [0.2.0] — 2026-08-25 — Incremento 2: SceneManager, NavigationManager y contenido data-driven

### Añadido
- `lib/engine/core/scene_manager.dart` — `SceneManager`: catálogo de escenas
  y escena activa (register/registerAll/get/knows/enter/unregister).
- `lib/engine/core/navigation_manager.dart` — `NavigationManager`: `goTo`,
  `goToMap`, `back`, historial; registra escenas visitadas en `GameState`
  (base para US-04).
- `GameEngine` refactorizado: delega en `scenes` y `navigation`; nueva API
  `navigateTo` / `navigateToMap` / `navigateBack`. API anterior intacta.
- Capa de contenido data-driven:
  - `game/models/scene_definition.dart` — `SceneDefinition`.
  - `game/data/scenes_data.dart` — datos provisionales de escenas.
  - `game/data/scene_catalog.dart` — `SceneCatalog`.
  - `game/scenes/generic_scene.dart` — `GenericScene`.
- Pruebas: `test/engine/scene_manager_test.dart` (7),
  `test/engine/navigation_manager_test.dart` (7),
  `test/game/scene_catalog_test.dart` (4),
  `test/game/generic_scene_test.dart` (4).

### Verificado
- `flutter analyze` → sin issues.
- `flutter test` → 47/47 pruebas en verde.

### Problemas encontrados
- Ninguno. La refactorización de `GameEngine` mantuvo la API pública, por lo
  que los tests del Incremento 1 no requirieron cambios.

### Pendiente / notas
- Sin assets todavía (`TODO: ASSET REQUIRED`); las escenas no referencian
  fondos inexistentes (regla §35).
- Los textos de escenas son provisionales hasta recibir contenido oficial UPB
  (regla §36).

## [0.1.0] — 2026-08-25 — Incremento 1: motor base

### Añadido
- `lib/engine/` — núcleo del motor propio (puro Dart, agnóstico de contenido):
  - `core/timer.dart` — `GameTimer` (cuenta regresiva, fin único, límites).
  - `core/game_state.dart` — `GameState` (estado serializable versionable).
  - `core/scene.dart` — `GameScene` (ciclo de vida onLoad/update/onExit).
  - `core/game_engine.dart` — `GameEngine` (escenas, `changeScene`,
    `advance(delta)`, ticker continuo).
- Pruebas del motor:
  - `test/engine/timer_test.dart` (7 casos).
  - `test/engine/game_state_test.dart` (8 casos, incluye roundtrip save).
  - `test/engine/game_engine_test.dart` (9 casos, incl. ciclo de vida y ticker).
- Documentación base:
  - `docs/ARCHITECTURE.md`, `docs/ENGINE.md`, `docs/TESTING.md`,
    `docs/PROGRESS.md`.

### Verificado
- `flutter analyze` → sin issues.
- `flutter test` → 25/25 pruebas en verde.

### Problemas encontrados
- Ninguno crítico. Núcleo del motor estable y sin dependencias circulares.

### Pendiente / notas
- Sin assets ni contenido UPB todavía (`TODO: ASSET REQUIRED`).
- `lib/main.dart` conserva la plantilla Flutter; será reemplazada en la
  FASE 2 de presentación.