import '../motor/timer.dart';

/// Ciclo READY -> ACTIVE -> COOLDOWN -> READY de una habilidad. Porte
/// directo de `game/skills/cooldown.py`.
///
/// Cada habilidad tiene su propia instancia de SkillCooldownTracker, así
/// que activar la habilidad 1 no bloquea de ninguna forma las
/// habilidades 2..5 y viceversa. El ciclo siempre vuelve a READY, porque
/// las habilidades no se consumen: se pueden usar cualquier cantidad de
/// veces durante un round.
const String skillReady = 'READY';
const String skillActive = 'ACTIVE';
const String skillCooldown = 'COOLDOWN';

class SkillCooldownTracker {
  double activeTime;
  double cooldownTime;
  String state = skillReady;
  final Timer _timer = Timer();

  SkillCooldownTracker({this.activeTime = 0.25, this.cooldownTime = 1.0});

  /// Empieza la fase activa; devuelve false si la habilidad no está READY.
  bool tryActivate() {
    if (state != skillReady) return false;
    state = skillActive;
    _timer.start(activeTime);
    return true;
  }

  /// Avanza la fase actual, encadenando si se cruza una transición.
  ///
  /// Una sola llamada a `update` puede cruzar varias transiciones: el
  /// delta restante se reaplica a la siguiente fase hasta agotarse o
  /// hasta que la habilidad vuelva a READY. Un pequeño épsilon absorbe
  /// ruido de punto flotante para que un ciclo de dos fases (ej. 0.2 +
  /// 0.4 == 0.6) se complete en un solo update.
  void update(double delta) {
    double restante = delta < 0.0 ? 0.0 : delta;
    while (restante > 0.0 && (state == skillActive || state == skillCooldown)) {
      final quedaEnFase = _timer.remaining;
      if (restante < quedaEnFase - 1e-9) {
        _timer.update(restante);
        return;
      }
      restante = restante - quedaEnFase;
      if (restante < 0.0) restante = 0.0;
      if (state == skillActive) {
        state = skillCooldown;
        _timer.start(cooldownTime);
      } else {
        state = skillReady;
        _timer.reset();
      }
    }
  }

  bool isReady() => state == skillReady;
  bool isActive() => state == skillActive;
  bool inCooldown() => state == skillCooldown;

  /// Segundos restantes de la fase actual (0 cuando está READY).
  double remaining() => state == skillReady ? 0.0 : _timer.remaining;

  /// Progreso transcurrido de la fase actual, entre 0.0 y 1.0.
  double progress() => state == skillReady ? 1.0 : _timer.progress;

  @override
  String toString() => 'SkillCooldownTracker(state: $state, remaining: ${remaining()})';
}
