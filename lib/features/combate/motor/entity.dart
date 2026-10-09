import 'component.dart';
import 'vector2.dart';
import 'motor_render_context.dart';
import 'input_manager.dart';

/// Entidad genérica que vive en el mundo del juego. Porte directo de
/// `engine/core/entity.py`. Delega su ciclo de vida (input/update/render)
/// a sus componentes para que ninguna clase crezca hasta ser un monolito.
class Entity {
  Vector2 position;
  Vector2 velocity;
  bool active;
  final List<Component> components = [];

  Entity({double x = 0.0, double y = 0.0, this.active = true})
      : position = Vector2(x, y),
        velocity = const Vector2();

  /// Adjunta un componente a esta entidad y lo devuelve.
  Component addComponent(Component component) {
    component.attach(this);
    components.add(component);
    return component;
  }

  /// Devuelve el primer componente del tipo [T], o null si no hay ninguno.
  T? getComponent<T extends Component>() {
    for (final component in components) {
      if (component is T) return component;
    }
    return null;
  }

  void removeComponent(Component component) {
    if (components.remove(component)) {
      component.attach(null);
    }
  }

  void handleInput(InputManager inputManager) {
    if (!active) return;
    for (final component in components) {
      component.handleInput(inputManager);
    }
  }

  void update(double delta) {
    if (!active) return;
    for (final component in components) {
      component.update(delta);
    }
  }

  void render(MotorRenderContext renderer) {
    if (!active) return;
    for (final component in components) {
      component.render(renderer);
    }
  }
}
