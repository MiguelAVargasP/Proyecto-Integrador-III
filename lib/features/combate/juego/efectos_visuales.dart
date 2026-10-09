import 'dart:math' as math;
import 'dart:ui';
import '../motor/motor_render_context.dart';

/// Efectos del combate en estilo pixel art: chispas cuadradas, anillo de
/// impacto escalonado, números flotantes con la fuente del juego y
/// temblor de pantalla por pasos enteros (para no desalinear los píxeles).
class EfectosVisuales {
  final math.Random _rng = math.Random();
  final List<_Chispa> _chispas = [];
  final List<_TextoFlotante> _textos = [];
  final List<_Onda> _ondas = [];
  final Paint _p = Paint()..isAntiAlias = false;

  double _temblorRestante = 0.0;
  double _temblorDuracion = 1.0;
  double _temblorAmplitud = 0.0;

  /// Desplazamiento del temblor, siempre en píxeles enteros.
  Offset get temblor {
    if (_temblorRestante <= 0.0) return Offset.zero;
    final fuerza = (_temblorAmplitud * (_temblorRestante / _temblorDuracion)).ceilToDouble();
    if (fuerza <= 0.0) return Offset.zero;
    return Offset(
      ((_rng.nextDouble() * 2 - 1) * fuerza).roundToDouble(),
      ((_rng.nextDouble() * 2 - 1) * fuerza).roundToDouble(),
    );
  }

  void temblar({double amplitud = 2.0, double duracion = 0.15}) {
    _temblorAmplitud = amplitud;
    _temblorDuracion = duracion;
    _temblorRestante = duracion;
  }

  void impacto(double x, double y, Color color, {int cantidad = 10, bool fuerte = false}) {
    final n = fuerte ? cantidad * 2 : cantidad;
    for (int i = 0; i < n; i++) {
      final angulo = _rng.nextDouble() * math.pi * 2;
      final velocidad = 40.0 + _rng.nextDouble() * (fuerte ? 140.0 : 90.0);
      _chispas.add(_Chispa(
        x: x,
        y: y,
        vx: math.cos(angulo) * velocidad,
        vy: math.sin(angulo) * velocidad - 20.0,
        vida: 0.25 + _rng.nextDouble() * 0.25,
        tam: _rng.nextBool() ? 2.0 : 1.0,
        color: i.isEven ? color : const Color(0xFFFFF2B0),
      ));
    }
    _ondas.add(_Onda(x: x, y: y, color: color, radioFinal: fuerte ? 16.0 : 10.0));
  }

  void texto(double x, double y, String contenido, Color color, {double tam = 9.0}) {
    _textos.add(_TextoFlotante(x: x, y: y, contenido: contenido, color: color, tam: tam));
  }

  void update(double dt) {
    if (_temblorRestante > 0.0) _temblorRestante -= dt;
    for (final c in _chispas) {
      c.vida -= dt;
      c.vy += 260.0 * dt;
      c.x += c.vx * dt;
      c.y += c.vy * dt;
    }
    _chispas.removeWhere((c) => c.vida <= 0.0);
    for (final t in _textos) {
      t.edad += dt;
      t.y -= 20.0 * dt;
    }
    _textos.removeWhere((t) => t.edad >= 0.8);
    for (final o in _ondas) {
      o.edad += dt;
    }
    _ondas.removeWhere((o) => o.edad >= 0.2);
  }

  void render(MotorRenderContext r) {
    final canvas = r.canvas;

    // Anillo de impacto: cuadrado hueco que crece en pasos de 2 px.
    for (final o in _ondas) {
      final p = (o.edad / 0.2).clamp(0.0, 1.0);
      final lado = ((4.0 + o.radioFinal * p) / 2.0).floorToDouble() * 2.0;
      final alpha = 1.0 - p;
      _p.color = o.color.withValues(alpha: alpha);
      final cx = o.x.roundToDouble(), cy = o.y.roundToDouble();
      canvas.drawRect(Rect.fromLTWH(cx - lado, cy - lado, lado * 2, 1), _p);
      canvas.drawRect(Rect.fromLTWH(cx - lado, cy + lado, lado * 2, 1), _p);
      canvas.drawRect(Rect.fromLTWH(cx - lado, cy - lado, 1, lado * 2), _p);
      canvas.drawRect(Rect.fromLTWH(cx + lado, cy - lado, 1, lado * 2 + 1), _p);
    }

    for (final c in _chispas) {
      final a = (c.vida / 0.5).clamp(0.0, 1.0);
      _p.color = c.color.withValues(alpha: a);
      canvas.drawRect(Rect.fromLTWH(c.x.roundToDouble(), c.y.roundToDouble(), c.tam, c.tam), _p);
    }

    for (final t in _textos) {
      final p = (t.edad / 0.8).clamp(0.0, 1.0);
      final alpha = p < 0.6 ? 1.0 : 1.0 - (p - 0.6) / 0.4;
      _dibujarTexto(canvas, t.contenido, t.x.roundToDouble(), t.y.roundToDouble(), t.tam, t.color.withValues(alpha: alpha));
    }
  }

  static void _dibujarTexto(Canvas canvas, String texto, double x, double y, double tam, Color color) {
    // Contorno oscuro de 1 px (4 desplazamientos) + texto encima.
    final desplazamientos = [
      const Offset(-1, 0),
      const Offset(1, 0),
      const Offset(0, -1),
      const Offset(0, 1),
      Offset.zero,
    ];
    for (final d in desplazamientos) {
      final esFrente = d == Offset.zero;
      final builder = ParagraphBuilder(ParagraphStyle(
        fontFamily: 'PixelifySans',
        fontSize: tam,
        textAlign: TextAlign.center,
      ))
        ..pushStyle(TextStyle(
          fontFamily: 'PixelifySans',
          color: esFrente ? color : const Color(0xFF05070F).withValues(alpha: color.a),
          fontVariations: const [FontVariation('wght', 700)],
        ))
        ..addText(texto);
      final parrafo = builder.build()..layout(const ParagraphConstraints(width: 80));
      canvas.drawParagraph(parrafo, Offset(x - 40 + d.dx, y + d.dy));
    }
  }
}

class _Chispa {
  double x, y, vx, vy, vida, tam;
  final Color color;
  _Chispa({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.vida,
    required this.tam,
    required this.color,
  });
}

class _TextoFlotante {
  double x, y, edad = 0.0, tam;
  final String contenido;
  final Color color;
  _TextoFlotante({
    required this.x,
    required this.y,
    required this.contenido,
    required this.color,
    required this.tam,
  });
}

class _Onda {
  final double x, y, radioFinal;
  final Color color;
  double edad = 0.0;
  _Onda({required this.x, required this.y, required this.color, required this.radioFinal});
}