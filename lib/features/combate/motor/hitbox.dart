import 'collider.dart';
import 'vector2.dart';

/// Collider ofensivo: la zona que causa daño. Porte directo de
/// `engine/physics/hitbox.py`.
class Hitbox extends Collider {
  double damage;
  double hitstun;
  Vector2 knockback;
  bool hasConnected = false;

  Hitbox({
    super.width = 16.0,
    super.height = 16.0,
    super.offsetX = 0.0,
    super.offsetY = 0.0,
    this.damage = 1.0,
    this.hitstun = 0.15,
    double knockbackX = 20.0,
    double knockbackY = 0.0,
    super.tag = 'hitbox',
  }) : knockback = Vector2(knockbackX, knockbackY);

  /// Habilita este hitbox y vuelve a permitir una sola conexión.
  void arm() {
    enabled = true;
    hasConnected = false;
  }

  /// Deshabilita el hitbox para que deje de causar daño.
  void disarm() {
    enabled = false;
  }

  /// Sobrescribe los valores de daño que lleva este hitbox. Cualquier
  /// parámetro que se deje en null conserva su valor actual.
  void applyData({
    double? damage,
    double? hitstun,
    double? knockbackX,
    double? knockbackY,
  }) {
    if (damage != null) this.damage = damage;
    if (hitstun != null) this.hitstun = hitstun;
    if (knockbackX != null || knockbackY != null) {
      knockback = knockback.copyWith(x: knockbackX, y: knockbackY);
    }
  }
}
