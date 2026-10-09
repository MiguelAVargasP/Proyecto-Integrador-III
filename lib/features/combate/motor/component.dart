import 'entity.dart';
import 'motor_render_context.dart';
import 'input_manager.dart';

/// Clase base para el comportamiento composable adjunto a una [Entity].
/// Porte directo de `engine/core/component.py`. El motor prefiere
/// composición sobre clases gigantes permisivas (ver [Entity]).
abstract class Component {
  Entity? owner;

  /// Vincula este componente a su entidad dueña (null lo desvincula).
  void attach(Entity? newOwner) {
    owner = newOwner;
  }

  /// Procesa la entrada relevante para este componente (hook opcional).
  void handleInput(InputManager inputManager) {}

  /// Avanza el componente `delta` segundos (hook opcional).
  void update(double delta) {}

  /// Dibuja el componente a través del contexto de render (hook opcional).
  void render(MotorRenderContext renderer) {}
}
