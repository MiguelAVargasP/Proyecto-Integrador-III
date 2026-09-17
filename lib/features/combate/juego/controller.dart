import '../motor/input_manager.dart';

/// Fuente de intenciones para un fighter (por defecto, "sin entrada").
/// Porte directo de `Controller` en Python.
class Controller {
  int moveDir() => 0;
  bool wantsJump() => false;
  bool wantsCrouch() => false;
  bool wantsBlock() => false;
  bool wantsAttackHigh() => false;
  bool wantsAttackLow() => false;

  /// true cuando la habilidad en `slot` (base 1) debería activarse.
  bool wantsSkill(int slot) => false;

  /// true cuando la superhabilidad debería activarse.
  bool wantsSuper() => false;

  /// Hook opcional por frame (usado por bucles de decisión de IA).
  void update(double delta) {}
}

/// Lee las intenciones desde el InputManager del motor usando nombres de
/// acción lógicos. Porte directo de `PlayerController`.
///
/// A diferencia del original (que leía teclas WASD/JKL), aquí el
/// `InputManager` recibe sus pulsos de botones táctiles en pantalla (ver
/// `combate/pantallas/`), pero como ambos exponen la misma interfaz de
/// `InputAction` (isPressed/isJustPressed), este controller no necesita
/// saber de dónde vino la entrada — se porta sin cambios de lógica.
class PlayerController extends Controller {
  final InputManager inputManager;
  PlayerController(this.inputManager);

  InputAction? _action(String name) => inputManager.getAction(name);

  @override
  int moveDir() {
    final left = _action('move_left');
    final right = _action('move_right');
    int direction = 0;
    if (left?.isPressed() ?? false) direction -= 1;
    if (right?.isPressed() ?? false) direction += 1;
    return direction;
  }

  @override
  bool wantsJump() => _action('jump')?.isJustPressed() ?? false;

  @override
  bool wantsCrouch() => _action('crouch')?.isPressed() ?? false;

  @override
  bool wantsBlock() => _action('block')?.isPressed() ?? false;

  @override
  bool wantsAttackHigh() => _action('attack_high')?.isJustPressed() ?? false;

  @override
  bool wantsAttackLow() => _action('attack_low')?.isJustPressed() ?? false;

  @override
  bool wantsSkill(int slot) => _action('skill_$slot')?.isJustPressed() ?? false;

  @override
  bool wantsSuper() => _action('super')?.isJustPressed() ?? false;
}

/// Un controller que nunca actúa (el muñeco de práctica).
class DummyController extends Controller {}
