import 'dart:math' as math;

/// Vector 2D propio del motor de combate. Igual que en la versión Python
/// original, se define aquí (no se reutiliza `Offset` de Flutter) para que
/// la lógica del motor no dependa de un tipo específico de la capa de
/// presentación — así el motor sigue siendo independiente de cómo se
/// termine dibujando.
class Vector2 {
  final double x;
  final double y;

  const Vector2([this.x = 0.0, this.y = 0.0]);

  Vector2 operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  Vector2 operator *(double scalar) => Vector2(x * scalar, y * scalar);
  Vector2 operator /(double scalar) => Vector2(x / scalar, y / scalar);
  Vector2 operator -() => Vector2(-x, -y);

  @override
  bool operator ==(Object other) =>
      other is Vector2 && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Vector2(x: $x, y: $y)';

  Vector2 copy() => Vector2(x, y);

  /// Devuelve una copia con `x` y/o `y` reemplazados. Como este Vector2 es
  /// inmutable (a diferencia del original en Python, que sí permitía
  /// `vector.y += ...` directamente), este es el equivalente idiomático en
  /// Dart: en vez de mutar en el sitio, el código llamador reasigna
  /// `entidad.velocity = entidad.velocity.copyWith(y: nuevoY)`.
  Vector2 copyWith({double? x, double? y}) =>
      Vector2(x ?? this.x, y ?? this.y);

  double lengthSquared() => x * x + y * y;

  double length() => math.sqrt(lengthSquared());

  /// Vector unitario en la misma dirección (el vector cero se queda en cero).
  Vector2 normalize() {
    final l = length();
    if (l == 0.0) return const Vector2();
    return Vector2(x / l, y / l);
  }
}
