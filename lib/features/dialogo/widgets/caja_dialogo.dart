import 'package:flutter/material.dart';
import '../../../core/estado_juego.dart';
import '../modelo/dialogo_linea.dart';

/// Muestra una lista de [DialogoLinea] una por una, en una caja de texto
/// estilo novela visual anclada abajo, con la ilustración de fondo de la
/// escena y el retrato de quien habla (si tiene uno). Tocar en cualquier
/// parte (cuando la línea no tiene opciones) avanza a la siguiente
/// línea; cuando la línea sí tiene opciones, se muestran como botones y
/// cada una decide a dónde salta el diálogo. Al llegar al final llama
/// [onFinalizado].
///
/// Es intencionalmente genérico: no sabe nada de UPB, edificios ni del
/// mapa — cualquier escena futura que solo necesite mostrar texto (con o
/// sin opciones/retrato) puede reutilizar este mismo widget con líneas
/// distintas.
class CajaDialogo extends StatefulWidget {
  final List<DialogoLinea> lineas;
  final VoidCallback onFinalizado;

  const CajaDialogo({
    super.key,
    required this.lineas,
    required this.onFinalizado,
  });

  @override
  State<CajaDialogo> createState() => _CajaDialogoState();
}

class _CajaDialogoState extends State<CajaDialogo> {
  int _indice = 0;

  void _irA(int indice) {
    if (indice < 0 || indice >= widget.lineas.length) {
      widget.onFinalizado();
      return;
    }
    setState(() => _indice = indice);
  }

  void _avanzar() {
    final actual = widget.lineas[_indice];
    if (actual.esFinal) {
      widget.onFinalizado();
      return;
    }
    if (actual.siguienteLinea != null) {
      _irA(actual.siguienteLinea!);
      return;
    }
    _irA(_indice + 1);
  }

  void _elegirOpcion(OpcionDialogo opcion) {
    // Aplica el efecto de la elección sobre EstadoJuego (si tiene alguno)
    // antes de navegar — así la decisión queda registrada sin importar a
    // qué línea salte después.
    if (opcion.deltaEstres != null) {
      estadoJuego.ajustarEstres(opcion.deltaEstres!);
    }
    if (opcion.decisionRegistrada != null) {
      estadoJuego.registrarDecision(opcion.decisionRegistrada!);
    }
    if (opcion.insignia != null) {
      estadoJuego.otorgarInsignia(opcion.insignia!);
    }

    if (opcion.saltarA != null) {
      _irA(opcion.saltarA!);
    } else {
      _avanzar();
    }
  }

  /// Fondo de la escena. Si `imagen` no está definida o el archivo no
  /// existe todavía en `assets/images/escenarios/`, cae a un color
  /// sólido con un aviso — así nunca truena la app por un asset
  /// faltante, solo se ve un color plano hasta que exista el archivo.
  Widget _fondoEscena(DialogoLinea linea) {
    if (linea.imagen == null) {
      return Container(color: const Color(0xFF10151F));
    }
    return Image.asset(
      'assets/images/escenarios/${linea.imagen}',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF10151F),
        alignment: Alignment.center,
        child: Text(
          'Falta el archivo:\nassets/images/escenarios/${linea.imagen}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ),
    );
  }

  /// Retrato circular de quien habla, si tiene uno asignado.
  Widget? _retrato(DialogoLinea linea) {
    if (linea.retrato == null) return null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/personajes/${linea.retrato}',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 48,
          height: 48,
          color: Colors.white12,
          child: const Icon(Icons.person, color: Colors.white38),
        ),
      ),
    );
  }

  Widget _cajaTexto(DialogoLinea linea, bool esUltima) {
    final tieneOpciones = linea.opciones.isNotEmpty;
    final retrato = _retrato(linea);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (retrato != null) ...[
            retrato,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (linea.hablante.isNotEmpty) ...[
                  Text(
                    linea.hablante,
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  linea.texto,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3),
                ),
                const SizedBox(height: 12),
                if (tieneOpciones)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final opcion in linea.opciones) ...[
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            alignment: Alignment.centerLeft,
                          ),
                          onPressed: () => _elegirOpcion(opcion),
                          child: Text(opcion.texto),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      esUltima ? 'Toca para continuar ▸' : 'Toca para seguir ▸',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lineas.isEmpty) {
      // Sin líneas que mostrar: no bloquear al jugador, avanzar directo.
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFinalizado());
      return const SizedBox.shrink();
    }

    final linea = widget.lineas[_indice];
    final esUltima = linea.esFinal || _indice == widget.lineas.length - 1;
    final tieneOpciones = linea.opciones.isNotEmpty;

    final contenido = Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _fondoEscena(linea)),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: _cajaTexto(linea, esUltima),
        ),
      ],
    );

    // Si la línea tiene opciones, los botones son los que avanzan — no
    // todo el área debe ser tocable, para no saltarse la elección.
    if (tieneOpciones) return contenido;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _avanzar,
      child: contenido,
    );
  }
}