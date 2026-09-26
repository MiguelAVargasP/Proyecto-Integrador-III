import 'package:flutter/material.dart';
import '../../../core/estado_juego.dart';
import '../motor/combat_loop.dart';
import '../motor/input_manager.dart';
import '../juego/combat_arena_scene.dart';
import '../juego/deck.dart';
import '../juego/hand.dart';
import '../juego/super_manager.dart';

/// Pantalla de combate real del "parcial simulado" (RF-05, tercera etapa
/// del ciclo estudiantil). Etapa 7 del plan de puertos: conecta el motor
/// de combate portado (Etapas 1-6) con el `EstadoJuego` de Orientación
/// UPB.
///
/// Conexiones con el resto del juego:
/// - El nivel de estrés acumulado (`estadoJuego.nivelEstres`) reduce la
///   vida máxima del jugador — las decisiones de gestión del tiempo de
///   historias anteriores tienen consecuencia mecánica real aquí, no
///   solo narrativa (RF-08).
/// - Al entrar, se reparte una mano de 5 cartas y se evalúa con
///   `SuperManager` — la combinación de poker determina la superhabilidad
///   disponible durante el combate.
/// - Al terminar (victoria o derrota), se registran las consecuencias en
///   `estadoJuego` y se cierra la pantalla — quien la abrió (ver
///   `ParcialContenido`) decide qué pasa después.
class ParcialCombateScreen extends StatefulWidget {
  const ParcialCombateScreen({super.key});

  @override
  State<ParcialCombateScreen> createState() => _ParcialCombateScreenState();
}

class _ParcialCombateScreenState extends State<ParcialCombateScreen> {
  final InputManager _inputManager = InputManager();
  late final CombatArenaScene _scene;
  late final Hand _mano;
  late final SuperManager _superManager;
  bool _resultadoResuelto = false;

  @override
  void initState() {
    super.initState();

    // Reparte la mano del round: barajar, robar 5, mantenerlas todo el
    // combate (RF: "no robar cartas adicionales durante el round").
    final mazo = Deck()..shuffle();
    _mano = Hand();
    _mano.deal(List.generate(5, (_) => mazo.draw()!));

    _superManager = SuperManager();
    _superManager.loadHand(_mano.cards);

    // El estrés acumulado en historias anteriores reduce la vida máxima
    // disponible para el parcial: 100 en estrés 0, hasta un mínimo de 40
    // en estrés 100 — nunca deja al jugador sin posibilidad real de ganar.
    final vidaMaxima = 100.0 - (estadoJuego.nivelEstres * 0.6);
    _scene = CombatArenaScene(
      _inputManager,
      vidaMaximaJugador: vidaMaxima.clamp(40.0, 100.0),
      superManager: _superManager,
    );
  }

  void _resolverResultado() {
    if (_resultadoResuelto) return;
    _resultadoResuelto = true;

    if (_scene.jugadorGano) {
      estadoJuego.ajustarEstres(-15);
      estadoJuego.registrarDecision(
          'Presentó el parcial simulado y lo aprobó (superhabilidad: ${_superManager.ability?.name ?? "-"}).');
    } else {
      estadoJuego.ajustarEstres(10);
      estadoJuego.registrarDecision(
          'Presentó el parcial simulado y no le fue bien.');
    }
    estadoJuego.completarEtapa();
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
          Positioned(
            top: 16,
            left: 16,
            child: Text(
              'Superhabilidad: ${_superManager.ability?.name ?? "-"}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          _barraDeVida('Jugador', _scene.player.healthRatio(), left: true),
          _barraDeVida('Parcial', _scene.dummy.healthRatio(), left: false),
          _cruceta(),
          _botonesDeAccion(),
          if (_scene.terminado) _overlayResultado(),
        ],
      ),
    );
  }

  Widget _barraDeVida(String etiqueta, double fraccion, {required bool left}) {
    return Positioned(
      top: 40,
      left: left ? 16 : null,
      right: left ? null : 16,
      child: Column(
        crossAxisAlignment: left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(etiqueta, style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            width: 140,
            height: 10,
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraccion.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _cruceta() {
    return Positioned(
      bottom: 24,
      left: 24,
      child: Column(
        children: [
          _boton('jump', Icons.arrow_upward),
          const SizedBox(height: 8),
          Row(children: [
            _boton('move_left', Icons.arrow_back),
            const SizedBox(width: 8),
            _boton('move_right', Icons.arrow_forward),
          ]),
          const SizedBox(height: 8),
          _boton('crouch', Icons.arrow_downward),
        ],
      ),
    );
  }

  Widget _botonesDeAccion() {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _boton('attack_high', Icons.arrow_upward, color: Colors.red.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          _boton('attack_low', Icons.arrow_downward, color: Colors.orange.withValues(alpha: 0.6)),
          const SizedBox(height: 8),
          _boton('block', Icons.shield, color: Colors.blue.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  Widget _overlayResultado() {
    _resolverResultado();
    final gano = _scene.jugadorGano;
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gano ? '¡Aprobaste el parcial!' : 'No te fue bien esta vez',
                style: TextStyle(
                  color: gano ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}