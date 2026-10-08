import 'package:audioplayers/audioplayers.dart';

/// Servicio de audio global y aislado del juego (no depende de `EstadoJuego`
/// ni de `EstadoMapa`, ni de ningún widget).
///
/// Responsabilidades (RF de audio del juego serio):
/// - `soundtrack.mp3` en **bucle (loop)** de fondo durante toda la partida.
/// - `Final.WAV` **exclusivo** en la pantalla final tras el parcial: detiene
///   el soundtrack y reproduce solo el audio de cierre.
///
/// Es un singleton a propósito: la música debe sobrevivir a los cambios de
/// pantalla (mapa -> diálogo -> combate -> resultados) sin reiniciarse ni
/// duplicarse. No se envuelve en `ChangeNotifier` porque el audio no pinta UI;
/// expone getters si alguna pantalla quiere reflejar el estado (p. ej. el
/// icono de mute).
///
/// Robustez: en pruebas de widget y en dispositivos sin el plugin nativo,
/// las llamadas lanzan `MissingPluginException` de forma asíncrona; por eso
/// todos los métodos están envueltos en `try/catch` silencioso para NUNCA
/// romper el flujo del juego por un fallo de audio.
class AudioService {
  AudioService._();

  /// Instancia única compartida por toda la app.
  static final AudioService instance = AudioService._();

  // Dos reproductores separados: uno para la música de fondo persistente y
  // otro para sonidos puntuales (como el 'Final'). Así, detener/reproducir
  // el cierre nunca interrumpe por error el reproductor equivocado.
  final AudioPlayer _musica = AudioPlayer();
  final AudioPlayer _efectos = AudioPlayer();

  bool _soundtrackSonando = false;

  /// `true` mientras el soundtrack de fondo está activo.
  bool get soundtrackSonando => _soundtrackSonando;

  bool _silenciado = false;

  /// `true` si el jugador silenció toda la música desde la UI.
  bool get silenciado => _silenciado;

  /// Inicia (o reanuda) el soundtrack de fondo en bucle infinito.
  /// Es idempotente: si ya está sonando, no lo reinicia.
  Future<void> iniciarSoundtrack({double volumen = 0.45}) async {
    if (_silenciado || _soundtrackSonando) return;
    try {
      await _musica.setReleaseMode(ReleaseMode.loop);
      await _musica.setVolume(volumen);
      await _musica.play(AssetSource('sounds/soundtrack.mp3'));
      _soundtrackSonando = true;
    } catch (_) {
      // Sin plugin nativo (tests/plataformas no soportadas): se ignora.
    }
  }

  /// Detiene el soundtrack de fondo.
  Future<void> detenerSoundtrack() async {
    if (!_soundtrackSonando) return;
    try {
      await _musica.stop();
    } catch (_) {
      // ignorar
    }
    _soundtrackSonando = false;
  }

  /// Pantalla final: detiene el soundtrack y reproduce EXCLUSIVAMENTE el
  /// audio de cierre (`Final.WAV`) una sola vez.
  Future<void> reproducirFinal({double volumen = 0.9}) async {
    try {
      // Primero silenciamos la música de fondo para que el cierre sea exclusivo.
      await _musica.stop();
      _soundtrackSonando = false;
      await _efectos.setReleaseMode(ReleaseMode.stop);
      await _efectos.setVolume(volumen);
      await _efectos.play(AssetSource('sounds/Final.WAV'));
    } catch (_) {
      // ignorar
    }
  }

  /// Alterna el silencio global de la música de fondo.
  /// Devuelve el nuevo estado (true = silenciado).
  Future<bool> toggleSilencio() async {
    _silenciado = !_silenciado;
    if (_silenciado) {
      await detenerSoundtrack();
    } else {
      await iniciarSoundtrack();
    }
    return _silenciado;
  }

  /// Detiene todo el audio (música y efectos).
  Future<void> detenerTodo() async {
    try {
      await _musica.stop();
      await _efectos.stop();
    } catch (_) {
      // ignorar
    }
    _soundtrackSonando = false;
  }

  /// Libera los reproductores. Llamar solo al cerrar la app por completo.
  Future<void> dispose() async {
    try {
      await _musica.dispose();
      await _efectos.dispose();
    } catch (_) {
      // ignorar
    }
    _soundtrackSonando = false;
  }
}
