import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../models/escena_campus.dart';
import '../state/estado_mapa.dart';
import '../widgets/hotspot_escena.dart';
import 'escena_screen.dart';

/// RF-01: mapa ilustrado del campus como punto de entrada visual a las
/// escenas del juego. Esta es la pantalla de inicio del recorrido jugable.
class MapaCampusScreen extends StatefulWidget {
  const MapaCampusScreen({super.key});

  @override
  State<MapaCampusScreen> createState() => _MapaCampusScreenState();
}

class _MapaCampusScreenState extends State<MapaCampusScreen> {
  /// Margen fijo reservado arriba para que los íconos de la barra de
  /// estado (hora, señal, batería) no tapen el marcador L.
  ///
  /// CRÍTICO: se usa un valor fijo en vez de `SafeArea`/
  /// `MediaQuery.padding.top` a propósito. En algunos emuladores (según
  /// cómo simulan el notch en modo horizontal), el sistema reporta un
  /// "safe area" superior mucho más grande de lo que realmente ocupa la
  /// barra de estado — SafeArea respeta ese valor tal cual venga, y
  /// terminaba dejando una franja negra enorme sin necesidad. 28px
  /// alcanza para despejar los íconos en la inmensa mayoría de
  /// dispositivos reales sin desperdiciar espacio de más.
  static const double _margenSuperior = 28;

  @override
  void initState() {
    super.initState();
    // Repinta los hotspots cuando cambie la escena actual/visitada (RF-03).
    estadoMapa.addListener(_onEstadoCambiado);
  }

  @override
  void dispose() {
    estadoMapa.removeListener(_onEstadoCambiado);
    super.dispose();
  }

  void _onEstadoCambiado() => setState(() {});

  Future<void> _irAEscena(EscenaCampus escena) async {
    estadoMapa.seleccionarEscena(escena.id);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EscenaScreen(escena: escena)),
    );
    // Al volver del Navigator.pop de EscenaScreen, el mapa ya refleja el
    // marcador de "escena actual" gracias al listener de estadoMapa.
  }

  /// Utilidad SOLO de desarrollo: mantén presionado sobre el mapa para
  /// imprimir en consola la posición fraccional exacta del toque, y así
  /// calibrar `posicionRelativa` en escena_campus.dart contra el asset
  /// real. Las coordenadas que imprime son relativas al recuadro del
  /// mapa, que es exactamente el sistema de coordenadas que usa
  /// `escena_campus.dart`.
  void _debugImprimirCoordenada(
      LongPressStartDetails details, BoxConstraints constraints) {
    if (!kDebugMode) return;
    final dx = details.localPosition.dx / constraints.maxWidth;
    final dy = details.localPosition.dy / constraints.maxHeight;
    debugPrint(
        'Coordenada fraccional tocada: Offset(${dx.toStringAsFixed(2)}, ${dy.toStringAsFixed(2)})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: _margenSuperior),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ancho = constraints.maxWidth;
            final alto = constraints.maxHeight;

            return GestureDetector(
              onLongPressStart: (details) =>
                  _debugImprimirCoordenada(details, constraints),
              child: Stack(
                children: [
                  // Sin AspectRatio: la imagen se estira para llenar
                  // exactamente el espacio disponible, sin franjas
                  // laterales.
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/mapa_campus.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  for (final escena in escenasCampus)
                    Positioned(
                      left: escena.posicionRelativa.dx * ancho -
                          HotspotEscena.tamano / 2,
                      top: escena.posicionRelativa.dy * alto -
                          HotspotEscena.tamano / 2,
                      child: HotspotEscena(
                        escena: escena,
                        esActual: estadoMapa.esEscenaActual(escena.id),
                        visitada: estadoMapa.fueVisitada(escena.id),
                        onTap: () => _irAEscena(escena),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}