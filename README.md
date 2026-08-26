# Orientación UPB — proyecto Flutter

Prototipo del juego de orientación universitaria (UPB seccional Bucaramanga), formato novela gráfica. Incluye el módulo de navegación por el mapa (US-01, US-02, US-03) y el sistema de enchufe de jugabilidad (`ContenidoEscena`) listo para que las siguientes historias del backlog se conecten.

## Qué trae esta carpeta

```
orientacion_upb/
├── pubspec.yaml            ← dependencias del proyecto
├── analysis_options.yaml   ← reglas de lint estándar de Flutter
├── assets/images/
│   └── mapa_campus.png     ← el mapa ilustrado real que compartiste
└── lib/
    ├── main.dart
    ├── core/                              (contrato de jugabilidad + estado del juego)
    ├── registro_inicial.dart              (dónde se conectan las historias reales)
    └── features/
        ├── mapa_navegacion/                (US-01, US-02, US-03 — completo)
        └── _ejemplo_contenido/             (ejemplo ilustrativo, bórralo al implementar US-06)
```

Esto es **todo el código Dart y los assets** del proyecto. Lo único que falta son las carpetas nativas (`android/`, y `ios/` si algún día lo necesitas), que Flutter genera automáticamente — no las incluyo porque ese paso requiere descargar binarios de Google (el motor de Flutter y el `gradle-wrapper.jar`) que no puedo generar por fuera de tu máquina ni simular a mano de forma confiable; cualquier intento manual de mi parte quedaría roto silenciosamente.

## Cómo arrancarlo (una sola vez)

Necesitas tener **Flutter instalado** (`flutter doctor` sin errores para Android). Luego, dentro de esta carpeta:

```bash
flutter create --platforms=android .
```

Este comando detecta que ya existe `pubspec.yaml` y `lib/`, **no los toca**, y solo agrega la carpeta `android/` que falta (con el `gradle-wrapper.jar` real, `AndroidManifest.xml`, etc.). Después:

```bash
flutter pub get
flutter run
```

Y deberías ver el mapa abrir directamente como pantalla de inicio.

## Primer paso recomendado al retomar el desarrollo

1. Corre el proyecto y confirma que el mapa se ve bien y que tocar un edificio navega a la escena placeholder.
2. Usa la calibración de hotspots (mantén presionado sobre el mapa en modo debug) para ajustar `posicionRelativa` en `lib/features/mapa_navegacion/models/escena_campus.dart` contra el asset real en tu pantalla.
3. Implementa **US-06 (gestión del tiempo)** como primera historia de jugabilidad real, siguiendo el patrón de `lib/features/_ejemplo_contenido/`. Bórralo cuando termines.

El prompt de Cline (`Prompt_Cline_Flutter.md`, entregado aparte) ya está escrito asumiendo que partes de este proyecto tal cual.
