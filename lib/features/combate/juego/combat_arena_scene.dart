import 'dart:ui';
import '../motor/combat_scene.dart';
import '../motor/entity.dart';
import '../motor/component.dart';
import '../motor/physics_system.dart';
import '../motor/motor_render_context.dart';
import '../motor/input_manager.dart';
import 'controller.dart';
import 'damage_system.dart';
import 'fighter.dart';

const double _anchoArena = 320;
const double _altoArena = 180;
const double _altoSuelo = 20;
const double _ySuelo = _altoArena - _altoSuelo;
const double _gravedad = 400.0;

/// Escena de práctica simplificada: jugador (control táctil) contra un
/// muñeco de práctica que no se mueve (`DummyController`). Equivalente
/// reducido de `game/scenes/fight_scene.py` — sin cámara, sin datos desde
/// JSON, sin IA todavía; sirve para verificar que Fighter + físicas +
/// DamageSystem funcionan juntos de punta a punta.
class CombatArenaScene extends CombatScene {
  final PhysicsSystem physicsSystem = PhysicsSystem(gravity: _gravedad);
  final DamageSystem damageSystem = DamageSystem();

  late final Fighter player;
  late final Fighter dummy;

  /// Etapa 7: el nivel de estrés acumulado en `EstadoJuego` reduce la vida
  /// máxima del jugador al entrar al parcial — las decisiones de gestión
  /// del tiempo de historias anteriores (US-06/US-08) tienen consecuencia
  /// mecánica real en el combate, no solo narrativa.
  CombatArenaScene(InputManager inputManager, {double vidaMaximaJugador = 100.0}) {
    backgroundColor = const Color(0xFF283A28); // verde oscuro de práctica

    physicsSystem.setFloorY(_ySuelo);
    physicsSystem.setBounds(0.0, 0.0, _anchoArena, _altoArena);

    // Suelo (solo visual, la colisión real la resuelve PhysicsSystem).
    final suelo = Entity(x: 0.0, y: _ySuelo);
    suelo.addComponent(_RectanguloEstatico(
      ancho: _anchoArena,
      alto: _altoSuelo,
      color: const Color(0xFF483A2A),
    ));
    addEntity(suelo);

    player = Fighter(
      x: 80.0,
      y: _ySuelo - 32.0,
      controller: PlayerController(inputManager),
      color: const Color(0xFF4696E6), // (70,150,230)
      facingInicial: 1,
      maxHealth: vidaMaximaJugador,
      name: 'Jugador',
    );
    dummy = Fighter(
      x: 230.0,
      y: _ySuelo - 32.0,
      controller: DummyController(),
      color: const Color(0xFFE65A50), // (230,90,80)
      facingInicial: -1,
      name: 'Muñeco de práctica',
    );

    addEntity(player);
    addEntity(dummy);
  }

  /// true cuando el combate ya tiene un resultado (alguno de los dos KO).
  bool get terminado => !player.alive || !dummy.alive;

  /// true cuando el combate terminó y ganó el jugador.
  bool get jugadorGano => terminado && player.alive && !dummy.alive;

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
    damageSystem.resolve([player], [dummy]);
    damageSystem.resolve([dummy], [player]);
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

class _RectanguloEstatico extends Component {
  final double ancho;
  final double alto;
  final Color color;
  _RectanguloEstatico({required this.ancho, required this.alto, required this.color});

  @override
  void render(MotorRenderContext renderer) {
    final dueno = owner;
    if (dueno == null) return;
    renderer.drawRect(dueno.position.x, dueno.position.y, ancho, alto, color);
  }
}