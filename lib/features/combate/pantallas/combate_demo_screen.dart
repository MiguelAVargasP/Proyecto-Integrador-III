import 'package:flutter/material.dart';
import '../motor/combat_loop.dart';
import '../motor/input_manager.dart';
import '../juego/demo_scene.dart';

/// Pantalla de verificación de la Etapa 1 del puerto de Fighting Deck.
/// Cumple el mismo criterio de éxito del prototipo original, adaptado a
/// Android: abre una pantalla, hay un game loop corriendo, el input
/// funciona (esta vez táctil, no teclado), existe una escena, existe una
/// entidad que camina izquierda/derecha, y la pantalla cierra
/// correctamente.
///
/// Los botones de mover son controles de depuración temporales — el
/// diseño real de controles táctiles (joystick virtual + botones de
/// ataque) es trabajo de la Etapa 3 (Fighter/PlayerController), cuando
/// haya un Fighter real que controlar.
class CombateDemoScreen extends StatefulWidget {
  const CombateDemoScreen({super.key});

  @override
  State<CombateDemoScreen> createState() => _CombateDemoScreenState();
}

class _CombateDemoScreenState extends State<CombateDemoScreen> {
  final InputManager _inputManager = InputManager();
  late final DemoScene _scene;

  @override
  void initState() {
    super.initState();
    _scene = DemoScene();
  }

  Widget _botonMover(String accion, IconData icono) {
    return GestureDetector(
      onTapDown: (_) => _inputManager.press(accion),
      onTapUp: (_) => _inputManager.release(accion),
      onTapCancel: () => _inputManager.release(accion),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Icon(icono, color: Colors.white, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CombatLoop(scene: _scene, inputManager: _inputManager),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black45),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            child: Row(
              children: [
                _botonMover('move_left', Icons.arrow_back),
                const SizedBox(width: 12),
                _botonMover('move_right', Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
