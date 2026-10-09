import '../motor/combat_entity.dart';
import '../motor/collision.dart';

/// Resuelve las superposiciones entre hitbox y hurtbox en cada frame.
/// Porte directo de `game/combat/damage_system.py`.
///
/// Un hitbox solo conecta una vez por ataque (`hasConnected`), lo que
/// evita que un solo movimiento drene al defensor durante varios frames.
class DamageSystem {
  /// Resuelve todos los golpes pendientes; devuelve cuántos conectaron.
  int resolve(Iterable<CombatEntity> attackers, Iterable<CombatEntity> defenders) {
    int landed = 0;
    for (final attacker in attackers) {
      if (!attacker.alive) continue;
      for (final hitbox in attacker.getActiveHitboxes()) {
        if (hitbox.hasConnected) continue;
        for (final defender in defenders) {
          if (identical(defender, attacker) || !defender.alive) continue;
          for (final hurtbox in defender.hurtboxes) {
            if (!hurtbox.enabled) continue;
            if (aabbOverlap(hitbox.getRect(), hurtbox.getRect())) {
              if (defender.receiveHit(hitbox, attacker)) {
                hitbox.hasConnected = true;
                landed += 1;
              }
              break;
            }
          }
        }
      }
    }
    return landed;
  }
}
