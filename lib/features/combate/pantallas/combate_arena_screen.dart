import 'package:flutter/material.dart';
import '../motor/combat_loop.dart';
import '../motor/input_manager.dart';
import '../juego/combat_arena_scene.dart';

/// Pantalla de verificación de la Etapa 3: Fighter real contra un muñeco
/// de práctica, con controles táctiles de combate (no los botones de
/// depuración de la Etapa 1).
///
/// Diseño de controles: cruceta de movimiento a la izquierda (izquierda/
/// derecha/saltar/agachar) y tres botones de acción a la derecha (golpe
/// alto, golpe bajo, bloqueo) — el equivalente táctil de WASD+JKL del
/// original en teclado.
class CombateArenaScreen extends StatefulWidget {
  const CombateArenaScreen({super.key});

  @override
  State<CombateArenaScreen> createState() => _CombateArenaScreenState();
}

class _CombateArenaScreenState extends State<CombateArenaScreen> {
  final InputManager _inputManager = InputManager();
  late final CombatArenaScene _scene;

  @override
  void initState() {
    super.initState();
    _scene = CombatArenaScene(_inputManager);
  }

  Widget _boton(String accion, IconData icono, {Color color = Colors.white24}) {
    return GestureDetector(
      onTapDown: (_) => _inputManager.press(accion),
      onTapUp: (_) => _inputManager.release(accion),
      onTapCancel: () => _inputManager.release(accion),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(28)),
        child: Icon(icono, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _barraDeVida(String etiqueta, double fraccion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(etiqueta, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 140,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fraccion.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CombatLoop(scene: _scene, inputManager: _inputManager, onTick: () => setState(() {})),
          ),

          // Barras de vida (se leen directo del Fighter cada frame gracias
          // a que CombatLoop llama setState en cada tick).
          Positioned(
            top: 16,
            left: 16,
            child: _barraDeVida('Jugador', _scene.player.healthRatio()),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: _barraDeVida('Muñeco', _scene.dummy.healthRatio()),
          ),

          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
              ),
            ),
          ),

          // Cruceta de movimiento (izquierda de la pantalla).
          Positioned(
            bottom: 24,
            left: 24,
            child: Column(
              children: [
                _boton('jump', Icons.arrow_upward),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _boton('move_left', Icons.arrow_back),
                    const SizedBox(width: 8),
                    _boton('move_right', Icons.arrow_forward),
                  ],
                ),
                const SizedBox(height: 8),
                _boton('crouch', Icons.arrow_downward),
              ],
            ),
          ),

          // Botones de acción (derecha de la pantalla).
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _boton('attack_high', Icons.arrow_upward, color: Colors.red.withOpacity(0.6)),
                const SizedBox(height: 8),
                _boton('attack_low', Icons.arrow_downward, color: Colors.orange.withOpacity(0.6)),
                const SizedBox(height: 8),
                _boton('block', Icons.shield, color: Colors.blue.withOpacity(0.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}