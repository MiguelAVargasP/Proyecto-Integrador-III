import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Una pose de sprite ya decodificada, con el punto de apoyo horizontal
/// (en píxeles de la imagen) que corresponde al centro del cuerpo.
class SpritePose {
  final ui.Image imagen;
  final double anclaX;
  const SpritePose(this.imagen, this.anclaX);
}

/// Carga una sola vez los sprites PNG del combate y los guarda en memoria.
/// Mientras no estén cargados, `Fighter` usa su dibujo de respaldo por
/// código, así que el combate nunca se bloquea por esperar imágenes.
class SpriteCache {
  /// Los PNG están a 3 píxeles de imagen por unidad lógica (320x180).
  static const double pxPorUnidad = 3.0;

  static const String _carpeta = 'assets/images/personajes/combate';

  /// id -> ancla X (px de imagen) = centro del cuerpo / punto de apoyo.
  static const Map<String, double> _anclas = {
    'estudiante_idle': 37.7,
    'estudiante_alto': 51.1,
    'estudiante_golpe': 43.9,
    'estudiante_golpeado': 58.6,
    'estudiante_patada': 32.0,
    'estudiante_bloqueo': 57.2,
    'estudiante_caminar1': 41.1,
    'estudiante_caminar2': 36.2,
    'estudiante_caminar3': 42.2,
    'estudiante_caminar4': 37.6,
    'estudiante_caminar5': 39.4,
    'estudiante_caminar6': 36.0,
    'estudiante_caminar7': 37.3,
    'estudiante_caminar8': 36.0,
  };

  static final Map<String, SpritePose> _poses = {};
  static bool _cargando = false;

  static bool get listo => _poses.length == _anclas.length;

  static SpritePose? pose(String id) => _poses[id];

  static Future<void> cargar() async {
    if (listo || _cargando) return;
    _cargando = true;
    try {
      for (final entrada in _anclas.entries) {
        final datos = await rootBundle.load('$_carpeta/${entrada.key}.png');
        final codec = await ui.instantiateImageCodec(datos.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        _poses[entrada.key] = SpritePose(frame.image, entrada.value);
      }
    } catch (_) {
      // Si falta algún archivo, se queda el dibujo de respaldo.
      _poses.clear();
    } finally {
      _cargando = false;
    }
  }
}