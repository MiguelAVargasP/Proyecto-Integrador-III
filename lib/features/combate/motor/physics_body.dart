import 'component.dart';

/// Huella física y banderas de movimiento de una entidad. El sistema de
/// físicas opera sobre entidades que tienen un PhysicsBody adjunto. Porte
/// directo de `engine/physics/physics_body.py`.
class PhysicsBody extends Component {
  double width;
  double height;
  double gravityScale;
  bool grounded = false;

  PhysicsBody({
    this.width = 16.0,
    this.height = 16.0,
    this.gravityScale = 1.0,
  });
}
