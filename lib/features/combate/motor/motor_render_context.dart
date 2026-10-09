import 'dart:ui';

/// Reemplazo del `Renderer` de Pygame para Flutter. Envuelve directamente
/// un `Canvas` de `dart:ui` (la capa de dibujo más baja de Flutter, no un
/// widget) — así el motor de combate no depende de widgets de Flutter,
/// solo de primitivas de dibujo, igual que el original solo dependía de
/// las primitivas de dibujo de Pygame, no de todo Pygame.
///
/// A diferencia del original (que escalaba una superficie interna de baja
/// resolución con `pygame.transform.scale`), aquí se dibuja directamente
/// al tamaño real del `CustomPaint` — Flutter ya maneja el escalado de
/// forma eficiente por su cuenta. El parámetro [internalSize] se conserva
/// como referencia de las proporciones de diseño (320x180) por si más
/// adelante se necesita, pero no se usa para reescalar manualmente.
class MotorRenderContext {
  final Canvas canvas;
  final Size internalSize;

  double _offsetX = 0.0;
  double _offsetY = 0.0;

  MotorRenderContext(this.canvas, this.internalSize);

  /// Define el desplazamiento de cámara usado por los métodos de dibujo en
  /// espacio de mundo (no afecta a los métodos `*Ui`).
  void setCameraOffset(double x, double y) {
    _offsetX = x;
    _offsetY = y;
  }

  void clear(Color color) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, internalSize.width, internalSize.height),
      Paint()..color = color,
    );
  }

  /// Dibuja un rectángulo en espacio de mundo (afectado por la cámara).
  void drawRect(double x, double y, double width, double height, Color color,
      {bool filled = true}) {
    final rect = Rect.fromLTWH(x - _offsetX, y - _offsetY, width, height);
    final paint = Paint()..color = color;
    if (!filled) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
    }
    canvas.drawRect(rect, paint);
  }

  /// Dibuja un rectángulo en espacio de pantalla (ignora la cámara; usado
  /// por la UI: barras de vida, textos, etc.).
  void drawRectUi(double x, double y, double width, double height, Color color,
      {bool filled = true}) {
    final rect = Rect.fromLTWH(x, y, width, height);
    final paint = Paint()..color = color;
    if (!filled) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
    }
    canvas.drawRect(rect, paint);
  }

  /// Dibuja una línea en espacio de mundo (afectada por la cámara).
  void drawLine(Offset start, Offset end, Color color, {double width = 1}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;
    canvas.drawLine(
      Offset(start.dx - _offsetX, start.dy - _offsetY),
      Offset(end.dx - _offsetX, end.dy - _offsetY),
      paint,
    );
  }

  /// Dibuja texto en espacio de mundo (afectado por la cámara). Se usa
  /// para depuración (nombre del estado actual, etc.) — no es un sistema
  /// de fuentes de juego, solo `dart:ui` puro, igual que el resto del
  /// contexto de render.
  void drawTextUi(String text, double x, double y, Color color, {double fontSize = 10}) {
    final builder = ParagraphBuilder(ParagraphStyle(fontSize: fontSize))
      ..pushStyle(TextStyle(color: color))
      ..addText(text);
    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: 200));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }

  // drawSprite queda para cuando existan assets reales (Etapa 3 en
  // adelante ya usa formas geométricas de depuración en su lugar).
}