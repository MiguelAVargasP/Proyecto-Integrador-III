# TESTING — Estrategia de pruebas (juegoupb)

Las pruebas validan **comportamiento**, no cobertura artificial. Suite
organizada en la carpeta `test/` de Flutter.

## Tipos de prueba

- **Unit tests del motor** (`test/engine/`): prueban `GameTimer`, `GameState`,
  `GameScene` y `GameEngine` de forma determinista (el motor es puro Dart, sin
  widgets).
- **Tests de lógica de juego** (`test/game/`, próximas fases): managers
  (`TimeManager`, `DecisionManager`, `ConsequenceManager`, ...). Soporte para
  pruebas puras.
- **Pruebas de integración/escena**: ciclo de vida y transiciones.
- **Save/load tests** (`test/save_load_test.dart`, US-20): serialización y
  reconstrucción.
- **Widget tests** (capa de presentación): flujo visual básico.

## Estado actual (Incremento 1-2 — motor base y navegación)

| Archivo | Cubre | Casos |
|---|---|---|
| `test/engine/timer_test.dart` | GameTimer | inicio inactivo, cuenta atrás, fin único, reinicio, límites de `progress`, `stop`, deltas negativos |
| `test/engine/game_state_test.dart` | GameState | por defecto, acotado `setStat`, `modifyStat` acumulativo, dedupe de escenas/insignias, orden de decisiones, ida y vuelta JSON (mapa y string) |
| `test/engine/game_engine_test.dart` | GameEngine + GameScene | inicio sin escena, registro/desregistro, `changeScene` con hooks y `sceneId`, id desconocido, `advance`, `resetState`, ticker continuo |
| `test/engine/scene_manager_test.dart` | SceneManager | vacío inicial, registro/consulta, `enter` (activa y desconocido), `get`, `unregister` (activa e inactiva) |
| `test/engine/navigation_manager_test.dart` | NavigationManager | `goTo` con registro, id desconocido, `goToMap`, historial ordenado, `back`, `back` insuficiente, `reset` |
| `test/game/scene_catalog_test.dart` | SceneCatalog + SceneDefinition | catálogo por defecto, datos arbitrarios, escena desconocida, campos opcionales |
| `test/game/generic_scene_test.dart` | GenericScene | resolución desde catálogo, fallback al id, catálogo inyectado, integración de navegación |
| `test/widget_test.dart` | Plantilla Flutter | humo del contador (base inicial) |

## Comandos

```powershell
cd "D:\Documents\Proyecto integrador 3\juegoupb"
flutter analyze      # sin issues
flutter test         # 47 tests pasan
```

## Resultado verificado (Incremento 1-2)

- `flutter analyze` → **No issues found!**
- `flutter test` → **47/47 passing**.

(La suite crecerá en cada incremento; este documento se mantiene al día.)