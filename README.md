# Primiparo

**Tu primer corte, tu gran inicio.**

Juego serio para Android que orienta a estudiantes de nuevo ingreso de la **Universidad Pontificia Bolivariana (UPB), Seccional Bucaramanga**. A lo largo de 8 semanas, el jugador recorre el campus, toma decisiones y aprende a manejar el tiempo y la presión académica hasta llegar al primer parcial.

Proyecto Integrador 3 · Ingeniería de Sistemas e Informática · 2026

## Descargar

[⬇️ Descargar la última versión (APK)](https://github.com/MiguelAVargasP/Proyecto-Integrador-III/releases/latest)

### Cómo instalar
1. Descarga el archivo `.apk` en tu celular Android.
2. Ábrelo. Si Android lo solicita, permite "Instalar apps desconocidas" para tu navegador o gestor de archivos.
3. Si aparece un aviso de Play Protect, elige "Instalar de todas formas".
4. Abre la app y toca **EMPEZAR**.

Requiere Android 5.0 (API 21) o superior.

## ¿De qué trata?

Eres un estudiante que empieza la universidad. El mapa ilustrado del campus es el escenario de la historia: cada semana visitas los bloques del campus (A al L) y el Templo, y en cada lugar enfrentas una situación con dos opciones. Cada decisión cambia tu nivel de estrés y queda registrada.

Al recorrer los bloques de la semana puedes completarla y avanzar a la siguiente. En la semana 8 presentas el parcial, un combate por turnos contra una hoja de examen, y al terminar ves tus resultados.

## Características

- **Mapa del campus** como punto de entrada y escenario de la historia, con progreso por semana.
- **8 semanas de historia** basadas en un guion, con decisiones por cada bloque del campus.
- **Gestión del tiempo:** distribución de horas entre estudio, descanso y otras actividades, con efecto sobre el estrés.
- **Etapas del ciclo estudiantil:** primeras clases y estudio independiente.
- **Eventos imprevistos** y **momentos de reflexión** al cerrar cada etapa.
- **Parcial como minijuego de combate** en estilo pixel art, con sprites propios, efectos visuales y una hoja de examen como rival.
- **Insignias**, **decisiones registradas** (con advertencia en las de alto impacto) y **pantalla de resultados** final.
- **Guardado automático** de la partida y opción de reiniciar el recorrido.
- **Banda sonora** de fondo y audio de cierre exclusivo de la pantalla final.

## Tecnologías

- [Flutter](https://flutter.dev) y Dart (SDK `>=3.3.0 <4.0.0`), solo Android.
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) para el guardado de la partida.
- [`audioplayers`](https://pub.dev/packages/audioplayers) para la música y los efectos.
- Motor de combate propio en Dart (`lib/features/combate/motor`), con el juego específico del parcial en `lib/features/combate/juego`.
- Tipografía [Pixelify Sans](https://fonts.google.com/specimen/Pixelify+Sans) (licencia OFL).

## Estructura del proyecto

```
lib/
├── main.dart
├── core/                    # Estado global del juego y servicio de audio
├── features/
│   ├── menu_inicio/         # Portada y botón EMPEZAR
│   ├── mapa_navegacion/     # Mapa del campus, escenas y estado del mapa
│   ├── semanas/             # Guion de las 8 semanas
│   ├── dialogo/             # Motor de diálogos con opciones
│   ├── gestion_tiempo/      # Reparto de horas y tutorial
│   ├── etapas/              # Primeras clases y estudio independiente
│   ├── eventos/             # Eventos imprevistos
│   ├── reflexion/           # Momento de reflexión
│   ├── combate/             # Parcial: motor, juego y pantallas
│   ├── progreso/            # Progreso e insignias
│   ├── decisiones/          # Historial de decisiones
│   ├── resultados/          # Resultado final
│   ├── menu_principal/      # Menú de progreso, resultados y reinicio
│   └── reiniciar/           # Reinicio del recorrido
assets/
├── images/                  # Mapa, escenarios (Menu.png, Bloque A-L) y personajes
├── sounds/                  # Banda sonora y audio final
├── fonts/                   # Pixelify Sans
└── Guion_del_juego_serio_8_semanas.md
docs/
└── backlog.md               # Backlog priorizado del producto
test/                        # Pruebas de widgets y de lógica
```

## Cómo ejecutarlo

### Requisitos
- Flutter instalado y `flutter doctor` sin errores para Android.
- Android SDK Platform 35 y CMake 3.22.1 (se instalan desde el SDK Manager de Android Studio), necesarios para compilar el plugin de audio.
- Un emulador o un celular Android con depuración USB.

### Pasos
```bash
git clone https://github.com/MiguelAVargasP/Proyecto-Integrador-III.git
cd Proyecto-Integrador-III
flutter pub get
flutter run
```

### Generar el APK
```bash
flutter build apk --release
```
El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`.

### Pruebas y análisis
```bash
flutter analyze
flutter test
```

## Documentación

El backlog priorizado, con las historias de usuario (US-01 a US-20) y los requerimientos, está en [`docs/backlog.md`](docs/backlog.md). El guion completo de las 8 semanas está en `assets/Guion_del_juego_serio_8_semanas.md`.

## Equipo

- **Andrés Felipe Pinzón Camacho**
- **Miguel Ángel Vargas Pardo**

**Docente asesor:** Lenin Javier Serrano Gil

Universidad Pontificia Bolivariana, Seccional Bucaramanga · Ingeniería de Sistemas e Informática · Proyecto Integrador 3 (2026)
