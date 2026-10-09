import 'package:flutter/material.dart';
import '../../../core/estado_juego.dart';
import '../motor/combat_loop.dart';
import '../motor/input_manager.dart';
import '../juego/combat_arena_scene.dart';
import '../juego/deck.dart';
import '../juego/hand.dart';
import '../juego/sprite_cache.dart';
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

  // Barras "con estela": la parte clara se queda atrás y baja despacio,
  // para que se note cuánto daño acaba de entrar.
  double _estelaJugador = 1.0;
  double _estelaRival = 1.0;
  final Stopwatch _reloj = Stopwatch()..start();
  double _ultimoT = 0.0;
  bool _mostrarBanner = true;

  @override
  void initState() {
    super.initState();
    SpriteCache.cargar(); // sprites PNG del combate (si faltan, se usa el dibujo de respaldo)

    // Reparte la mano del round: barajar, robar 5, mantenerlas todo el
    // combate (RF: "no robar cartas adicionales durante el round").
    final mazo = Deck()..shuffle();
    _mano = Hand();
    _mano.deal(List.generate(5, (_) => mazo.draw()!));

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _mostrarBanner = false);
    });

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

  void _alTick() {
    final t = _reloj.elapsedMicroseconds / 1e6;
    final dt = (t - _ultimoT).clamp(0.0, 0.1);
    _ultimoT = t;
    _estelaJugador = _bajarEstela(_estelaJugador, _scene.player.healthRatio(), dt);
    _estelaRival = _bajarEstela(_estelaRival, _scene.dummy.healthRatio(), dt);
    setState(() {});
  }

  double _bajarEstela(double estela, double real, double dt) {
    if (estela <= real) return real;
    return (estela - 0.35 * dt).clamp(real, 1.0);
  }

  @override
  void dispose() {
    _reloj.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CombatLoop(scene: _scene, inputManager: _inputManager, onTick: _alTick),
          ),
          _hudSuperior(),
          _cruceta(),
          _botonesDeAccion(),
          _bannerInicio(),
          if (_scene.terminado) _overlayResultado(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ HUD
  Widget _hudSuperior() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _placaVida(
                nombre: 'Estudiante',
                rol: 'ESTUDIANTE',
                colorRol: const Color(0xFF1565C0),
                real: _scene.player.healthRatio(),
                estela: _estelaJugador,
                vida: _scene.player.health,
                vidaMax: _scene.player.maxHealth,
                izquierda: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  _cronometro(),
                  const SizedBox(height: 4),
                  _chipSuper(),
                ],
              ),
            ),
            Expanded(
              child: _placaVida(
                nombre: 'Hoja de examen',
                rol: 'PARCIAL',
                colorRol: const Color(0xFFB3261E),
                real: _scene.dummy.healthRatio(),
                estela: _estelaRival,
                vida: _scene.dummy.health,
                vidaMax: _scene.dummy.maxHealth,
                izquierda: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placa de personaje: marco azul marino con filete dorado, nombre,
  /// barra de vida segmentada y cinta de rol (mismo estilo de las placas
  /// de los personajes).
  Widget _placaVida({
    required String nombre,
    required String rol,
    required Color colorRol,
    required double real,
    required double estela,
    required double vida,
    required double vidaMax,
    required bool izquierda,
  }) {
    return _MarcoPixel(
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      child: Column(
        crossAxisAlignment: izquierda ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(nombre, style: _fuente(13, Colors.white)),
          const SizedBox(height: 3),
          SizedBox(
            height: 12,
            child: CustomPaint(
              size: const Size(double.infinity, 12),
              painter: _BarraPixelPainter(
                real: real.clamp(0.0, 1.0),
                estela: estela.clamp(0.0, 1.0),
                desdeIzquierda: izquierda,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: izquierda ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              _Cinta(texto: rol, color: colorRol),
              const SizedBox(width: 6),
              Text('${vida.ceil()}/${vidaMax.round()}', style: _fuente(10, const Color(0xFFB8C4DC))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cronometro() {
    final segundos = _scene.tiempoRestante.ceil();
    final pocoTiempo = segundos <= 10;
    return _MarcoPixel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        '$segundos',
        style: _fuente(22, pocoTiempo ? const Color(0xFFFF5A5A) : const Color(0xFFFFE08A)),
      ),
    );
  }

  Widget _chipSuper() {
    final nombre = _superManager.ability?.name;
    if (nombre == null) return const SizedBox.shrink();
    return _Cinta(texto: '⚡ $nombre', color: const Color(0xFF6A1B9A));
  }

  /// Banner "¡PARCIAL!" al empezar.
  Widget _bannerInicio() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _mostrarBanner ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Text(
              '¡PARCIAL!',
              style: _fuente(
                48,
                const Color(0xFFFFE08A),
                sombras: const [
                  Shadow(color: Color(0xFF05070F), offset: Offset(4, 4)),
                  Shadow(color: Color(0xFF9E1B1B), offset: Offset(2, 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------- controles
  Widget _cruceta() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Column(
        children: [
          _BotonControl(accion: 'jump', icono: Icons.keyboard_arrow_up, input: _inputManager),
          const SizedBox(height: 6),
          Row(children: [
            _BotonControl(accion: 'move_left', icono: Icons.keyboard_arrow_left, input: _inputManager),
            const SizedBox(width: 6),
            _BotonControl(accion: 'move_right', icono: Icons.keyboard_arrow_right, input: _inputManager),
          ]),
          const SizedBox(height: 6),
          _BotonControl(accion: 'crouch', icono: Icons.keyboard_arrow_down, input: _inputManager),
        ],
      ),
    );
  }

  Widget _botonesDeAccion() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotonControl(
            accion: 'attack_high',
            icono: Icons.flash_on,
            etiqueta: 'ALTO',
            color: const Color(0xFF9E1B1B),
            tamano: 60,
            input: _inputManager,
          ),
          const SizedBox(height: 6),
          _BotonControl(
            accion: 'attack_low',
            icono: Icons.sports_martial_arts,
            etiqueta: 'BAJO',
            color: const Color(0xFFB86A12),
            tamano: 60,
            input: _inputManager,
          ),
          const SizedBox(height: 6),
          _BotonControl(
            accion: 'block',
            icono: Icons.shield,
            etiqueta: 'BLOQUEO',
            color: const Color(0xFF1565C0),
            input: _inputManager,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- resultado
  Widget _overlayResultado() {
    _resolverResultado();
    final gano = _scene.jugadorGano;
    final porTiempo = _scene.tiempoAgotado && _scene.player.alive && _scene.dummy.alive;
    final acento = gano ? const Color(0xFF6BE675) : const Color(0xFFFF6B6B);
    return Positioned.fill(
      child: Container(
        color: const Color(0xCC05070F),
        child: Center(
          child: SizedBox(
            width: 340,
            child: _MarcoPixel(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(gano ? Icons.emoji_events : Icons.sentiment_dissatisfied, color: acento, size: 44),
                  const SizedBox(height: 8),
                  Text(
                    gano ? '¡Aprobaste el parcial!' : 'No te fue bien esta vez',
                    textAlign: TextAlign.center,
                    style: _fuente(22, acento),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    gano
                        ? 'Tu preparación dio resultado. El GTD baja un poco.'
                        : 'Con más preparación irá mejor. El GTD sube un poco.',
                    textAlign: TextAlign.center,
                    style: _fuente(13, const Color(0xFFB8C4DC), negrita: false),
                  ),
                  if (porTiempo) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Se acabó el tiempo: se decidió por quién quedó mejor preparado.',
                      textAlign: TextAlign.center,
                      style: _fuente(11, const Color(0xFF8795B5), negrita: false),
                    ),
                  ],
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: _Cinta(texto: 'CONTINUAR', color: const Color(0xFFB8862B), grande: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// Piezas de interfaz en estilo pixel art (azul marino + dorado)
// =====================================================================

const Color _marinoOscuro = Color(0xFF05070F);
const Color _marino = Color(0xFF071D3B);
const Color _oro = Color(0xFFC9962F);
const Color _oroClaro = Color(0xFFE8C46A);

/// Texto con la fuente pixelada del juego (assets/fonts/PixelifySans.ttf).
TextStyle _fuente(double tam, Color color, {bool negrita = true, List<Shadow>? sombras}) {
  return TextStyle(
    fontFamily: 'PixelifySans',
    fontSize: tam,
    color: color,
    height: 1.1,
    fontVariations: [FontVariation('wght', negrita ? 700 : 500)],
    shadows: sombras ?? const [Shadow(color: _marinoOscuro, offset: Offset(1, 1))],
  );
}

/// Marco de placa: borde oscuro, filete dorado y fondo azul marino, con
/// esquinas cuadradas (sin redondeo) para mantener el look de 16 bits.
class _MarcoPixel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color fondo;
  final Color filete;

  const _MarcoPixel({
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.fondo = _marino,
    this.filete = _oro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _marinoOscuro,
      padding: const EdgeInsets.all(2),
      child: Container(
        color: filete,
        padding: const EdgeInsets.all(2),
        child: Container(
          color: _marinoOscuro,
          padding: const EdgeInsets.all(1),
          child: Container(
            color: fondo,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Cinta de rol ("PROFESOR", "ESTUDIANTE"...).
class _Cinta extends StatelessWidget {
  final String texto;
  final Color color;
  final bool grande;

  const _Cinta({required this.texto, required this.color, this.grande = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _marinoOscuro,
      padding: const EdgeInsets.all(1.5),
      child: Container(
        color: color,
        padding: EdgeInsets.symmetric(horizontal: grande ? 22 : 7, vertical: grande ? 6 : 1),
        child: Text(texto, style: _fuente(grande ? 15 : 9, Colors.white)),
      ),
    );
  }
}

/// Barra de vida segmentada (bloques de color plano). La parte blanca es
/// la "estela" del daño reciente.
class _BarraPixelPainter extends CustomPainter {
  final double real;
  final double estela;
  final bool desdeIzquierda;

  _BarraPixelPainter({required this.real, required this.estela, required this.desdeIzquierda});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    const segmentos = 20;
    final ancho = size.width;
    final alto = size.height;

    p.color = _marinoOscuro;
    canvas.drawRect(Rect.fromLTWH(0, 0, ancho, alto), p);

    final anchoSeg = (ancho - 2) / segmentos;
    final colorVida = real > 0.55
        ? const Color(0xFF3DDC5A)
        : (real > 0.25 ? const Color(0xFFFFC107) : const Color(0xFFFF4D4D));
    final colorLuz = Color.lerp(colorVida, Colors.white, 0.4)!;

    for (int i = 0; i < segmentos; i++) {
      final idx = desdeIzquierda ? i : segmentos - 1 - i;
      final x = 1 + i * anchoSeg;
      final umbral = (idx + 1) / segmentos;
      final inicio = idx / segmentos;
      final llenoReal = real >= umbral - 0.0001 || real > inicio + 0.5 / segmentos;
      final llenoEstela = estela > inicio + 0.5 / segmentos;

      Color color;
      if (llenoReal) {
        color = colorVida;
      } else if (llenoEstela) {
        color = const Color(0xFFFFFFFF);
      } else {
        color = const Color(0xFF1A2540);
      }
      canvas.drawRect(Rect.fromLTWH(x.floorToDouble(), 1, (anchoSeg - 1).ceilToDouble(), alto - 2), p..color = color);
      if (llenoReal) {
        // Línea de luz superior en cada bloque.
        canvas.drawRect(Rect.fromLTWH(x.floorToDouble(), 1, (anchoSeg - 1).ceilToDouble(), 2), p..color = colorLuz);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarraPixelPainter old) =>
      old.real != real || old.estela != estela || old.desdeIzquierda != desdeIzquierda;
}

/// Botón táctil cuadrado con marco dorado. Al presionarlo se hunde 2 px
/// y se ilumina. Usa `Listener` para permitir varios botones a la vez.
class _BotonControl extends StatefulWidget {
  final String accion;
  final IconData icono;
  final String? etiqueta;
  final Color color;
  final double tamano;
  final InputManager input;

  const _BotonControl({
    required this.accion,
    required this.icono,
    required this.input,
    this.etiqueta,
    this.color = _marino,
    this.tamano = 52,
  });

  @override
  State<_BotonControl> createState() => _BotonControlState();
}

class _BotonControlState extends State<_BotonControl> {
  bool _presionado = false;

  void _set(bool v) {
    if (_presionado == v) return;
    setState(() => _presionado = v);
    if (v) {
      widget.input.press(widget.accion);
    } else {
      widget.input.release(widget.accion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fondo = _presionado ? Color.lerp(widget.color, Colors.white, 0.35)! : widget.color;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: Transform.translate(
        offset: Offset(0, _presionado ? 2 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.tamano,
              height: widget.tamano,
              child: _MarcoPixel(
                padding: EdgeInsets.zero,
                fondo: fondo,
                filete: _presionado ? _oroClaro : _oro,
                child: Center(child: Icon(widget.icono, color: Colors.white, size: widget.tamano * 0.52)),
              ),
            ),
            if (widget.etiqueta != null) ...[
              const SizedBox(height: 2),
              Text(widget.etiqueta!, style: _fuente(9, const Color(0xFFE8C46A))),
            ],
          ],
        ),
      ),
    );
  }
}