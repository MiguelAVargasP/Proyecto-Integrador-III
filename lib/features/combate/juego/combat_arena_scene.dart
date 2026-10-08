import 'dart:ui';
import '../motor/combat_scene.dart';
import '../motor/entity.dart';
import '../motor/physics_system.dart';
import '../motor/motor_render_context.dart';
import '../motor/input_manager.dart';
import 'arena_fondo.dart';
import 'controller.dart';
import 'efectos_visuales.dart';
import 'damage_system.dart';
import 'fighter.dart';
import 'fighter_state.dart' as estados;
import 'super_manager.dart';

const double _anchoArena = 320;
const double _altoArena = 180;
const double _altoSuelo = 20;
const double _ySuelo = _altoArena - _altoSuelo;

/// Escena de práctica simplificada: jugador (control táctil) contra un
/// muñeco de práctica que no se mueve (`DummyController`). Equivalente
/// reducido de `game/scenes/fight_scene.py` — sin cámara, sin datos desde
/// JSON, sin IA todavía; sirve para verificar que Fighter + físicas +
/// DamageSystem funcionan juntos de punta a punta.
class CombatArenaScene extends CombatScene {
  final PhysicsSystem physicsSystem;
  final DamageSystem damageSystem = DamageSystem();

  /// Chispas, números de daño y temblor de pantalla.
  final EfectosVisuales efectos = EfectosVisuales();

  late final Fighter player;
  late final Fighter dummy;

  CombatArenaScene(
    InputManager inputManager, {
    double vidaMaximaJugador = 100.0,
    SuperManager? superManager,
  }) : physicsSystem = PhysicsSystem() {
    backgroundColor = const Color(0xFF283A28); // verde oscuro de práctica

    physicsSystem.setFloorY(_ySuelo);
    physicsSystem.setBounds(0.0, 0.0, _anchoArena, _altoArena);

    // Fondo (aula de examen + piso). La colisión real del piso la
    // resuelve PhysicsSystem; esto es solo visual.
    final fondo = Entity(x: 0.0, y: 0.0);
    fondo.addComponent(ArenaFondo(ancho: _anchoArena, alto: _altoArena, ySuelo: _ySuelo));
    addEntity(fondo);

    player = Fighter(
      x: 80.0,
      y: _ySuelo - 32.0,
      controller: PlayerController(inputManager),
      color: const Color(0xFF4696E6), // (70,150,230)
      facingInicial: 1,
      maxHealth: vidaMaximaJugador,
      name: 'Estudiante',
      sprite: 'estudiante',
    );
    // IA básica (ver controller.dart): se acerca cuando está lejos, y a
    // rango ataca/bloquea/espera al azar con un pequeño tiempo de
    // reacción. `objetivo: player` ya existe (se construyó arriba); `yo`
    // se completa justo abajo, una vez que `dummy` ya existe.
    final iaDelMuneco = AIController(objetivo: player);
    dummy = Fighter(
      x: 230.0,
      y: _ySuelo - 32.0,
      controller: iaDelMuneco,
      color: const Color(0xFFE65A50), // (230,90,80)
      facingInicial: -1,
      name: 'Hoja de examen',
      sprite: 'examen',
    );
    iaDelMuneco.yo = dummy;

    // Conecta la superhabilidad del jugador si se proporcionó.
    if (superManager != null) {
      player.superManager.ability = superManager.ability;
    }

    player.ySombra = _ySuelo;
    dummy.ySombra = _ySuelo;

    addEntity(player);
    addEntity(dummy);
  }

  /// Segundos de combate antes de que se decida por tiempo (RF-12: la
  /// partida debe caber en una sesión corta — un combate que se puede
  /// alargar indefinidamente no respeta esa restricción).
  static const double _duracionCombate = 45.0;
  double tiempoRestante = _duracionCombate;

  bool get tiempoAgotado => tiempoRestante <= 0.0;

  /// true cuando el combate ya tiene un resultado (KO de alguno de los
  /// dos, o se acabó el tiempo).
  bool get terminado => !player.alive || !dummy.alive || tiempoAgotado;

  /// true cuando el combate terminó y ganó el jugador. Si terminó por
  /// tiempo sin KO, gana quien tenga más vida restante (empate exacto se
  /// resuelve a favor del jugador).
  bool get jugadorGano {
    if (!terminado) return false;
    if (!player.alive) return false;
    if (!dummy.alive) return true;
    return player.health >= dummy.health;
  }

  @override
  void update(double delta) {
    super.update(delta);
    efectos.update(delta);
    if (!terminado) {
      tiempoRestante -= delta;
      if (tiempoRestante < 0.0) tiempoRestante = 0.0;
    }
  }

  @override
  void onPhysicsStep(double delta) {
    // Aplica gravedad/integración/colisión con el suelo a ambos fighters
    // (el PhysicsSystem original lo maneja `Game`, no la escena; aquí la
    // escena lo posee directamente por simplicidad de arquitectura).
    physicsSystem.update(delta, entities);
    player.onPhysicsResolved();
    dummy.onPhysicsResolved();
  }

  @override
  void onCollisionStep() {
    player.faceTarget(dummy);
    dummy.faceTarget(player);
    _separateBodies();
    final vidaJugadorAntes = player.health;
    final vidaMunecoAntes = dummy.health;
    final golpesDelJugador = damageSystem.resolve([player], [dummy]);
    final golpesDelMuneco = damageSystem.resolve([dummy], [player]);
    // Hit-pause breve cuando conecta cualquier golpe — un golpe se siente
    // más contundente con una micro-pausa que sin ninguna, sin cambiar
    // ningún número de daño ni de vida.
    if (golpesDelJugador > 0 || golpesDelMuneco > 0) {
      solicitarPausa(0.06);
    }
    if (golpesDelJugador > 0) {
      _efectoDeGolpe(atacante: player, defensor: dummy, vidaAntes: vidaMunecoAntes);
    }
    if (golpesDelMuneco > 0) {
      _efectoDeGolpe(atacante: dummy, defensor: player, vidaAntes: vidaJugadorAntes);
    }
  }

  /// Chispas + número flotante + temblor en el punto de impacto.
  void _efectoDeGolpe({
    required Fighter atacante,
    required Fighter defensor,
    required double vidaAntes,
  }) {
    final caja = atacante.attackHitbox.getRect();
    final x = atacante.facing >= 0 ? caja.right : caja.x;
    final y = caja.y + caja.height / 2.0;
    final danio = vidaAntes - defensor.health;
    final bloqueado = defensor.sm.isCurrent(estados.block);
    final ko = !defensor.alive;

    if (bloqueado) {
      efectos.impacto(x, y, const Color(0xFF8CC8FF), cantidad: 6);
      efectos.texto(defensor.position.x + 12, defensor.position.y - 10, 'BLOQUEO', const Color(0xFF8CC8FF), tam: 7);
      efectos.temblar(amplitud: 0.8, duracion: 0.08);
    } else {
      efectos.impacto(x, y, const Color(0xFFFFC857), fuerte: ko);
      efectos.texto(
        defensor.position.x + 12,
        defensor.position.y - 10,
        '-${danio.round()}',
        ko ? const Color(0xFFFF5A5A) : const Color(0xFFFFFFFF),
        tam: ko ? 12 : 9,
      );
      efectos.temblar(amplitud: ko ? 4.0 : 2.0, duracion: ko ? 0.3 : 0.15);
    }
  }

  @override
  void render(MotorRenderContext renderer) {
    final canvas = renderer.canvas;
    final t = efectos.temblor;
    canvas.save();
    canvas.translate(t.dx, t.dy);
    super.render(renderer);
    efectos.render(renderer);
    canvas.restore();
  }

  /// Evita que los dos cuerpos se superpongan horizontalmente.
  void _separateBodies() {
    final a = player, b = dummy;
    final aWidth = a.physicsBody.width;
    final bWidth = b.physicsBody.width;
    final aLeft = a.position.x, aRight = a.position.x + aWidth;
    final bLeft = b.position.x, bRight = b.position.x + bWidth;

    if (aLeft >= bRight || bLeft >= aRight) return; // sin superposición

    final overlap =
        (aRight < bRight ? aRight : bRight) - (aLeft > bLeft ? aLeft : bLeft);
    final half = overlap / 2.0;
    if (aLeft <= bLeft) {
      a.position = a.position.copyWith(x: a.position.x - half);
      b.position = b.position.copyWith(x: b.position.x + half);
    } else {
      a.position = a.position.copyWith(x: a.position.x + half);
      b.position = b.position.copyWith(x: b.position.x - half);
    }
  }
}