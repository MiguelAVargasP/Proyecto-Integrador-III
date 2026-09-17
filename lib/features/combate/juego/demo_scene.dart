import 'dart:ui';
import '../motor/combat_scene.dart';
import 'demo_entity.dart';

/// Escena mínima de Etapa 1: solo contiene la entidad de demostración.
/// Equivalente Flutter del criterio de éxito del prototipo original:
/// "debe existir un escenario simple" + "Fighter representado
/// temporalmente por una figura geométrica" + "el Fighter debe moverse
/// izquierda/derecha".
class DemoScene extends CombatScene {
  late final DemoEntity jugador;

  DemoScene() {
    backgroundColor = const Color(0xFF28233C); // (40,35,60) del original
    jugador = DemoEntity(x: 140, y: 74, color: const Color(0xFF40AADC));
    addEntity(jugador);
  }
}
