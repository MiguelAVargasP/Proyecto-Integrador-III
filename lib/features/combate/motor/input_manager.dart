/// Acción lógica de entrada configurable (ej. "move_left", "attack_high").
/// Porte de `engine/input/input_action.py`, pero sin el concepto de
/// "tecla": en Android no hay teclado por defecto, así que en vez de
/// mapear teclas a la acción, los controles táctiles (Etapa 3: joystick
/// virtual + botones) llaman [press]/[release] directamente sobre la
/// acción. El resto de la superficie (`isPressed`, `isJustPressed`,
/// `isJustReleased`) se mantiene igual, así que `Fighter`/
/// `PlayerController` (Etapa 3) no necesitan saber si la entrada vino de
/// una tecla o de un botón en pantalla.
class InputAction {
  final String name;
  bool pressed = false;
  bool justPressed = false;
  bool justReleased = false;

  bool _pendingJustPressed = false;
  bool _pendingJustReleased = false;

  InputAction(this.name);

  void press() {
    if (!pressed) _pendingJustPressed = true;
    pressed = true;
  }

  void release() {
    if (pressed) _pendingJustReleased = true;
    pressed = false;
  }

  /// Refresca los pulsos "just_*" para el frame actual. Lo llama
  /// [InputManager.update] una vez por frame, igual que la versión Python
  /// limpiaba `_just_pressed`/`_just_released` al inicio de cada frame.
  void tick() {
    justPressed = _pendingJustPressed;
    justReleased = _pendingJustReleased;
    _pendingJustPressed = false;
    _pendingJustReleased = false;
  }

  bool isPressed() => pressed;
  bool isJustPressed() => justPressed;
  bool isJustReleased() => justReleased;

  @override
  String toString() => 'InputAction(name: $name, pressed: $pressed)';
}

/// Reemplazo de `engine/input/input_manager.py`. Registra el mismo
/// conjunto de acciones lógicas que la versión de teclado (mismos
/// nombres, para que el resto del motor no cambie), pero sin bindings de
/// teclas — los controles táctiles llaman `inputManager.press('jump')` /
/// `.release('jump')` directamente.
class InputManager {
  static const List<String> accionesPorDefecto = [
    'move_left', 'move_right', 'jump', 'crouch',
    'attack_high', 'attack_low', 'block',
    'skill_1', 'skill_2', 'skill_3', 'skill_4', 'skill_5',
    'super', 'pause',
  ];

  final Map<String, InputAction> _actions = {};

  InputManager() {
    for (final name in accionesPorDefecto) {
      _actions[name] = InputAction(name);
    }
  }

  InputAction? getAction(String name) => _actions[name];

  void press(String name) => _actions[name]?.press();
  void release(String name) => _actions[name]?.release();

  /// Se llama una vez por frame (al inicio de la fase INPUT del loop) para
  /// refrescar los pulsos "just_*" de todas las acciones.
  void update() {
    for (final action in _actions.values) {
      action.tick();
    }
  }
}
