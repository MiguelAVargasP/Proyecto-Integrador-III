# PROGRESS — Backlog y estado de historias (juegoupb)

Convenciones de estado:
`[ ]` NOT STARTED · `[-]` IN PROGRESS · `[x]` DONE · `[!]` BLOCKED ·
`[~]` DEFERRED

---

## Must Have (12)

**Mapa y navegación**

`[ ]` US-01 — Mapa ilustrado como punto de entrada (_Fase 8_)
`[ ]` US-02 — Selección de espacios representativos (_Fase 8_)
`[ ]` US-03 — Identificación de escena actual y navegación (_Fase 8_)

**Ciclo estudiantil y tiempo**

`[ ]` US-05 — Etapas del ciclo estudiantil (primeras clases → estudio →
parcial) (_Fase 6_, depende de US-06)
`[ ]` US-06 — Gestión del tiempo del jugador (_Fase 5_)
`[ ]` US-12 — Duración corta de partida (_decisión de diseño a documentar_)
`[ ]` US-13 — Retroalimentación inmediata (visual)

**Consecuencias, progreso y resultados**

`[ ]` US-08 — Consecuencias acumuladas y nivel de estrés (_Fase 7_)
`[ ]` US-14 — Progreso acumulado visible (_Fase 8_)
`[ ]` US-15 — Pantalla de resultados/boletín (_Fase 8_)
`[ ]` US-20 — Guardado, reanudación y gestión de partidas (_Fase 9_)

**Interfaz e identidad**

`[ ]` US-17 — Interfaz institucional coherente UPB (_Fase 3_)

## Should Have (7)

`[ ]` US-04 — Registro de escenas visitadas
`[ ]` US-09 — Reinicio del recorrido
`[ ]` US-10 — Insignias por hitos
`[ ]` US-16 — Aviso en decisiones de alto impacto + explicación final
`[ ]` US-18 — Identidad visual propia
`[ ]` US-19 — Interfaz de baja carga cognitiva
`[ ]` US-21 — Tutorial de gestión del tiempo

## Could Have (2)

`[~]` US-07 — Eventos imprevistos opcionales (solo si Must/Should estables)
`[~]` US-11 — Momento de reflexión/síntesis (solo si estable)

---

## Detalle y decisiones por historia (Workbook)

> El campo `Observaciones` se alimenta al cerrar cada historia según la
> Definition of Done (implementada/integrada/probada/criterios/arquitectura/
> sin errores/backlog).

| US | Estado | Dependencias | Implementación | Pruebas | Criterios de aceptación | Observaciones |
|----|--------|--------------|----------------|---------|--------------------------|----------------|
| (infra: motor base) | `[x]` INCREMENTO 1 | — | `engine/core` (Timer, GameState, Scene, GameEngine) | 24 tests de motor + 1 plantilla | motor compila, `analyze` limpio, `test` verde | Prepara el terreno para US-06 y siguientes. |
| (infra: navegación) | `[x]` INCREMENTO 2 | Incr. 1 | `SceneManager`, `NavigationManager` + capa data-driven (`SceneDefinition`, `SceneCatalog`, `GenericScene`) | +22 tests (total 47) | navegación funcional, catálogo carga datos, `analyze` limpio, `test` verde | Base para US-01/02/03 (mapa) y US-04 (visitas). |

## Siguiente paso

**Incremento 3** — TimeManager (gestión del tiempo, US-06) con distribución
válida/inválida y efectos; primeras pruebas unitarias de la mecánica base.