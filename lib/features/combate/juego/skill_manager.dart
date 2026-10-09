import 'card.dart';
import 'cooldown.dart';
import 'hand.dart';
import 'skill.dart';
import 'skill_data.dart';

const int skillSlotCount = 5;

/// Los cinco slots fijos de habilidad de un fighter. Porte directo de
/// `game/skills/skill_manager.py`.
///
/// Los slots 1..5 mapean 1:1 a las cinco cartas de la Hand repartida al
/// inicio del round. Cada slot tiene su propio SkillCooldownTracker, así
/// que los cooldowns son completamente independientes: usar la
/// habilidad 1 nunca bloquea las habilidades 2..5, y cada slot vuelve a
/// READY por su cuenta.
///
/// El manager es agnóstico de los efectos concretos — solo administra
/// disponibilidad, tiempos y contabilidad de slots para las habilidades
/// que se agreguen más adelante con contenido real.
class SkillManager {
  final Map<int, Skill> _skills = {};
  final Map<int, SkillCooldownTracker> _cooldowns = {};

  /// Coloca `skill` en `slot` (1..5), reiniciando su cooldown.
  Skill assignSlot(int slot, Skill skill) {
    _validateSlot(slot);
    _skills[slot] = skill;
    _cooldowns[slot] = skill.makeCooldown();
    return skill;
  }

  /// Reparte la mano en los slots a través del catálogo; devuelve los
  /// slots que quedaron llenos.
  List<int> loadHand(Hand hand, SkillCatalog catalog) {
    final filled = <int>[];
    for (int slot = 1; slot <= skillSlotCount; slot++) {
      final Card? card = hand.getCard(slot);
      if (card == null) continue;
      final skill = catalog.resolveCard(card);
      if (skill != null) {
        assignSlot(slot, skill);
        filled.add(slot);
      }
    }
    return filled;
  }

  /// Quita todas las habilidades (se usa cuando se reparte un round nuevo).
  void clear() {
    _skills.clear();
    _cooldowns.clear();
  }

  /// La habilidad en `slot` (null si el slot está vacío).
  Skill? getSkill(int slot) => _skills[slot];

  /// Activa la habilidad en `slot` cuando está READY; true si tuvo éxito.
  bool tryActivate(int slot) {
    final skill = _skills[slot];
    if (skill == null) return false;
    final cooldown = _cooldowns[slot];
    if (cooldown == null) return false;
    return cooldown.tryActivate();
  }

  /// Avanza el cooldown de cada slot en `delta` segundos.
  void update(double delta) {
    for (final cooldown in _cooldowns.values) {
      cooldown.update(delta);
    }
  }

  /// Fase actual de `slot`: READY, ACTIVE, COOLDOWN o EMPTY.
  String state(int slot) {
    final cooldown = _cooldowns[slot];
    if (cooldown == null) return 'EMPTY';
    return cooldown.state;
  }

  /// true cuando el slot tiene una habilidad en estado READY.
  bool isReady(int slot) {
    final cooldown = _cooldowns[slot];
    return cooldown != null && cooldown.isReady();
  }

  /// Segundos restantes de la fase ACTIVE (0 para slots vacíos/listos).
  double activeRemaining(int slot) => _cooldowns[slot]?.remaining() ?? 0.0;

  /// Segundos restantes de la fase COOLDOWN (0 si está listo o vacío).
  double cooldownRemaining(int slot) {
    final cooldown = _cooldowns[slot];
    if (cooldown == null || cooldown.state != skillCooldown) return 0.0;
    return cooldown.remaining();
  }

  /// Los slots que actualmente tienen una habilidad, en orden ascendente.
  List<int> filledSlots() => _skills.keys.toList()..sort();

  int get length => _skills.length;

  /// Itera como (slot, skill, cooldown) para cada slot lleno.
  Iterable<(int, Skill, SkillCooldownTracker)> entries() sync* {
    for (final slot in filledSlots()) {
      yield (slot, _skills[slot]!, _cooldowns[slot]!);
    }
  }

  static void _validateSlot(int slot) {
    if (slot < 1 || slot > skillSlotCount) {
      throw ArgumentError('el slot de habilidad debe estar entre 1 y $skillSlotCount, se dio $slot');
    }
  }
}
