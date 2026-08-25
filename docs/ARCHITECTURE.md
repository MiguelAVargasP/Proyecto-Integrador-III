# Arquitectura — juego de orientación universitaria UPB (juegoupb)

> Documento base de arquitectura. Fase 0 — auditoría completada. Incremento 1
> (motor base) implementado.

## 1. Principio

El proyecto **no** es una colección de pantallas Flutter con lógica embebida. Se
construye un **motor propio de juego** (inspirado en el patrón de *Fighting
Deck*) con una separación estricta de capas:

```
ENGINE      → lógica de juego genérica y reutilizable (agnóstica de contenido)
GAME        → contenido específico del ciclo estudiantil (data-driven)
PRESENTATION → widgets Flutter que consumen el motor
DATA         → definiciones configurables (escenas, etapas, decisiones)
ASSETS       → recursos gráficos / UI / audio
TESTS        → pruebas unitarias, de integración y widget
```

El motor **no contiene información institucional de la UPB**: trabaja con
identificadores opacos y [GameState] genérico.

## 2. Capas y responsabilidades

| Capa | Carpeta propuesta | Responsabilidades |
|---|---|---|
| Engine | `lib/engine/` | `GameEngine`, `GameState`, `GameScene`, `GameTimer` y (en fases siguientes) `TimeManager`, `DecisionManager`, `ConsequenceManager`, `ProgressManager`, `ResultsManager`, `SaveManager`, `AssetManager`. No conoce UPB. |
| Game | `lib/game/` | Escenas de contenido (mapa, escenario, tiempo, decisiones, resultados) y modelos (`stage`, `decision`, `player_stats`). Data-driven. |
| Presentation | `lib/presentation/` | Widgets, temas, pantallas Flutter que leen el motor y muestran estado. Sin lógica de negocio. |
| Data | `lib/game/data/` + `assets/data` | Definiciones de escenas, etapas y decisiones (Dart maps o JSON). |
| Assets | `assets/` | `maps/ backgrounds/ characters/ ui/ icons/ effects/ audio/`. |
| Docs | `docs/` | `ARCHITECTURE`, `ENGINE`, `GAME_DESIGN`, `ASSETS`, `TESTING`, `PROGRESS`. |
| Tests | `test/` | Unit (motor, juego), integración, lógica de juego, save/load, widget. |

> Nota: `assets/` y `data/` de contenido no existen todavía. Marcados
> `TODO: ASSET REQUIRED` hasta que el desarrollador proporcione los recursos
> "Mapa 16 bits UPB".

## 3. Estado actual (Incremento 1-2)

Implementado y probado el **núcleo del motor** en `lib/engine/core/` más la
**primera escena de contenido data-driven** en `lib/game/`:

| Archivo | Responsabilidad |
|---|---|
| `timer.dart` | `GameTimer`: cuenta regresiva genérica (start/stop/reset/update, `remaining`, `progress`, fin único). |
| `game_state.dart` | `GameState`: estado serializable, genérico (stats `Map<String,double>`, registros). Preparado para guardado (US-20) con `schemaVersion`. |
| `scene.dart` | `GameScene`: ciclo de vida `onLoad`/`update`/`onExit`. Agnóstica de contenido. |
| `scene_manager.dart` | `SceneManager`: catálogo de escenas y escena activa. |
| `navigation_manager.dart` | `NavigationManager`: ir a / mapa / volver atrás; registra visitas (base US-04). |
| `game_engine.dart` | `GameEngine`: orquesta `state` + `scenes` + `navigation`; `changeScene`, `advance(delta)` determinista y ticker continuo. |
| `game/models/scene_definition.dart` | `SceneDefinition`: definición data-driven de una escena (id, nombre, descripción, fondo). |
| `game/data/scenes_data.dart` | Datos provisionales de escenas del mapa (data-driven). |
| `game/data/scene_catalog.dart` | `SceneCatalog`: catálogo construido desde los datos. |
| `game/scenes/generic_scene.dart` | `GenericScene`: escena que resuelve su definición al cargar. |

Características del motor:
- **Puro Dart** (sin `package:flutter` en `engine/`): testeable de forma
  determinista y desacoplado de widgets.
- **Serialización versionable** del `GameState` (base para `SaveManager`).
- **SceneManager** (catálogo/activa) + **NavigationManager** (flujo y
  `visitedScenes`) con responsabilidades únicas y bajo acoplamiento.

## 4. Flujo conceptual alfa (objetivo)

```
INICIO → MAPA → ESCENA → ETAPA → GESTIÓN DEL TIEMPO → DECISIONES
       → CONSECUENCIAS → PROGRESO → PRIMER PARCIAL → RESULTADO
       → GUARDADO / REANUDACIÓN
```

## 5. Roadmap por incrementos

| Incr. | Objetivo | US |
|---|---|---|
| 1 | Motor base (engine/core + pruebas) | infra ✅ |
| 2 | SceneManager + NavigationManager + primera escena data-driven | infra ✅ |
| 3 | TimeManager (distribución de tiempo con tests) | US-06 |
| 4 | Etapas del ciclo estudiantil | US-05 |
| 5 | DecisionManager + ConsequenceManager | US-08 |
| 6 | ProgressManager + ResultsManager (pantalla boletín) | US-14, US-15 |
| 7 | SaveManager (guardar/reanudar/reiniciar) | US-20 |
| 8 | Mapa interactivo + navegación | US-01, US-02, US-03 |
| 9 | Integración alfa completa | Must Have |
| 10+ | Should Have (insignias, avisos, tutorial, identidad) | US-04, US-09, US-10, US-16, US-18, US-19, US-21 |

Ver también: `docs/PROGRESS.md`, `docs/ENGINE.md`, `docs/TESTING.md`.