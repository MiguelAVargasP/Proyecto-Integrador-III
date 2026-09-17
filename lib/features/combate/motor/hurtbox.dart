import 'collider.dart';

/// Collider que marca una zona vulnerable del fighter — recibe daño de
/// los hitbox enemigos. Porte directo de `engine/physics/hurtbox.py`.
class Hurtbox extends Collider {
  Hurtbox({
    super.width = 16.0,
    super.height = 16.0,
    super.offsetX = 0.0,
    super.offsetY = 0.0,
    super.tag = 'hurtbox',
  });
}
