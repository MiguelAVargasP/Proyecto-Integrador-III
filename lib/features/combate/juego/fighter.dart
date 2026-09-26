import 'dart:ui';
import '../motor/combat_entity.dart';
import '../motor/component.dart';
import '../motor/entity.dart';
import '../motor/hitbox.dart';
import '../motor/hurtbox.dart';
import '../motor/input_manager.dart';
import '../motor/motor_render_context.dart';
import '../motor/physics_body.dart';
import '../motor/state_machine.dart';
import 'controller.dart';
import 'fighter_state.dart' as estados;
import 'skill_manager.dart';
import 'super_manager.dart';

/// Postura de pie / agachado: (offsetX, offsetY, ancho, alto) por zona.
const Map<String, List<double>> _standingStance = {
  'body': [0.0, 4.0, 24.0, 28.0],
  'head': [0.0, -2.0, 18.0, 8.0],
};
const Map<String, List<double>> _crouchingStance = {
  'body': [0.0, 14.0, 24.0, 18.0],
  'head': [0.0, 6.0, 18.0, 10.0],
};

/// Aclara/oscurece un color (factor 1.0 lo deja igual). Porte de `_shade`.
///
/// Usa los componentes nuevos de Color (`.a/.r/.g/.b`, doubles 0.0-1.0) en
/// vez de los enteros 0-255 (`color.red` etc.), que quedaron obsoletos.
Color _shade(Color color, double factor) {
  double clamp01(double v) => v < 0.0 ? 0.0 : (v > 1.0 ? 1.0 : v);
  return Color.from(
    alpha: color.a,
    red: clamp01(color.r * factor),
    green: clamp01(color.g * factor),
    blue: clamp01(color.b * factor),
  );
}

/// Una unidad de combate controlada por un [Controller]. Porte directo de
/// `game/fighters/fighter.py`.
///
/// NOTA: a diferencia del original, este puerto todavía NO conecta
/// `SkillManager` ni `SuperManager` (eso corresponde a las etapas 5/6 del
/// plan de puertos) — las 5 habilidades normales y la superhabilidad
/// llegan después. Por ahora el Fighter cubre exactamente el alcance de
/// la Etapa 4 original: estados, movimiento, ataque alto/bajo, hitbox/
/// hurtbox y recepción de daño.
class Fighter extends CombatEntity {
  String name;
  Controller controller;
  final Color baseColor;
  int facing;

  late final PhysicsBody physicsBody;
  late final Hurtbox bodyHurtbox;
  late final Hurtbox headHurtbox;
  late final Hitbox attackHitbox;

  final Map<String, Map<String, dynamic>> attacks = {};

  double moveSpeed = 80.0;
  double jumpVelocity = -150.0;

  // Intenciones del frame actual (se leen del controller en handleInput).
  int _intentDir = 0;
  bool _intentJump = false;
  bool _intentCrouch = false;
  bool _intentBlock = false;
  bool _intentAttackHigh = false;
  bool _intentAttackLow = false;

  // Progreso del ataque actual.
  String attackName = '';
  Map<String, dynamic> attackData = {};
  String attackPhase = '';
  double hitstunRestante = 0.0;
  double stateTime = 0.0;

  Color currentColor;
  late final StateMachine sm;

  /// Etapa 5: los cinco slots de habilidad del fighter. Empieza vacío —
  /// se llena con `skillManager.loadHand(hand, catalog)` cuando exista
  /// una mano real repartida (Etapa 6/7, cuando se conecte el flujo de
  /// cartas de round). Mientras tanto, `controller.wantsSkill(slot)` ya
  /// intenta activar el slot correspondiente, pero como no hay
  /// habilidades asignadas, `tryActivate` simplemente no hace nada
  /// (comportamiento correcto, no es un bug).
  final SkillManager skillManager = SkillManager();

  /// Etapa 6: la superhabilidad, derivada de la combinación de poker de
  /// la mano del fighter (no de una carta individual). Igual que
  /// `skillManager`, empieza sin mano cargada — `superManager.loadHand`
  /// se llama cuando exista una mano real repartida (Etapa 7). Mientras
  /// tanto, `controller.wantsSuper()` ya intenta activarla, pero sin
  /// mano cargada `tryActivate` no hace nada (comportamiento correcto).
  final SuperManager superManager = SuperManager();

  Fighter({
    required double x,
    required double y,
    required this.controller,
    Color color = const Color(0xFF78A0C8), // (120,160,200)
    int facingInicial = 1,
    double maxHealth = 100.0,
    this.name = 'Fighter',
  })  : baseColor = color,
        currentColor = color,
        facing = facingInicial >= 0 ? 1 : -1,
        super(x: x, y: y, maxHealth: maxHealth) {
    physicsBody = addComponent(PhysicsBody(width: 24.0, height: 32.0)) as PhysicsBody;

    bodyHurtbox = addHurtbox(Hurtbox(
      width: _standingStance['body']![2],
      height: _standingStance['body']![3],
      offsetX: _standingStance['body']![0],
      offsetY: _standingStance['body']![1],
      tag: 'body',
    ));
    headHurtbox = addHurtbox(Hurtbox(
      width: _standingStance['head']![2],
      height: _standingStance['head']![3],
      offsetX: _standingStance['head']![0],
      offsetY: _standingStance['head']![1],
      tag: 'head',
    ));

    attackHitbox = addHitbox(Hitbox(
      width: 1,
      height: 1,
      offsetX: 0,
      offsetY: 0,
      damage: 10,
      tag: 'attack',
    ));
    attackHitbox.disarm();

    attacks[estados.attackHigh] = {
      'startup': 0.06, 'active': 0.05, 'recovery': 0.10,
      'damage': 10.0, 'hitstun': 0.25, 'knockback_x': 40.0,
      'hbox': {'width': 20.0, 'height': 8.0, 'ox': 6.0, 'oy': -4.0},
    };
    attacks[estados.attackLow] = {
      'startup': 0.07, 'active': 0.06, 'recovery': 0.12,
      'damage': 8.0, 'hitstun': 0.22, 'knockback_x': 30.0,
      'hbox': {'width': 22.0, 'height': 10.0, 'ox': 12.0, 'oy': 16.0},
    };

    addComponent(_FighterRenderComponent());

    sm = StateMachine(this);
    for (final estado in estados.buildStandardStates()) {
      sm.register(estado);
    }
    sm.start(estados.idle);
    _applyStance();
    _applyVisual();
  }

  // -------------------------------------------------------------- input
  @override
  void handleInput(InputManager inputManager) {
    _intentDir = controller.moveDir();
    _intentJump = controller.wantsJump();
    _intentCrouch = controller.wantsCrouch();
    _intentBlock = controller.wantsBlock();
    _intentAttackHigh = controller.wantsAttackHigh();
    _intentAttackLow = controller.wantsAttackLow();

    for (int slot = 1; slot <= skillSlotCount; slot++) {
      if (controller.wantsSkill(slot)) {
        skillManager.tryActivate(slot);
      }
    }
    if (controller.wantsSuper()) {
      superManager.tryActivate();
    }
  }

  // ------------------------------------------------------------- update
  @override
  void update(double delta) {
    super.update(delta);
    if (!alive) return;
    controller.update(delta);
    sm.update(delta);
    skillManager.update(delta);
    superManager.update(delta);
  }

  /// Llamado por [estados.FighterState.update] vía invocación dinámica.
  void stateUpdate(double delta) {
    stateTime += delta;
    final estado = sm.getName();
    if (estado == estados.attackHigh || estado == estados.attackLow) {
      _updateAttack();
    } else if (estado == estados.hit) {
      _updateHit();
    } else if (estados.airStates.contains(estado)) {
      _updateAirborne();
    } else if ([estados.idle, estados.walk, estados.crouch, estados.block]
        .contains(estado)) {
      _applyGroundControls();
    }
  }

  /// Se llama tras el paso de físicas: resuelve el aterrizaje desde el aire.
  void onPhysicsResolved() {
    if (sm.isCurrent(estados.jump) || sm.isCurrent(estados.fall)) {
      if (physicsBody.grounded) {
        _changeState(estados.idle);
      }
    }
  }

  // ----------------------------------------------------------- movement
  void _applyGroundControls() {
    final estado = sm.getName();
    final direccion = _intentDir;

    if (_intentAttackHigh) {
      _startAttack(estados.attackHigh);
      return;
    }
    if (_intentAttackLow) {
      _startAttack(estados.attackLow);
      return;
    }
    if (_intentJump) {
      velocity = velocity.copyWith(y: jumpVelocity);
      _changeState(estados.jump);
      return;
    }
    if (_intentCrouch) {
      _changeState(estados.crouch);
      velocity = velocity.copyWith(x: 0.0);
      return;
    }
    if (_intentBlock) {
      _changeState(estados.block);
      velocity = velocity.copyWith(x: 0.0);
      return;
    }

    if (direccion != 0) {
      facing = direccion;
      _changeState(estados.walk);
      velocity = velocity.copyWith(x: direccion * moveSpeed);
    } else if ([estados.walk, estados.block, estados.crouch].contains(estado)) {
      _changeState(estados.idle);
      velocity = velocity.copyWith(x: 0.0);
    } else {
      velocity = velocity.copyWith(x: 0.0);
    }
  }

  void _updateAirborne() {
    final direccion = _intentDir;
    if (direccion != 0) facing = direccion;
    velocity = velocity.copyWith(x: direccion * moveSpeed * 0.75);
  }

  // ------------------------------------------------------------ attacks
  void _startAttack(String nombreAtaque) {
    final data = attacks[nombreAtaque]!;
    attackName = nombreAtaque;
    attackData = data;
    attackPhase = 'startup';
    stateTime = 0.0;
    velocity = velocity.copyWith(x: 0.0);
    sm.change(nombreAtaque);
    _applyVisual();
  }

  void _updateAttack() {
    final data = attackData;
    if (attackPhase == 'startup' && stateTime >= (data['startup'] as double)) {
      attackPhase = 'active';
      stateTime = 0.0;
      _armAttackHitbox();
    } else if (attackPhase == 'active' && stateTime >= (data['active'] as double)) {
      attackPhase = 'recovery';
      stateTime = 0.0;
      attackHitbox.disarm();
    } else if (attackPhase == 'recovery' && stateTime >= (data['recovery'] as double)) {
      attackHitbox.disarm();
      _changeState(estados.idle);
    }
  }

  void _armAttackHitbox() {
    final data = attackData;
    final hbox = data['hbox'] as Map<String, dynamic>;
    attackHitbox.width = hbox['width'] as double;
    attackHitbox.height = hbox['height'] as double;
    attackHitbox.setOffset(facing * (hbox['ox'] as double), hbox['oy'] as double);
    attackHitbox.applyData(
      damage: data['damage'] as double,
      hitstun: data['hitstun'] as double,
      knockbackX: facing * (data['knockback_x'] as double),
    );
    attackHitbox.arm();
    _applyVisual();
  }

  // ---------------------------------------------------------------- hit
  @override
  bool receiveHit(Hitbox hitbox, Entity attacker) {
    if (!alive) return false;

    if (sm.isCurrent(estados.block)) {
      health -= hitbox.damage * 0.15; // daño reducido al bloquear
      _pushApart(attacker);
    } else {
      health -= hitbox.damage;
      if (health <= 0.0) {
        health = 0.0;
        alive = false;
        _changeState(estados.ko);
        velocity = velocity.copyWith(x: 0.0);
        return true;
      }
      _beginHit(hitbox, attacker);
    }
    return true;
  }

  void _beginHit(Hitbox hitbox, Entity attacker) {
    if (identical(attacker, this)) return;
    hitstunRestante = hitbox.hitstun;
    stateTime = 0.0;
    velocity = velocity.copyWith(x: 0.0);
    sm.change(estados.hit);
    _pushApart(attacker);
    _applyVisual();
  }

  /// Pequeña separación posicional que mantiene a ambos fighters a rango.
  void _pushApart(Entity attacker) {
    if (identical(attacker, this)) return;
    final pushDir = position.x >= attacker.position.x ? 1.0 : -1.0;
    position = position.copyWith(x: position.x + pushDir * 4.0);
    if (attacker is CombatEntity && attacker.alive) {
      attacker.position =
          attacker.position.copyWith(x: attacker.position.x + pushDir * 6.0);
    }
  }

  void _updateHit() {
    if (stateTime >= hitstunRestante) {
      velocity = velocity.copyWith(x: 0.0);
      _changeState(estados.idle);
    }
  }

  // ---------------------------------------------------------------- util
  void _changeState(String nombreEstado) {
    final anterior = sm.getName();
    sm.change(nombreEstado);
    if (sm.getName() != anterior) {
      if (nombreEstado == estados.crouch) {
        _applyStance(crouching: true);
        _applyVisual();
      } else if (anterior == estados.crouch) {
        _applyStance(crouching: false);
        _applyVisual();
      } else {
        _applyStance(crouching: false);
        _applyVisual();
      }
    }
  }

  void _applyStance({bool crouching = false}) {
    final stance = crouching ? _crouchingStance : _standingStance;
    final body = stance['body']!;
    bodyHurtbox.setOffset(body[0], body[1]);
    bodyHurtbox.width = body[2];
    bodyHurtbox.height = body[3];
    final head = stance['head']!;
    headHurtbox.setOffset(head[0], head[1]);
    headHurtbox.width = head[2];
    headHurtbox.height = head[3];
  }

  /// Auto-orienta al fighter hacia el enemigo más cercano.
  void faceTarget(Entity? other) {
    if (other == null) return;
    final miCentro = position.x + physicsBody.width / 2.0;
    final suCentro = other.position.x + physicsBody.width / 2.0;
    facing = suCentro >= miCentro ? 1 : -1;
  }

  void _applyVisual() {
    final estado = sm.getName();
    if (estado == estados.ko) {
      currentColor = _shade(baseColor, 0.35);
    } else if (estado == estados.crouch) {
      currentColor = _shade(baseColor, 0.8);
    } else if (estado == estados.block) {
      currentColor = _shade(baseColor, 1.25);
    } else if (estado == estados.hit) {
      currentColor = const Color(0xFFFF5050);
    } else if ((estado == estados.attackHigh || estado == estados.attackLow) &&
        attackPhase == 'active') {
      currentColor = _shade(baseColor, 1.35);
    } else {
      currentColor = baseColor;
    }
  }
}

class _FighterRenderComponent extends Component {
  @override
  void render(MotorRenderContext renderer) {
    final fighter = owner as Fighter?;
    if (fighter == null) return;
    renderer.drawRect(
      fighter.position.x,
      fighter.position.y,
      fighter.physicsBody.width,
      fighter.physicsBody.height,
      fighter.currentColor,
    );
  }
}