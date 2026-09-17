import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'combat_scene.dart';
import 'input_manager.dart';
import 'motor_render_context.dart';

/// Reemplazo de `engine/core/game.py`. La versión Python tenía un
/// `while self._running:` manual, con `pygame.time.Clock` fijando el
/// framerate y `pygame.event.get()` alimentando el input. Aquí, el
/// `Ticker` nativo de Flutter dispara `_onTick` una vez por frame de
/// pantalla (típicamente 60 Hz), y usamos su propio timestamp para
/// calcular `delta` — el mismo rol que cumplía `clock.tick(fps)`.
///
/// La secuencia de fases se conserva igual que el loop original:
/// 1. INPUT — 2. UPDATE — 3. PHYSICS — 4. COLLISION — 5. RENDER
/// (RENDER ocurre en el CustomPainter, activado por el repintado que
/// dispara este widget; no hay fase de AUDIO todavía — se agrega en la
/// etapa de audio del plan de puertos).
class CombatLoop extends StatefulWidget {
  final CombatScene scene;
  final InputManager inputManager;

  /// Se llama una vez por frame, DESPUÉS de correr la lógica del frame
  /// (input/update/physics/collision), para que la pantalla que contiene
  /// este widget (barras de vida, textos de estado, etc.) pueda
  /// refrescarse en sincronía con el combate. Sin esto, un `setState` en
  /// la pantalla contenedora solo repinta lo que sea que el combate
  /// tuviera en el momento en que ESA pantalla se reconstruyó por su
  /// cuenta — nunca frame a frame — y widgets como las barras de vida
  /// parecen "congelados" hasta que algo más fuerza un rebuild ahí.
  final VoidCallback? onTick;

  const CombatLoop({
    super.key,
    required this.scene,
    required this.inputManager,
    this.onTick,
  });

  @override
  State<CombatLoop> createState() => _CombatLoopState();
}

class _CombatLoopState extends State<CombatLoop>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _ultimoElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final deltaSegundos =
        (elapsed - _ultimoElapsed).inMicroseconds / 1000000.0;
    _ultimoElapsed = elapsed;
    if (deltaSegundos <= 0) return;

    // 1 - INPUT
    widget.inputManager.update();
    widget.scene.handleInput(widget.inputManager);

    // 2 - UPDATE
    widget.scene.update(deltaSegundos);

    // 3 - PHYSICS
    widget.scene.onPhysicsStep(deltaSegundos);

    // 4 - COLLISION
    widget.scene.onCollisionStep();

    // 5 - RENDER: se dispara con setState, que provoca el repintado del
    // CustomPainter (ver build()).
    setState(() {});

    // Avisa a quien contiene este widget que hay un frame nuevo.
    widget.onTick?.call();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CombatPainter(widget.scene),
      size: Size.infinite,
    );
  }
}

class _CombatPainter extends CustomPainter {
  final CombatScene scene;
  _CombatPainter(this.scene);

  @override
  void paint(Canvas canvas, Size size) {
    final logical = scene.logicalSize;

    // Llena TODA la pantalla real con negro primero — si la proporción
    // de la pantalla no calza exacto con la del área lógica, esto evita
    // franjas sin pintar en vez de dejarlas transparentes.
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF000000));

    // Escala uniforme (preserva proporción) que hace caber el área
    // lógica dentro del tamaño real disponible, centrada.
    final escalaX = size.width / logical.width;
    final escalaY = size.height / logical.height;
    final escala = escalaX < escalaY ? escalaX : escalaY;
    final anchoRenderizado = logical.width * escala;
    final altoRenderizado = logical.height * escala;
    final offsetX = (size.width - anchoRenderizado) / 2;
    final offsetY = (size.height - altoRenderizado) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(escala);

    // A partir de aquí, todo lo que dibuje la escena usa coordenadas del
    // espacio lógico (320x180 por defecto) — el canvas ya está
    // transformado para que eso llene el área calculada arriba.
    final renderer = MotorRenderContext(canvas, logical);
    renderer.clear(scene.backgroundColor);
    scene.render(renderer);

    canvas.restore();
  }

  // Repinta en cada frame mientras el CombatLoop esté activo — el motor
  // de combate se anima constantemente (no es una UI estática), así que
  // no vale la pena comparar estados para decidir si repintar o no.
  @override
  bool shouldRepaint(covariant _CombatPainter oldDelegate) => true;
}