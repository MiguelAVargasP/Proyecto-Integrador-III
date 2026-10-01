# Backlog Priorizado del Producto: Juego de Orientación Universitaria — UPB Seccional Bucaramanga

**Autores:** Andrés Felipe Pinzón Camacho, Miguel Ángel Vargas Pardo  
**Docente:** Lenin Javier Serrano Gil  
**Universidad Pontificia Bolivariana Seccional Bucaramanga (UPB)** — Ingeniería de Sistemas e Informática — Proyecto Integrador 3 (2026)

---

## Resumen de Priorización
- **12 Must have** (Semanas 2 a 4: base versión alfa jugable de principio a fin)
- **7 Should have** (Semanas 3 a 5: mejoras sobre versión alfa)
- **2 Could have** (Semana 5: RF-07 y RF-11 si el avance lo permite)

---

## 1. Mapa y navegación por escenas

### US-01: Mapa ilustrado como punto de entrada
- **Requerimiento:** RF-01 | **Prioridad:** Must (Alta) | **Semana:** 3
- **Historia de usuario:** Como estudiante nuevo, quiero ver un mapa ilustrado del campus al iniciar el juego, para usarlo como punto de entrada visual a las escenas disponibles.
- **Criterio de aceptación:** El mapa se muestra al iniciar el juego y permite acceder visualmente a las escenas disponibles.

### US-02: Selección de espacios representativos del campus
- **Requerimiento:** RF-02 | **Prioridad:** Must (Alta) | **Semana:** 3
- **Historia de usuario:** Como estudiante nuevo, quiero seleccionar espacios representativos del campus desde el mapa ilustrado, para explorar los lugares más relevantes para mí.
- **Criterio de aceptación:** Al menos un espacio representativo del campus está disponible como escena seleccionable desde el mapa.

### US-03: Identificación de la escena actual y navegación
- **Requerimiento:** RF-03 | **Prioridad:** Must (Alta) | **Semana:** 3
- **Historia de usuario:** Como estudiante nuevo, quiero identificar en qué escena me encuentro y elegir la siguiente, para avanzar en la historia sin necesitar desplazamiento continuo.
- **Criterio de aceptación:** El jugador puede identificar su escena actual y seleccionar una nueva escena desde el mapa, sin desplazamiento continuo.

### US-04: Registro de escenas visitadas
- **Requerimiento:** RF-04 | **Prioridad:** Should (Media) | **Semana:** 3-4
- **Historia de usuario:** Como estudiante nuevo, quiero que el juego recuerde qué escenas ya visité, para tener noción de mi propio avance de exploración.
- **Criterio de aceptación:** El sistema conserva un registro accesible de las escenas visitadas por el jugador durante la partida.

---

## 2. Ciclo estudiantil y gestión del tiempo

### US-05: Etapas del ciclo estudiantil
- **Requerimiento:** RF-05 | **Prioridad:** Must (Alta) | **Semana:** 3-4
- **Historia de usuario:** Como estudiante nuevo, quiero avanzar por etapas del ciclo estudiantil (primeras clases, estudio independiente, primer parcial), para vivir una versión anticipada del semestre.
- **Criterio de aceptación:** El jugador puede avanzar por al menos tres etapas del ciclo estudiantil, cada una con impacto medible en su desempeño.

### US-06: Gestión del tiempo del jugador
- **Requerimiento:** RF-06 | **Prioridad:** Must (Alta) | **Semana:** 4
- **Historia de usuario:** Como estudiante nuevo, quiero distribuir mi tiempo entre actividades académicas y no académicas, para practicar la gestión del tiempo universitario.
- **Criterio de aceptación:** El jugador puede distribuir su tiempo entre actividades y el sistema refleja el efecto de esa distribución en su desempeño.

### US-07: Eventos imprevistos opcionales
- **Requerimiento:** RF-07 | **Prioridad:** Could (Baja) | **Semana:** 5
- **Historia de usuario:** Como estudiante nuevo, quiero enfrentar, si el tiempo de desarrollo lo permite, eventos imprevistos propios de la vida universitaria, para practicar cómo adaptarme a lo inesperado.
- **Criterio de aceptación:** Si el tiempo de desarrollo lo permite, se incluye al menos un evento imprevisto dentro del recorrido.

### US-09: Reinicio del recorrido
- **Requerimiento:** RF-09 | **Prioridad:** Should (Media) | **Semana:** 5
- **Historia de usuario:** Como estudiante nuevo, quiero poder reiniciar el recorrido tras finalizar una partida, para explorar otra estrategia sin consecuencias reales.
- **Criterio de aceptación:** El jugador puede reiniciar el recorrido completo desde el menú principal al finalizar una partida.

### US-11: Momento de reflexión tras cada etapa
- **Requerimiento:** RF-11 | **Prioridad:** Could (Baja) | **Semana:** 5
- **Historia de usuario:** Como estudiante nuevo, quiero tener un momento breve de reflexión al terminar cada etapa, para asimilar lo vivido antes de continuar.
- **Criterio de aceptación:** Al finalizar al menos una etapa, se presenta un breve espacio de reflexión o síntesis.

---

## 3. Consecuencias, progreso, resultados y guardado

### US-08: Consecuencias acumuladas y nivel de estrés
- **Requerimiento:** RF-08 | **Prioridad:** Must (Alta) | **Semana:** 4
- **Historia de usuario:** Como estudiante nuevo, quiero que mis decisiones se acumulen en un nivel de estrés o preparación visible, para entender cómo afectan mi resultado antes del parcial.
- **Criterio de aceptación:** El resultado mostrado antes del parcial varía según las decisiones previas del jugador.

### US-10: Insignias por hitos del recorrido
- **Requerimiento:** RF-10 | **Prioridad:** Should (Media) | **Semana:** 4-5
- **Historia de usuario:** Como estudiante nuevo, quiero recibir insignias por hitos relevantes de mi recorrido, para sentir reconocimiento por mi progreso.
- **Criterio de aceptación:** El jugador recibe una notificación visible al obtener una insignia asociada a un hito relevante.

### US-12: Duración corta de la partida
- **Requerimiento:** RF-12 | **Prioridad:** Must (Alta) | **Semana:** 2 (diseño) / verificar en 4-5
- **Historia de usuario:** Como estudiante nuevo, quiero que una partida completa pueda jugarse en una sesión corta, para poder usarla sin comprometer mucho tiempo.
- **Criterio de aceptación:** Una partida completa puede finalizarse dentro de una sesión corta, definida en la etapa de diseño.

### US-13: Retroalimentación inmediata
- **Requerimiento:** RF-13 | **Prioridad:** Must (Alta) | **Semana:** 4
- **Historia de usuario:** Como estudiante nuevo, quiero recibir retroalimentación inmediata tras mis acciones más relevantes, para saber que el juego registró mi decisión.
- **Criterio de aceptación:** El sistema responde visualmente ante cada acción relevante del jugador sin demoras perceptibles.

### US-14: Progreso acumulado visible
- **Requerimiento:** RF-14 | **Prioridad:** Must (Alta) | **Semana:** 4
- **Historia de usuario:** Como estudiante nuevo, quiero consultar mi progreso acumulado en cualquier momento, para saber qué tanto llevo del recorrido.
- **Criterio de aceptación:** El jugador puede consultar en cualquier momento su progreso acumulado dentro del recorrido.

### US-15: Pantalla de resultados finales
- **Requerimiento:** RF-15 | **Prioridad:** Must (Alta) | **Semana:** 4
- **Historia de usuario:** Como estudiante nuevo, quiero ver una pantalla de resultados al finalizar, análoga a un boletín de parcial, para cerrar la experiencia con un resumen claro.
- **Criterio de aceptación:** Al finalizar el recorrido, se presenta una pantalla que resume el resultado obtenido.

### US-16: Transparencia sobre decisiones de alto impacto
- **Requerimiento:** RF-16 | **Prioridad:** Should (Media) | **Semana:** 4-5
- **Historia de usuario:** Como estudiante nuevo, quiero que el juego me advierta antes de decisiones de alto impacto y me explique después qué influyó en mi resultado, para entender el porqué de lo que obtuve.
- **Criterio de aceptación:** El sistema advierte antes de decisiones de alto impacto y explica, al final, cuáles decisiones influyeron en el resultado.

### US-20: Guardado, reanudación y gestión de partidas
- **Requerimiento:** RF-20 | **Prioridad:** Must (Alta) | **Semana:** 4
- **Historia de usuario:** Como estudiante nuevo, quiero guardar mi progreso, reanudarlo, reiniciarlo o consultar mi resultado final, para no perder mi avance entre sesiones.
- **Criterio de aceptación:** El jugador puede guardar, reanudar, reiniciar y consultar el resultado final de su progreso en el mismo dispositivo.

---

## 4. Interfaz, identidad visual y accesibilidad

### US-17: Interfaz institucional coherente con la UPB
- **Requerimiento:** RF-17 | **Prioridad:** Must (Alta) | **Semana:** 2-3
- **Historia de usuario:** Como estudiante nuevo, quiero ver una interfaz coherente con la identidad de la UPB, para confiar en que es una herramienta institucional seria.
- **Criterio de aceptación:** Los elementos de interfaz siguen consistentemente la identidad visual institucional definida para el proyecto.

### US-18: Identidad visual propia del juego
- **Requerimiento:** RF-18 | **Prioridad:** Should (Media) | **Semana:** 2-3
- **Historia de usuario:** Como estudiante nuevo, quiero que el juego tenga su propio personaje, colores e iconografía, para que se sienta como una experiencia con identidad propia y no solo un formulario institucional.
- **Criterio de aceptación:** El juego presenta un personaje, una paleta de colores y una iconografía definidos y aplicados de forma consistente.

### US-19: Interfaz de baja carga cognitiva
- **Requerimiento:** RF-19 | **Prioridad:** Should (Media) | **Semana:** 2-3
- **Historia de usuario:** Como estudiante nuevo sin experiencia previa en videojuegos, quiero menús sencillos con iconografía reconocible antes que texto extenso, para no sentirme abrumado por la interfaz.
- **Criterio de aceptación:** Las pantallas principales priorizan iconografía reconocible sobre texto extenso.

### US-21: Tutorial de la mecánica de gestión del tiempo
- **Requerimiento:** RF-21 | **Prioridad:** Should (Media) | **Semana:** 4
- **Historia de usuario:** Como estudiante nuevo, quiero que el juego me explique la mecánica de gestión del tiempo antes de exigirme usarla, para no fallar por desconocimiento de las reglas.
- **Criterio de aceptación:** Antes de exigir el uso de la mecánica de gestión del tiempo, el sistema presenta una explicación breve al jugador.
