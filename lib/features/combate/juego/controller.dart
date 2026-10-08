import 'dart:math';
import '../motor/input_manager.dart';
import 'fighter.dart';
import 'fighter_state.dart' as estados;

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

/// Un controller que nunca actúa — se deja como referencia de "sin
/// oponente real" (p. ej. para una futura escena puramente de
/// entrenamiento), pero el muñeco de práctica del parcial ya usa
/// [AIController] en su lugar.
class DummyController extends Controller {}

/// IA básica para el oponente del parcial: se acerca cuando está lejos, y
/// cuando está a rango ataca, bloquea o se mantiene quieto al azar, con
/// un pequeño tiempo de reacción entre decisiones (para que no se sienta
/// sobrehumano — un jugador real tampoco decide 60 veces por segundo).
///
/// `yo` se asigna DESPUÉS de construir el Fighter dueño de este
/// controller, porque el Fighter todavía no existe cuando se arma el
/// controller (ver `CombatArenaScene`). Mientras `yo` sea null, la IA no
/// actúa — así nunca se cae si algo la usa antes de completar esa
/// conexión.
class AIController extends Controller {
  Fighter? yo;
  final Fighter objetivo;
  final Random _rng;

  /// Distancia (en el mismo espacio lógico que `Fighter.position`) por
  /// debajo de la cual la IA deja de acercarse y empieza a decidir entre
  /// atacar/bloquear/esperar.
  final double rangoDeAtaque;

  AIController({
    required this.objetivo,
    this.rangoDeAtaque = 34.0,
    Random? rng,
  }) : _rng = rng ?? Random();

  double _tiempoHastaProximaDecision = 0.0;
  int _direccionActual = 0;
  bool _pulsoAtacarAlto = false;
  bool _pulsoAtacarBajo = false;

  /// Bajo este umbral de vida, la IA se vuelve "desesperada": decide más
  /// rápido y ataca con más frecuencia.
  static const double _umbralDesesperado = 0.3;

  @override
  void update(double delta) {
    _tiempoHastaProximaDecision -= delta;
    if (_tiempoHastaProximaDecision > 0.0) return;
    _tomarDecision();

    final desesperado = (yo?.healthRatio() ?? 1.0) < _umbralDesesperado;
    // Tiempo de reacción aleatorio: normal entre 0.15s y 0.45s; desesperado
    // (poca vida) entre 0.10s y 0.25s — decide más rápido, no solo ataca
    // más seguido.
    _tiempoHastaProximaDecision = desesperado
        ? 0.10 + _rng.nextDouble() * 0.15
        : 0.15 + _rng.nextDouble() * 0.30;
  }

  void _tomarDecision() {
    _pulsoAtacarAlto = false;
    _pulsoAtacarBajo = false;

    final propio = yo;
    if (propio == null || !propio.alive || !objetivo.alive) {
      _direccionActual = 0;
      return;
    }

    final distancia = (objetivo.position.x - propio.position.x).abs();
    if (distancia > rangoDeAtaque) {
      // Lejos: acercarse.
      _direccionActual = objetivo.position.x >= propio.position.x ? 1 : -1;
      return;
    }

    _direccionActual = 0;

    // No atacar si el oponente ya está en medio de un golpe — evita
    // intercambios automáticos sin sentido; es más interesante que la IA
    // "espere" un instante a que termine, en vez de chocar golpes a
    // ciegas todo el tiempo.
    final estadoOponente = objetivo.sm.getName();
    if (estadoOponente == estados.attackHigh || estadoOponente == estados.attackLow) {
      return;
    }

    // A rango: decide entre atacar (alto o bajo) o quedarse quieto un
    // instante — sin bloqueo (ver nota anterior sobre por qué se quitó).
    // Con poca vida, sube la probabilidad total de atacar.
    final desesperado = propio.healthRatio() < _umbralDesesperado;
    final probAtacarAlto = desesperado ? 0.60 : 0.50;
    final probAtacarBajo = desesperado ? 0.35 : 0.35;

    final opcion = _rng.nextDouble();
    if (opcion < probAtacarAlto) {
      _pulsoAtacarAlto = true;
    } else if (opcion < probAtacarAlto + probAtacarBajo) {
      _pulsoAtacarBajo = true;
    }
    // El resto: no hace nada este turno de decisión.
  }

  @override
  int moveDir() => _direccionActual;

  @override
  bool wantsAttackHigh() {
    if (!_pulsoAtacarAlto) return false;
    _pulsoAtacarAlto = false; // pulso de un solo frame, igual que isJustPressed
    return true;
  }

  @override
  bool wantsAttackLow() {
    if (!_pulsoAtacarBajo) return false;
    _pulsoAtacarBajo = false;
    return true;
  }
}