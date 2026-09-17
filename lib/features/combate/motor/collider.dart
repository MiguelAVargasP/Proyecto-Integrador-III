import 'component.dart';
import 'rect.dart';

/// Rectángulo adjunto a una entidad mediante un desplazamiento (offset) y
/// un tamaño. Porte directo de `engine/physics/collider.py`.
class Collider extends Component {
  double width;
  double height;
  double offsetX;
  double offsetY;
  final String tag;
  bool enabled = true;

  Collider({
    this.width = 16.0,
    this.height = 16.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.tag = '',
  });

  /// Mueve el collider en relación al origen de su dueño.
  void setOffset(double newOffsetX, double newOffsetY) {
    offsetX = newOffsetX;
    offsetY = newOffsetY;
  }

  /// Rectángulo en espacio de mundo de este collider.
  Rect getRect() {
    final dueno = owner;
    if (dueno == null) {
      return Rect(offsetX, offsetY, width, height);
    }
    return Rect(
      dueno.position.x + offsetX,
      dueno.position.y + offsetY,
      width,
      height,
    );
  }
}
