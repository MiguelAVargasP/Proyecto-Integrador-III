import 'rect.dart';

/// Funciones puras de colisión entre rectángulos. Porte directo de
/// `engine/physics/collision.py`.

/// true cuando los rectángulos a y b se superponen.
bool aabbOverlap(Rect a, Rect b) => a.overlaps(b);

/// Rectángulo compartido entre a y b (rectángulo vacío si están separados).
Rect aabbIntersection(Rect a, Rect b) {
  final left = a.x > b.x ? a.x : b.x;
  final top = a.y > b.y ? a.y : b.y;
  final right = a.right < b.right ? a.right : b.right;
  final bottom = a.bottom < b.bottom ? a.bottom : b.bottom;
  final width = (right - left) > 0.0 ? (right - left) : 0.0;
  final height = (bottom - top) > 0.0 ? (bottom - top) : 0.0;
  return Rect(left, top, width, height);
}
