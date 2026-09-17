import 'dart:ui';
import '../motor/entity.dart';
import '../motor/component.dart';
import '../motor/vector2.dart';
import '../motor/input_manager.dart';
import '../motor/motor_render_context.dart';

/// Entidad mínima de demostración: un cuadrado que camina izquierda/
/// derecha leyendo `move_left`/`move_right` del InputManager. Sirve solo
/// para verificar que el motor funciona de punta a punta (equivalente al
/// "Fighter representado temporalmente por una figura geométrica" que
/// pedía el prototipo original) — no es el Fighter real (eso es Etapa 3).
class DemoEntity extends Entity {
  static const double tamano = 32;
  static const double velocidad = 120.0;

  final Color color;

  DemoEntity({required double x, required double y, required this.color})
      : super(x: x, y: y) {
    addComponent(_MovimientoDemo());
    addComponent(_DibujoDemo());
  }
}

/// Componente de movimiento: traduce la entrada en velocidad horizontal y
/// mueve la posición en update(), igual que haría un PhysicsBody sencillo.
class _MovimientoDemo extends Component {
  @override
  void handleInput(InputManager inputManager) {
    final entidad = owner as DemoEntity?;
    if (entidad == null) return;

    final izquierda = inputManager.getAction('move_left');
    final derecha = inputManager.getAction('move_right');
    double direccion = 0.0;
    if (izquierda?.isPressed() ?? false) direccion -= 1.0;
    if (derecha?.isPressed() ?? false) direccion += 1.0;

    entidad.velocity = Vector2(direccion * DemoEntity.velocidad, 0.0);
  }

  @override
  void update(double delta) {
    final entidad = owner as DemoEntity?;
    if (entidad == null) return;
    entidad.position = entidad.position + entidad.velocity * delta;
  }
}

class _DibujoDemo extends Component {
  @override
  void render(MotorRenderContext renderer) {
    final entidad = owner as DemoEntity?;
    if (entidad == null) return;
    renderer.drawRect(
      entidad.position.x,
      entidad.position.y,
      DemoEntity.tamano,
      DemoEntity.tamano,
      entidad.color,
    );
  }
}
