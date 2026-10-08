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
import 'sprite_cache.dart';
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

  /// Apariencia pixel-art: 'estudiante' o 'profesor'.
  final String sprite;
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

  /// Y del piso donde se proyecta la sombra (la escena lo ajusta).
  double ySombra = 160.0;

  /// Reloj de animación (respiración, paso al caminar).
  double tAnim = 0.0;

  /// Segundos transcurridos desde el KO (anima la caída).
  double tiempoKo = 0.0;
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
    this.sprite = 'estudiante',
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
      'hbox': {'width': 22.0, 'height': 10.0, 'ox': 10.0, 'oy': 16.0},
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
    tAnim += delta;
    if (!alive) {
      tiempoKo += delta;
      return;
    }
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
    // Espejado respecto al CENTRO del cuerpo: 'ox' es la distancia del
    // borde cercano del golpe al centro. Antes, con facing = -1 la caja
    // se desplazaba hacia atrás pero seguía extendiéndose hacia la
    // derecha, por lo que alcanzaba mucho menos (o nada) a la izquierda.
    final ancho = hbox['width'] as double;
    final ox = hbox['ox'] as double;
    final centro = physicsBody.width / 2.0;
    final izquierda = facing >= 0 ? centro + ox : centro - ox - ancho;
    attackHitbox.setOffset(izquierda, hbox['oy'] as double);
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
    sm.change(estados.hit);
    // Knockback real: cada ataque define su propia fuerza de empuje
    // (ver `attacks['ATTACK_HIGH']['knockback_x']` etc. en el
    // constructor) — se aplica como velocidad, no como un salto fijo de
    // posición, así que el golpe alto empuja notablemente más que el
    // bajo, y el empuje se resuelve de forma natural junto con la
    // integración de física de cada frame durante el hitstun.
    velocity = velocity.copyWith(x: hitbox.knockback.x);
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

// =====================================================================
// Render pixel-art. Todo se dibuja con rectángulos de coordenadas enteras
// en el espacio lógico 320x180 (1 unidad lógica = 1 "píxel" del sprite),
// sin antialiasing, así que se ve como arte de 16 bits y no como vectores.
// =====================================================================

class _Paleta {
  final Color pelo, piel, pielSombra, prenda, prendaSombra, prendaLuz;
  final Color pantalon, pantalonSombra, zapato;
  const _Paleta({
    required this.pelo,
    required this.piel,
    required this.pielSombra,
    required this.prenda,
    required this.prendaSombra,
    required this.prendaLuz,
    required this.pantalon,
    required this.pantalonSombra,
    required this.zapato,
  });
}

const _Paleta _paletaEstudiante = _Paleta(
  pelo: Color(0xFF6B3A1E),
  piel: Color(0xFFE8B07A),
  pielSombra: Color(0xFFC98C5A),
  prenda: Color(0xFFC62828), // sudadera roja
  prendaSombra: Color(0xFF8E1B1B),
  prendaLuz: Color(0xFFE35454),
  pantalon: Color(0xFF2F5FA8),
  pantalonSombra: Color(0xFF1F3F7A),
  zapato: Color(0xFFEDEDED),
);

const _Paleta _paletaProfesor = _Paleta(
  pelo: Color(0xFF1E202F),
  piel: Color(0xFFE8B07A),
  pielSombra: Color(0xFFC98C5A),
  prenda: Color(0xFF7A4E2D), // saco café
  prendaSombra: Color(0xFF512A27),
  prendaLuz: Color(0xFF9A6A42),
  pantalon: Color(0xFF1E202F),
  pantalonSombra: Color(0xFF0F111C),
  zapato: Color(0xFF0B0B12),
);

const _Paleta _paletaExamen = _Paleta(
  pelo: Color(0xFF2F4FA0),
  piel: Color(0xFFFFFFFF), // guantes blancos
  pielSombra: Color(0xFFD9D3BC),
  prenda: Color(0xFF2F4FA0), // tinta azul
  prendaSombra: Color(0xFF1F3578),
  prendaLuz: Color(0xFF4C6BC8),
  pantalon: Color(0xFF2F4FA0),
  pantalonSombra: Color(0xFF1F3578),
  zapato: Color(0xFFD32F2F),
);

const Color _contorno = Color(0xFF0B0F1E);
const Color _blanco = Color(0xFFFFFFFF);

class _FighterRenderComponent extends Component {
  final Paint _p = Paint()..isAntiAlias = false;

  late Canvas _c;
  double _ox = 0, _oy = 0, _dir = 1;

  /// Rectángulo en coordenadas locales: lx crece hacia donde mira el
  /// luchador (0 = centro del cuerpo), ly crece hacia abajo (0 = arriba).
  void _r(double lx, double ly, double w, double h, Color color) {
    final left = _dir > 0 ? _ox + lx : _ox - lx - w;
    _c.drawRect(Rect.fromLTWH(left, _oy + ly, w, h), _p..color = color);
  }

  /// Rectángulo con contorno de 1 px.
  void _rc(double lx, double ly, double w, double h, Color color) {
    _r(lx - 1, ly - 1, w + 2, h + 2, _contorno);
    _r(lx, ly, w, h, color);
  }

  @override
  void render(MotorRenderContext renderer) {
    final f = owner as Fighter?;
    if (f == null) return;
    _c = renderer.canvas;

    final String estado = f.sm.getName() ?? '';
    _dir = f.facing >= 0 ? 1.0 : -1.0;
    final pal = f.sprite == 'profesor' ? _paletaProfesor : _paletaEstudiante;
    final esProfe = f.sprite == 'profesor';

    _ox = (f.position.x + f.physicsBody.width / 2.0).roundToDouble();
    _oy = f.position.y.roundToDouble();
    final pies = _oy + f.physicsBody.height;

    // ---- Sombra: 3 franjas, se encoge al saltar.
    final altura = (f.ySombra - pies).clamp(0.0, 90.0);
    final k = 1.0 - altura / 130.0;
    final sombra = Color.fromRGBO(0, 0, 0, 0.4 * k);
    for (final fila in [
      [22.0, 0.0],
      [18.0, 1.0],
      [12.0, 2.0],
    ]) {
      final ancho = (fila[0] * k).roundToDouble();
      _c.drawRect(Rect.fromLTWH(_ox - ancho / 2, f.ySombra + fila[1], ancho, 1), _p..color = sombra);
    }

    // ---- KO: un instante cae, luego queda tendido (giro exacto de 90°
    // para que los píxeles sigan alineados).
    _c.save();
    var koCaido = false;
    if (estado == estados.ko) {
      if (f.tiempoKo < 0.12) {
        _ox -= _dir * 3.0;
      } else {
        koCaido = true;
        _c.translate(_ox, pies);
        _c.rotate(-_dir * 1.5707963267948966);
        _c.translate(-_ox, -pies);
      }
    }

    final agachado = estado == estados.crouch;
    final enAire = estado == estados.jump || estado == estados.fall;
    final caminando = estado == estados.walk;
    final golpeado = estado == estados.hit || (estado == estados.ko && !koCaido);
    final atacando = estado == estados.attackHigh || estado == estados.attackLow;
    final bloqueando = estado == estados.block;
    final destello = golpeado && f.stateTime < 0.08;

    if (golpeado) _ox -= _dir * 2.0;

    // Cuadros de animación (2 cuadros, como en un sprite sheet clásico).
    final cuadro = (f.tAnim * (caminando ? 10.0 : 3.0)).floor() % 2;
    final bob = (!agachado && !enAire && !caminando && estado == estados.idle && cuadro == 1) ? 1.0 : 0.0;

    if (f.sprite == 'estudiante' && SpriteCache.listo) {
      _dibujarSprite(
        f,
        estado: estado,
        agachado: agachado,
        enAire: enAire,
        caminando: caminando,
        golpeado: golpeado,
        atacando: atacando,
        bloqueando: bloqueando,
        destello: destello,
        cuadro: cuadro,
      );
      _c.restore();
      return;
    }

    if (f.sprite == 'examen') {
      _dibujarExamen(
        f,
        agachado: agachado,
        enAire: enAire,
        caminando: caminando,
        golpeado: golpeado,
        atacando: atacando,
        destello: destello,
        cuadro: cuadro,
        bob: bob,
      );
      _c.restore();
      return;
    }

    final prenda = destello ? _blanco : pal.prenda;
    final prendaSombra = destello ? const Color(0xFFD8E4F5) : pal.prendaSombra;
    final prendaLuz = destello ? _blanco : pal.prendaLuz;
    final pantalon = destello ? _blanco : pal.pantalon;
    final pantalonSombra = destello ? const Color(0xFFD8E4F5) : pal.pantalonSombra;

    final hy = (agachado ? 6.0 : -3.0) + bob; // arriba de la cabeza
    final ty = (agachado ? 16.0 : 7.0) + bob; // arriba del torso
    final th = agachado ? 8.0 : 15.0;
    final caderaY = ty + th;

    // ---- Mochila (estudiante), detrás del torso.
    if (!esProfe) {
      _rc(-9, ty + 1, 4, th - 5, const Color(0xFF1F2A4A));
      _r(-8, ty + 2, 1, th - 7, const Color(0xFF34457A));
    }

    // ---- Brazo trasero.
    final balanceo = caminando ? (cuadro == 0 ? 1.0 : -1.0) : 0.0;
    _rc(-7, ty + 2 + balanceo, 3, agachado ? 5 : 8, prendaSombra);

    // ---- Piernas.
    final paso = caminando ? (cuadro == 0 ? 2.0 : -2.0) : 0.0;
    final legTop = caderaY - 1;
    final piesL = f.physicsBody.height; // pies en coordenadas locales
    final legH = piesL - legTop - (enAire ? 4.0 : 0.0);
    final pataFrenteExtendida = atacando && f.sm.getName() == estados.attackLow;
    // pierna trasera
    _rc(-4 - paso, legTop, 4, legH, pantalonSombra);
    _r(-5 - paso, piesL - 3 - (enAire ? 4.0 : 0.0), 6, 3, _contorno);
    _r(-4 - paso, piesL - 2 - (enAire ? 4.0 : 0.0), 5, 2, pal.zapato);
    // pierna delantera (si no es patada)
    if (!pataFrenteExtendida) {
      _rc(1 + paso, legTop, 4, legH - (enAire ? 1.0 : 0.0), pantalon);
      _r(0 + paso, piesL - 3 - (enAire ? 5.0 : 0.0), 7, 3, _contorno);
      _r(1 + paso, piesL - 2 - (enAire ? 5.0 : 0.0), 6, 2, pal.zapato);
    }

    // ---- Torso con luz a un costado y franja inferior.
    _rc(-5, ty, 10, th, prenda);
    _r(-4, ty + 1, 2, th - 2, prendaLuz);
    _r(3, ty + 1, 2, th - 2, prendaSombra);
    if (esProfe) {
      // camisa blanca + corbata roja
      _r(2, ty, 4, 5, destello ? _blanco : const Color(0xFFF2F2F2));
      _r(3, ty + 1, 2, 7, destello ? _blanco : const Color(0xFF9E1B1B));
    } else {
      // bolsillo canguro de la sudadera
      if (!agachado) _r(-3, ty + th - 5, 7, 1, prendaSombra);
    }

    // ---- Cabeza.
    _rc(-5, hy, 12, 10, pal.piel);
    _r(-5, hy + 3, 1, 5, pal.pielSombra); // sombra de la nuca
    // pelo
    _r(-5, hy, 12, 3, pal.pelo);
    _r(-5, hy + 3, 3, 4, pal.pelo);
    if (!esProfe) _r(4, hy + 3, 3, 1, pal.pelo); // flequillo
    // ojos
    final ojoY = hy + 5;
    if (golpeado) {
      // ojos cerrados con mueca
      _r(0, ojoY, 3, 1, _contorno);
      _r(4, ojoY, 3, 1, _contorno);
      _r(3, hy + 8, 2, 1, const Color(0xFF7A1F1F));
    } else {
      if (esProfe) {
        // lentes
        _r(-1, ojoY - 1, 4, 4, _contorno);
        _r(4, ojoY - 1, 4, 4, _contorno);
        _r(0, ojoY, 2, 2, const Color(0xFFDDEBFF));
        _r(5, ojoY, 2, 2, const Color(0xFFDDEBFF));
        _r(1, ojoY, 1, 2, _contorno);
        _r(6, ojoY, 1, 2, _contorno);
      } else {
        _r(0, ojoY, 2, 2, _contorno);
        _r(5, ojoY, 2, 2, _contorno);
        _r(0, ojoY, 1, 1, _blanco);
        _r(5, ojoY, 1, 1, _blanco);
      }
      if (atacando) {
        // ceño fruncido
        _r(-1, ojoY - 2, 4, 1, _contorno);
        _r(4, ojoY - 2, 4, 1, _contorno);
      }
      _r(3, hy + 8, 2, 1, const Color(0xFF8A3B2A)); // boca
    }

    // ---- Brazo delantero / ataque / bloqueo.
    if (atacando) {
      _dibujarAtaque(f, pal, ty, caderaY, pantalon, prenda);
    } else if (bloqueando) {
      // Antebrazos cruzados al frente como escudo.
      _rc(5, ty - 1, 4, 13, const Color(0xFFB8D4F0));
      _r(6, ty, 1, 11, _blanco);
      _r(5, ty + 12, 4, 3, pal.piel); // manos
      // destello de bloqueo (parpadea)
      if (cuadro == 0) {
        _r(10, ty + 2, 1, 3, const Color(0xFF63B3FF));
        _r(11, ty + 3, 1, 1, const Color(0xFF63B3FF));
        _r(10, ty + 8, 1, 3, const Color(0xFF63B3FF));
      }
    } else {
      final dy = caminando ? (cuadro == 0 ? -1.0 : 1.0) : 0.0;
      _rc(3, ty + 2 + dy, 3, agachado ? 5 : 8, prenda);
      _r(3, ty + (agachado ? 7 : 10) + dy, 3, 3, pal.piel);
    }

    _c.restore();
  }

  /// Dibuja la pose PNG que corresponde al estado actual (sprites reales).
  void _dibujarSprite(
    Fighter f, {
    required String estado,
    required bool agachado,
    required bool enAire,
    required bool caminando,
    required bool golpeado,
    required bool atacando,
    required bool bloqueando,
    required bool destello,
    required int cuadro,
  }) {
    String id = 'estudiante_idle';
    final fase = f.attackPhase;
    if (atacando && (fase == 'active' || fase == 'recovery')) {
      id = estado == estados.attackHigh ? 'estudiante_golpe' : 'estudiante_patada';
    } else if (golpeado || estado == estados.ko) {
      id = 'estudiante_golpeado';
    } else if (bloqueando) {
      id = 'estudiante_bloqueo';
    } else if (enAire) {
      id = 'estudiante_alto';
    } else if (caminando) {
      // Ciclo de 8 cuadros. Si camina hacia atrás (de espaldas al rival),
      // el ciclo corre al revés para que los pies no "patinen".
      var paso = (f.tAnim * 12.0).floor() % 8;
      if (f.velocity.x * _dir < 0) paso = 7 - paso;
      id = 'estudiante_caminar${paso + 1}';
    }
    final pose = SpriteCache.pose(id);
    if (pose == null) return;

    const k = 1.0 / SpriteCache.pxPorUnidad;
    final w = pose.imagen.width * k;
    final h = pose.imagen.height * k;

    // Pequeño movimiento: respiración en reposo, rebote al caminar.
    double dy = 0.0;
    if (estado == estados.idle) dy = cuadro == 1 ? 0.5 : 0.0;
    final sy = agachado ? 0.78 : 1.0;

    final pies = _oy + f.physicsBody.height + dy;
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..isAntiAlias = true;
    if (destello) {
      paint.colorFilter = const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcATop);
    }

    _c.save();
    _c.translate(_ox, pies);
    _c.scale(_dir, sy);
    _c.drawImageRect(
      pose.imagen,
      Rect.fromLTWH(0, 0, pose.imagen.width.toDouble(), pose.imagen.height.toDouble()),
      Rect.fromLTWH(-pose.anclaX * k, -h, w, h),
      paint,
    );
    _c.restore();

    if (bloqueando && cuadro == 0) {
      // Destellos de bloqueo (parpadean) delante del puño.
      const azul = Color(0xFF63B3FF);
      _r(18, 4, 1, 5, azul);
      _r(21, 8, 3, 1, azul);
      _r(19, 12, 1, 5, azul);
      _r(22, 16, 3, 1, azul);
    }
  }

  /// La hoja de examen: un papel con cara, brazos y piernas de tinta. Ataca
  /// con un lápiz (golpe alto) y una patada (golpe bajo).
  void _dibujarExamen(
    Fighter f, {
    required bool agachado,
    required bool enAire,
    required bool caminando,
    required bool golpeado,
    required bool atacando,
    required bool destello,
    required int cuadro,
    required double bob,
  }) {
    const papel = Color(0xFFF4F1E4);
    const papelSombra = Color(0xFFD9D3BC);
    const tinta = Color(0xFF2F4FA0);
    const gris = Color(0xFF9AA3B5);
    const rojo = Color(0xFFD32F2F);

    final hoja = destello ? _blanco : papel;
    final top = (agachado ? 13.0 : 2.0) + bob;
    final alto = agachado ? 13.0 : 22.0;
    final base = top + alto;
    final paso = caminando ? (cuadro == 0 ? 2.0 : -2.0) : 0.0;
    final aire = enAire ? 4.0 : 0.0;
    final legH = 32.0 - base - aire;
    final patada = atacando && f.sm.getName() == estados.attackLow;

    // Brazo trasero.
    _rc(-12, top + 7, 2, 8, tinta);
    _r(-13, top + 14, 4, 3, _blanco);

    // Piernas (palitos de tinta con zapatos rojos).
    _rc(-5 - paso, base - 1, 3, legH + 1, tinta);
    _r(-6 - paso, 32.0 - 2 - aire, 5, 2, rojo);
    if (!patada) {
      _rc(2 + paso, base - 1, 3, legH + 1 - (enAire ? 1.0 : 0.0), tinta);
      _r(1 + paso, 32.0 - 2 - aire - (enAire ? 1.0 : 0.0), 5, 2, rojo);
    }

    // Hoja de papel.
    _rc(-9, top, 18, alto, hoja);
    _r(7, top + 1, 2, alto - 2, destello ? _blanco : papelSombra);
    _r(5, top, 4, 4, destello ? _blanco : papelSombra); // esquina doblada
    _r(5, top + 3, 4, 1, _contorno);
    _r(5, top, 1, 4, _contorno);

    if (!agachado) {
      // Encabezado y renglones de la hoja.
      _r(-7, top + 3, 9, 1, tinta);
      _r(-7, top + 5, 6, 1, gris);
      _r(-7, top + 17, 13, 1, gris);
      _r(-7, top + 19, 9, 1, gris);
      _r(3, top + 19, 1, 1, rojo);
      _r(4, top + 18, 1, 1, rojo);
    }

    // Cara.
    final ojoY = top + (agachado ? 3.0 : 9.0);
    if (golpeado) {
      _r(-3, ojoY, 3, 1, tinta);
      _r(2, ojoY, 3, 1, tinta);
      if (!agachado) _r(0, ojoY + 4, 3, 3, tinta); // boca abierta
    } else {
      _r(-3, ojoY, 2, 3, _contorno);
      _r(2, ojoY, 2, 3, _contorno);
      _r(-3, ojoY, 1, 1, _blanco);
      _r(2, ojoY, 1, 1, _blanco);
      // cejas fruncidas (más marcadas al atacar)
      _r(-4, ojoY - 2, 4, 1, atacando ? rojo : tinta);
      _r(1, ojoY - 2 + (atacando ? 1.0 : 0.0), 4, 1, atacando ? rojo : tinta);
      if (!agachado) {
        _r(-1, ojoY + 5, 5, 1, _contorno);
        _r(-2, ojoY + 6, 1, 1, _contorno);
        _r(4, ojoY + 6, 1, 1, _contorno);
      }
    }

    // Brazo delantero / ataque con lápiz.
    if (atacando) {
      _dibujarAtaque(f, _paletaExamen, top + 6, base, tinta, tinta);
    } else {
      final dy = caminando ? (cuadro == 0 ? -1.0 : 1.0) : 0.0;
      _rc(10, top + 7 + dy, 2, 8, tinta);
      _r(9, top + 14 + dy, 4, 3, _blanco);
    }
  }

  void _dibujarAtaque(Fighter f, _Paleta pal, double ty, double caderaY, Color pantalon, Color manga) {
    final fase = f.attackPhase;
    final alto = f.sm.getName() == estados.attackHigh;
    final caja = f.attackHitbox.getRect();

    // Posición del golpe relativa al centro del luchador, en su "adelante".
    final centroX = _ox;
    final objetivoLx = (_dir > 0 ? caja.right - centroX : centroX - caja.x).roundToDouble();
    final objetivoY = (caja.y + caja.height / 2.0).roundToDouble() - _oy;

    final reposoLx = 5.0;
    double ext;
    double brillo = 0.0;
    if (fase == 'startup') {
      final dur = f.attackData['startup'] as double;
      final p = dur <= 0 ? 1.0 : (f.stateTime / dur).clamp(0.0, 1.0);
      ext = 2.0 + p * 2.0; // brazo/pierna recogidos
    } else if (fase == 'active') {
      ext = objetivoLx;
      brillo = 1.0;
    } else {
      final dur = f.attackData['recovery'] as double;
      final p = dur <= 0 ? 1.0 : (f.stateTime / dur).clamp(0.0, 1.0);
      ext = (objetivoLx + (reposoLx - objetivoLx) * p).roundToDouble();
      brillo = 1.0 - p;
    }
    final y = fase == 'active' || fase == 'recovery' ? objetivoY : (alto ? ty + 3 : caderaY - 2);

    if (alto) {
      // Puño: manga + puño de piel.
      final esExamen = f.sprite == 'examen';
      final largo = (ext - 4.0 - (esExamen ? 6.0 : 0.0)).clamp(2.0, 40.0);
      _rc(2, y - 1, largo, 3, manga);
      _rc(2 + largo, y - 2, 4, 4, pal.piel);
      if (esExamen) {
        // Lápiz amarillo con goma y punta.
        _r(2 + largo - 1, y - 1, 2, 2, const Color(0xFFE57373)); // goma
        _r(2 + largo + 3, y - 1, 6, 2, const Color(0xFFFFD54F)); // cuerpo
        _r(2 + largo + 9, y - 1, 1, 2, _contorno); // punta
      }
    } else {
      // Patada baja: pierna extendida + zapato.
      final largo = (ext - 5.0).clamp(2.0, 40.0);
      _rc(1, y - 2, largo, 4, pantalon);
      _rc(1 + largo, y - 3, 5, 5, pal.zapato);
    }

    if (brillo > 0.5) {
      // Estrella de impacto pixelada.
      final tip = ext + 2.0;
      const dorado = Color(0xFFFFE08A);
      _r(tip, y - 4, 2, 8, dorado);
      _r(tip - 2, y - 1, 6, 2, dorado);
      _r(tip, y - 1, 2, 2, _blanco);
    }
  }
}