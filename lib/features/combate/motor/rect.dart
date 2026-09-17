/// Rectángulo alineado a los ejes, usado por el sistema de colisiones.
/// Porte directo de `engine/physics/rect.py` — no depende de ningún tipo
/// de Flutter para que el motor de colisiones se pueda probar de forma
/// aislada, igual que en la versión Python.
class Rect {
  final double x;
  final double y;
  final double width;
  final double height;

  const Rect([this.x = 0.0, this.y = 0.0, this.width = 0.0, this.height = 0.0]);

  double get right => x + width;
  double get bottom => y + height;

  /// true si los dos rectángulos se superponen (bordes estrictos).
  bool overlaps(Rect other) {
    if (width <= 0.0 || height <= 0.0) return false;
    if (other.width <= 0.0 || other.height <= 0.0) return false;
    return x < other.right && other.x < right && y < other.bottom && other.y < bottom;
  }

  Rect translate(double dx, double dy) => Rect(x + dx, y + dy, width, height);

  @override
  bool operator ==(Object other) =>
      other is Rect &&
      x == other.x &&
      y == other.y &&
      width == other.width &&
      height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'Rect(x: $x, y: $y, width: $width, height: $height)';
}
