import 'dart:ui';
import '../motor/component.dart';
import '../motor/motor_render_context.dart';

/// Fondo de la arena en pixel art: un aula de examen con colores planos
/// (sin degradados ni antialiasing), paleta azul marino + dorado como el
/// resto de la interfaz. Todo con rectángulos enteros en el espacio
/// lógico 320x180, así que escala como un fondo de 16 bits.
class ArenaFondo extends Component {
  final double ancho;
  final double alto;
  final double ySuelo;

  final Paint _p = Paint()..isAntiAlias = false;
  double _t = 0.0;

  static const Color _marino0 = Color(0xFF0B1226);
  static const Color _marino1 = Color(0xFF11204A);
  static const Color _marino2 = Color(0xFF182C5C);
  static const Color _marino3 = Color(0xFF213872);
  static const Color _oro = Color(0xFFC9962F);
  static const Color _oroClaro = Color(0xFFE8C46A);

  ArenaFondo({required this.ancho, required this.alto, required this.ySuelo});

  @override
  void update(double delta) {
    _t += delta;
  }

  void _r(Canvas c, double x, double y, double w, double h, Color color) {
    c.drawRect(Rect.fromLTWH(x, y, w, h), _p..color = color);
  }

  @override
  void render(MotorRenderContext renderer) {
    final c = renderer.canvas;

    // ---- Pared en franjas planas con transición "dither" (tablero de
    // 2 px) entre una franja y la siguiente.
    _r(c, -12, -12, ancho + 24, 48, _marino0);
    _r(c, -12, 36, ancho + 24, 44, _marino1);
    _r(c, -12, 80, ancho + 24, 44, _marino2);
    _r(c, -12, 124, ancho + 24, ySuelo - 124, _marino3);
    // dither en los cortes
    final cortes = <double, List<Color>>{
      36.0: [_marino1, _marino0],
      80.0: [_marino2, _marino1],
      124.0: [_marino3, _marino2],
    };
    cortes.forEach((corte, colores) {
      for (double x = -12; x < ancho + 12; x += 4) {
        _r(c, x, corte - 2, 2, 2, colores[0]);
        _r(c, x + 2, corte, 2, 2, colores[1]);
      }
    });

    // ---- Ventanales.
    for (final x in [22.0, 242.0]) {
      _ventana(c, x, 16, 56, 62);
    }

    // ---- Pizarrón central.
    const bx = 112.0, by = 20.0, bw = 96.0, bh = 44.0;
    _r(c, bx - 3, by - 3, bw + 6, bh + 6, _marino0);
    _r(c, bx - 2, by - 2, bw + 4, bh + 4, const Color(0xFF6B4A2B));
    _r(c, bx, by, bw, bh, const Color(0xFF16322A));
    _r(c, bx, by, bw, 1, const Color(0xFF24503F));
    _texto(c, 'PARCIAL', ancho / 2, by + 6, 14, const Color(0xFFFFFFFF));
    _texto(c, 'Ingeniería · UPB', ancho / 2, by + 26, 7, const Color(0xFFB8D4C8));
    // trazos de tiza
    _r(c, bx + 8, by + 36, 24, 1, const Color(0x99FFFFFF));
    _r(c, bx + bw - 32, by + 36, 24, 1, const Color(0x99FFFFFF));
    // repisa del pizarrón con tiza
    _r(c, bx, by + bh + 2, bw, 2, const Color(0xFF6B4A2B));
    _r(c, bx + 8, by + bh + 1, 6, 1, const Color(0xFFFFFFFF));
    _r(c, bx + 16, by + bh + 1, 4, 1, const Color(0xFFFFE08A));

    // ---- Pupitres del fondo (siluetas).
    for (double x = 6; x < ancho; x += 50) {
      _pupitre(c, x, ySuelo - 26);
    }

    // ---- Zócalo azul con filetes dorados (como las placas de la UI).
    _r(c, -12, ySuelo - 20, ancho + 24, 20, _marino0);
    _r(c, -12, ySuelo - 20, ancho + 24, 2, _oro);
    _r(c, -12, ySuelo - 18, ancho + 24, 1, _oroClaro);
    for (double x = -12; x < ancho + 12; x += 32) {
      _r(c, x, ySuelo - 16, 1, 16, _marino2);
    }

    // ---- Piso de madera: tablones de 2 tonos con juntas.
    final alturaPiso = alto + 12 - ySuelo;
    _r(c, -12, ySuelo, ancho + 24, alturaPiso, const Color(0xFF8A5A33));
    _r(c, -12, ySuelo, ancho + 24, 1, const Color(0xFFB5834F)); // brillo superior
    int fila = 0;
    for (double y = ySuelo + 1; y < alto + 12; y += 6) {
      _r(c, -12, y + 5, ancho + 24, 1, const Color(0xFF4A2C16)); // junta horizontal
      final desfase = (fila % 2 == 0) ? 0.0 : 18.0;
      for (double x = -12 + desfase; x < ancho + 12; x += 36) {
        _r(c, x, y, 1, 5, const Color(0xFF4A2C16)); // junta vertical
        _r(c, x + 2, y + 1, 10, 1, const Color(0xFF9B6A3E)); // veta
      }
      if (fila % 2 == 1) {
        _r(c, -12, y, ancho + 24, 5, const Color(0x1A000000)); // tablón más oscuro
      }
      fila++;
    }
  }

  void _ventana(Canvas c, double x, double y, double w, double h) {
    _r(c, x - 3, y - 3, w + 6, h + 6, _marino0);
    _r(c, x - 2, y - 2, w + 4, h + 4, const Color(0xFF8A5A33));
    _r(c, x, y, w, h, const Color(0xFF5FA8E8));
    _r(c, x, y, w, h / 2, const Color(0xFF9CD0F5));
    // reflejos diagonales
    for (int i = 0; i < 5; i++) {
      _r(c, x + 6 + i * 2.0, y + 22 - i * 4.0, 2, 2, const Color(0xFFFFFFFF));
    }
    // nubes (se desplazan despacio, saltos de 1 px)
    final nube = ((_t * 4.0) % (w + 20)).floorToDouble();
    _r(c, x + (nube - 14).clamp(0.0, w - 12.0), y + 8, 12, 3, const Color(0xE6FFFFFF));
    // travesaños
    _r(c, x + w / 2 - 1, y, 2, h, const Color(0xFF8A5A33));
    _r(c, x, y + h / 2 - 1, w, 2, const Color(0xFF8A5A33));
    // alféizar
    _r(c, x - 4, y + h + 1, w + 8, 3, const Color(0xFFC9962F));
    _r(c, x - 4, y + h + 1, w + 8, 1, const Color(0xFFE8C46A));
  }

  void _pupitre(Canvas c, double x, double y) {
    const sil = Color(0xFF070C1A);
    _r(c, x, y, 34, 4, sil); // tablero
    _r(c, x + 3, y + 4, 2, 22, sil); // patas
    _r(c, x + 29, y + 4, 2, 22, sil);
    _r(c, x + 10, y + 6, 14, 10, sil); // espaldar
    _r(c, x + 12, y + 16, 2, 10, sil);
    _r(c, x + 20, y + 16, 2, 10, sil);
  }

  void _texto(Canvas c, String texto, double cx, double y, double tam, Color color) {
    final builder = ParagraphBuilder(ParagraphStyle(
      fontFamily: 'PixelifySans',
      fontSize: tam,
      textAlign: TextAlign.center,
    ))
      ..pushStyle(TextStyle(
        fontFamily: 'PixelifySans',
        color: color,
        letterSpacing: 1.0,
        fontVariations: const [FontVariation('wght', 700)],
      ))
      ..addText(texto);
    final parrafo = builder.build()..layout(const ParagraphConstraints(width: 90));
    c.drawParagraph(parrafo, Offset((cx - 45).roundToDouble(), y.roundToDouble()));
  }
}