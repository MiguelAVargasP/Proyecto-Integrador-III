import 'entity.dart';
import 'hitbox.dart';
import 'hurtbox.dart';

/// Unidad de combate genérica (vida, hurtboxes, hitboxes). Porte directo
/// de `engine/combat/combat_entity.py`.
///
/// Las subclases deciden cómo reciben golpes (estados del fighter,
/// bloqueo, KO) implementando [receiveHit].
class CombatEntity extends Entity {
  final double maxHealth;
  double health;
  bool alive = true;
  final List<Hurtbox> hurtboxes = [];
  final List<Hitbox> hitboxes = [];

  CombatEntity({super.x = 0.0, super.y = 0.0, this.maxHealth = 100.0})
      : health = maxHealth;

  /// Registra una zona vulnerable en esta entidad.
  Hurtbox addHurtbox(Hurtbox hurtbox) {
    hurtboxes.add(hurtbox);
    addComponent(hurtbox);
    return hurtbox;
  }

  /// Registra una zona ofensiva en esta entidad.
  Hitbox addHitbox(Hitbox hitbox) {
    hitboxes.add(hitbox);
    addComponent(hitbox);
    return hitbox;
  }

  /// Todos los hitbox habilitados (usables durante los frames activos de
  /// un ataque).
  List<Hitbox> getActiveHitboxes() =>
      hitboxes.where((h) => h.enabled).toList();

  /// Vida como fracción entre 0.0 y 1.0.
  double healthRatio() {
    if (maxHealth <= 0.0) return 0.0;
    final r = health / maxHealth;
    return r < 0.0 ? 0.0 : (r > 1.0 ? 1.0 : r);
  }

  /// Aplica un golpe entregado por el sistema de daño. Devuelve true si
  /// conectó. Las subclases deben implementar esto (equivalente al
  /// `raise NotImplementedError` de Python).
  bool receiveHit(Hitbox hitbox, Entity attacker) {
    throw UnimplementedError(
        'Las subclases de CombatEntity deben implementar receiveHit()');
  }
}
