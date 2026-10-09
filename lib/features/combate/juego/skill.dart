import 'cooldown.dart';

/// Tipos genéricos de habilidad usados por los datos del catálogo. Se
/// pueden agregar tipos nuevos libremente.
const String kindStrike = 'strike';
const String kindProjectile = 'projectile';
const String kindDash = 'dash';
const String kindBuff = 'buff';
const String kindCounter = 'counter';

/// Una habilidad universal ligada a una carta de la baraja francesa.
///
/// Cada carta de la baraja representa la misma habilidad para todos los
/// personajes, así que una Skill nunca depende del fighter que la usa.
/// Esta clase solo lleva la definición estática (id, nombre, tipo,
/// tiempos); el estado dinámico disponible/activo/cooldown vive en
/// [SkillCooldownTracker] y lo administra el SkillManager.
///
/// Los efectos concretos (qué hace la habilidad de verdad en una pelea)
/// TODAVÍA no se definen aquí — eso corresponde a una etapa posterior de
/// contenido. Porte directo de `game/skills/skill.py`.
class Skill {
  final String skillId;
  final String name;
  final String kind;
  final double activeTime;
  final double cooldownTime;
  final Map<String, dynamic> meta;

  Skill(this.skillId, [Map<String, dynamic>? data])
      : name = (data?['name'] as String?) ?? skillId,
        kind = (data?['kind'] as String?) ?? kindStrike,
        activeTime = (data?['active_time'] as num?)?.toDouble() ?? 0.25,
        cooldownTime = (data?['cooldown'] as num?)?.toDouble() ?? 1.0,
        meta = Map<String, dynamic>.from(
            (data?['meta'] as Map<String, dynamic>?) ?? {});

  /// Crea un rastreador de cooldown nuevo para esta habilidad (uno por slot).
  SkillCooldownTracker makeCooldown() =>
      SkillCooldownTracker(activeTime: activeTime, cooldownTime: cooldownTime);

  /// Punto de extensión donde caen los efectos concretos (no hace nada
  /// todavía — contenido de una etapa posterior).
  dynamic effect(dynamic owner, [dynamic opponent]) => null;

  @override
  String toString() =>
      'Skill(id: $skillId, name: $name, kind: $kind, active: $activeTime, cooldown: $cooldownTime)';
}
