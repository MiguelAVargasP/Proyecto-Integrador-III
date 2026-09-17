import 'package:flutter/material.dart';
import '../../core/contenido_escena.dart';
import 'modelo/dialogo_linea.dart';
import 'pantallas/dialogo_screen.dart';

/// `ContenidoEscena` genérico para escenas que solo necesitan mostrar
/// diálogo/texto descriptivo (con o sin opciones) — la mayoría de los
/// edificios del campus, al menos hasta que alguno necesite una mecánica
/// jugable propia (como el parcial simulado en el Bloque D).
///
/// A diferencia de la primera versión, esto YA NO dibuja el diálogo
/// dentro del `AppBar` de `EscenaScreen` — abre `DialogoScreen` a
/// pantalla completa (sin franja blanca robándole espacio a la
/// ilustración), igual que `ParcialContenido` hace con el combate.
///
/// Uso en `registro_inicial.dart`:
/// ```dart
/// registroContenidoEscenas['A'] = DialogoContenido([
///   DialogoLinea('Aquí va el texto...', imagen: 'bloque_a_fachada.png'),
///   DialogoLinea('¿Quieres saber más?', opciones: [
///     OpcionDialogo('Sí'),
///     OpcionDialogo('No', saltarA: 3),
///   ]),
/// ]);
/// ```
///
/// Cuando el jugador termina el diálogo y vuelve, se llama
/// `onCompletada` (el mismo contrato de `ContenidoEscena`) y el mapa
/// marca la escena como visitada (RF-04) igual que cualquier otra.
class DialogoContenido implements ContenidoEscena {
  final List<DialogoLinea> lineas;

  const DialogoContenido(this.lineas);

  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return _LanzadorDialogo(lineas: lineas, onCompletada: onCompletada);
  }
}

/// Widget puente: apenas se construye, empuja `DialogoScreen` a pantalla
/// completa. Su propio `build()` solo pinta negro por el instante
/// brevísimo antes de que la navegación ocurra — nunca se ve el AppBar
/// de `EscenaScreen` de forma perceptible.
class _LanzadorDialogo extends StatefulWidget {
  final List<DialogoLinea> lineas;
  final VoidCallback onCompletada;

  const _LanzadorDialogo({required this.lineas, required this.onCompletada});

  @override
  State<_LanzadorDialogo> createState() => _LanzadorDialogoState();
}

class _LanzadorDialogoState extends State<_LanzadorDialogo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => DialogoScreen(lineas: widget.lineas),
        ),
      );
      widget.onCompletada();
    });
  }

  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.black);
}