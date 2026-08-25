# ENGINE — Motor de juego (juegoupb)

Este documento describe el motor propio del proyecto. El motor es **agnóstico
de contenido**: no conoce la UPB, edificios, etapas ni decisiones. Trabaja con
identificadores y datos.

---

## Estructura

```
lib/engine/
└── core/
    ├── timer.dart              # GameTimer: cuenta regresiva genérica
    ├── game_state.dart         # GameState: estado serializable
    ├── scene.dart              # GameScene: ciclo de vida abstracto
    ├── scene_manager.dart      # SceneManager: catálogo y escena activa
    ├── navigation_manager.dart # NavigationManager: ir a / mapa / volver
    └── game_engine.dart        # GameEngine: orquesta estado + escenas + bucle

lib/game/   (capa de contenido, data-driven)
├── models/scene_definition.dart # definición de una escena
├── data/scenes_data.dart        # datos provisionales de escenas
├── data/scene_catalog.dart      # catálogo construido desde los datos
└── scenes/generic_scene.dart    # escena genérica que resuelve su definición
```

## Componente actual: 1. GameTimer

Reutilizable, similar al `Timer` de Fighting-Deck. Semántica del retorno de
`update(delta)`: devuelve `true` **exactamente una vez**, en el paso en que la
duración llega a cero. Apoya cadenas de transición (por ejemplo
`espera → decision → siguiente`).

```dart
final timer = GameTimer(duration: 2.0);
timer.start();
if (timer.update(dt)) { /* fin de fase */ }
```

## Componente actual: 2. GameState

Contenedor genérico de estado que más adelante leen los managers.

- `stageId`, `sceneId`: identificadores opacos.
- `progressIndex`: avance global (0 = inicio, N = fin).
- `stats: Map<String,double>`: p. ej. `stress`, `preparation`, `performance`.
- `strings: Map<String,String>`: extras.
- `visitedScenes`, `decisionLog`, `badges`: registros sin duplicados.
- `isFinished`: marca de boletín emitido.

**Serialización**: `toJson()`/`encode()`, `fromJson()`/`decode()` con
`schemaVersion` (`kGameStateSchemaVersion = 1`), base para `SaveManager`
(US-20).

## Componente actual: 3. GameScene

Ciclo de vida: `onLoad(engine)`, `update(engine, delta)`, `onExit(engine)`.
Las subclases de la capa `game/` definen contenido; el motor no.

## Componente actual: 4. GameEngine

- `state`: el [GameState] compartido.
- `scenes`: [SceneManager] (catálogo y escena activa).
- `navigation`: [NavigationManager] (flujo entre escenas).
- `registerScene` / `registerScenes` / `unregisterScene` / `knowsScene`
  (delegados a `scenes`).
- `changeScene(id)`: transición con `onExit`/`onLoad`, fija `state.sceneId`.
- `navigateTo` / `navigateToMap` / `navigateBack` (delegados a `navigation`).
- `advance(delta)`: actualización determinista (pruebas y UI).
- `startTicker(interval)` / `stopTicker`: bucle continuo opcional
  (`dart:async`), sin depender del framework Flutter.

## Componente actual: 5. SceneManager

- `register` / `registerAll`: registrar escenas por su `id`.
- `get(id)` / `knows(id)` / `ids` / `length`: consulta del catálogo.
- `enter(id)`: marca la escena activa y la devuelve (null si no existe).
- `current`: la escena activa.
- `unregister(id)`: elimina; si era la activa, deja `current` en null.

No ejecuta la vida útil del motor: `GameEngine.changeScene` orquesta los
hooks `onExit`/`onLoad` alrededor de `enter`.

## Componente actual: 6. NavigationManager

- `goTo(engine, sceneId)`: navega y registra la visita en el estado
  (`visitedScenes`) y en el historial.
- `goToMap(engine)`: navega al mapa (id configurable, por defecto `'map'`).
- `back(engine)`: vuelve a la escena anterior del recorrido si existe.
- `history`: recorrido inmodificable de las escenas visitadas.
- `reset()`: limpia el historial.

El id del mapa es **configuración**, no contenido: se inyecta en el
constructor, por lo que el motor sigue sin conocer la UPB.

## Componente actual: 7. Capa de juego (data-driven)

Definiciones de contenido que el motor no conoce:

- `SceneDefinition`: id opaco, nombre mostrable, descripción y ruta de fondo
  (vacío mientras no exista asset: `TODO: ASSET REQUIRED`).
- `SceneCatalog`: construye `SceneDefinition`s desde datos configurables
  (`fromData`) y expone un catálogo por defecto (`defaultCatalog`).
- `GenericScene`: escena concreta que al cargar resuelve su `SceneDefinition`
  del catálogo; la capa de presentación usará `displayName`, `description` y
  `background` para renderizar el escenario.

---

Documentación del motor se actualiza en cada incremento.