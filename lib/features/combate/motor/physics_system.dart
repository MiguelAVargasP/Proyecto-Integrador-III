import 'entity.dart';
import 'physics_body.dart';

/// Límites de movimiento horizontal: (x, y, ancho, alto).
class Bounds {
  final double x, y, width, height;
  const Bounds(this.x, this.y, this.width, this.height);
}

/// Sistema de físicas 2D simple para un prototipo de juego de peleas:
/// gravedad, velocidad horizontal/vertical, soporte de salto (a través de
/// la velocidad vertical) y colisión con el suelo. Porte directo de
/// `engine/physics/physics_system.py`.
///
/// El sistema es genérico del motor: nunca sabe nada de cartas, fighters
/// ni escenarios.
class PhysicsSystem {
  double gravity;
  double? floorY;
  Bounds? bounds;

  PhysicsSystem({this.gravity = 275.0});

  /// Define la coordenada y (espacio de mundo) de la superficie del suelo.
  void setFloorY(double y) => floorY = y;

  /// Restringe el movimiento horizontal al rectángulo de mundo dado.
  void setBounds(double x, double y, double width, double height) {
    bounds = Bounds(x, y, width, height);
  }

  /// Avanza la física de cada entidad activa que tenga un PhysicsBody.
  void update(double delta, Iterable<Entity> entities) {
    for (final entity in entities) {
      if (!entity.active) continue;
      final body = entity.getComponent<PhysicsBody>();
      if (body == null) continue;
      _applyGravity(entity, body, delta);
      _integrate(entity, delta);
      _resolveFloor(entity, body);
      _clampHorizontal(entity, body);
    }
  }

  void _applyGravity(Entity entity, PhysicsBody body, double delta) {
    entity.velocity = entity.velocity.copyWith(
      y: entity.velocity.y + gravity * body.gravityScale * delta,
    );
  }

  void _integrate(Entity entity, double delta) {
    entity.position = entity.position + entity.velocity * delta;
  }

  /// Detiene la entidad en el suelo si lo alcanza mientras cae.
  void _resolveFloor(Entity entity, PhysicsBody body) {
    final piso = floorY;
    if (piso == null) {
      body.grounded = false;
      return;
    }
    final bottom = entity.position.y + body.height;
    if (entity.velocity.y >= 0.0 && bottom >= piso) {
      entity.position = entity.position.copyWith(y: piso - body.height);
      entity.velocity = entity.velocity.copyWith(y: 0.0);
      body.grounded = true;
    } else {
      body.grounded = false;
    }
  }

  /// Mantiene a la entidad dentro de los límites de mundo (solo X, por ahora).
  void _clampHorizontal(Entity entity, PhysicsBody body) {
    final limites = bounds;
    if (limites == null) return;
    final minX = limites.x;
    final maxX = limites.x + limites.width - body.width;
    double x = entity.position.x;
    if (x < minX) x = minX;
    if (x > maxX) x = maxX;
    entity.position = entity.position.copyWith(x: x);
  }
}
