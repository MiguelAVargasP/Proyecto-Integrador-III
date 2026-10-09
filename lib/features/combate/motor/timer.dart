/// Temporizador de cuenta regresiva genérico, reutilizado por estados de
/// combate, fases de ataque y cooldowns de habilidades — igual que en el
/// motor original, el Timer no sabe nada de fighters, habilidades ni
/// cartas.
///
/// Uso:
/// ```dart
/// final timer = Timer(1.5);
/// timer.start();
/// if (timer.update(delta)) { ... } // true solo en el frame en que termina
/// ```
class Timer {
  double _duration;
  double _elapsed = 0.0;
  bool running = false;
  bool finished = false;

  Timer([double duration = 0.0]) : _duration = duration;

  double get duration => _duration;
  double get elapsed => _elapsed;

  /// Segundos restantes (nunca negativo).
  double get remaining =>
      (_duration - _elapsed) < 0 ? 0.0 : (_duration - _elapsed);

  /// Fracción transcurrida, entre 0.0 y 1.0.
  double get progress {
    if (_duration <= 0.0) return 1.0;
    final p = _elapsed / _duration;
    return p < 0.0 ? 0.0 : (p > 1.0 ? 1.0 : p);
  }

  /// Inicia (o reinicia) la cuenta regresiva; opcionalmente con una
  /// duración nueva.
  void start([double? duration]) {
    if (duration != null) _duration = duration;
    _elapsed = 0.0;
    running = true;
    finished = false;
  }

  void stop() => running = false;

  void reset() {
    _elapsed = 0.0;
    running = false;
    finished = false;
  }

  /// Avanza `delta` segundos. Devuelve true exactamente una vez, en el
  /// frame en que la duración llega a cero.
  bool update(double delta) {
    if (!running) return false;
    _elapsed += delta < 0 ? 0.0 : delta;
    if (_elapsed >= _duration) {
      _elapsed = _duration;
      running = false;
      finished = true;
      return true;
    }
    return false;
  }
}
