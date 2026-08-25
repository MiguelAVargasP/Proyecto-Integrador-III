/// Timer genérico de cuenta regresiva del motor.
///
/// El motor proporciona este primitivo reutilizable de tiempo. Los sistemas del
/// juego (etapas, gestión del tiempo, temporizadores de escena) se construyen
/// sobre él, pero el timer nunca conoce etapas, decisiones ni contenido.
///
/// `update` devuelve `true` exactamente una vez — en el paso en que la duración
/// llega a cero — lo que facilita encadenar transiciones de fase.
///
/// Uso:
/// ```dart
/// final timer = GameTimer(duration: 1.5);
/// timer.start();
/// if (timer.update(delta)) { /* se alcanzó el final */ }
/// ```
library;

class GameTimer {
  GameTimer({double duration = 0.0}) : _duration = duration;

  double _duration;
  double _elapsed = 0.0;
  bool running = false;
  bool finished = false;

  /// Duración total del temporizador en segundos.
  double get duration => _duration;

  /// Segundos transcurridos desde el último `start()`.
  double get elapsed => _elapsed;

  /// Segundos restantes hasta el final (nunca por debajo de cero).
  double get remaining =>
      (_duration - _elapsed).clamp(0.0, double.infinity).toDouble();

  /// Fracción transcurrida en `[0.0, 1.0]`.
  double get progress {
    if (_duration <= 0.0) return 1.0;
    return (_elapsed / _duration).clamp(0.0, 1.0).toDouble();
  }

  /// Inicia (o reinicia) la cuenta, opcionalmente con una nueva duración.
  void start([double? duration]) {
    if (duration != null) _duration = duration;
    _elapsed = 0.0;
    running = true;
    finished = false;
  }

  /// Detiene la cuenta sin terminarla.
  void stop() {
    running = false;
  }

  /// Vuelve a cero: sin correr y sin terminar.
  void reset() {
    _elapsed = 0.0;
    running = false;
    finished = false;
  }

  /// Avanza `delta` segundos. Devuelve `true` exactamente una vez, en el paso
  /// en que la duración llega a cero. Las llamadas posteriores a terminar
  /// devuelven `false` hasta `start`/`reset`.
  bool update(double delta) {
    if (!running) return false;
    _elapsed += delta < 0.0 ? 0.0 : delta;
    if (_elapsed >= _duration) {
      _elapsed = _duration;
      running = false;
      finished = true;
      return true;
    }
    return false;
  }
}