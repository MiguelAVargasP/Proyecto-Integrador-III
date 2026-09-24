import 'package:flutter/material.dart';
import '../../../core/contenido_escena.dart';
import '../../../core/estado_juego.dart';
import '../../../features/mapa_navegacion/state/estado_mapa.dart';
import '../pantallas/parcial_combate_screen.dart';

/// Contenido jugable de la escena del parcial simulado (RF-05, RF-08).
/// Implementa el contrato `ContenidoEscena` (ver `core/contenido_escena.dart`)
/// para que el mapa pueda navegar aquí como a cualquier otra escena, sin
/// que `MapaCampusScreen` ni `EscenaScreen` necesiten saber nada de
/// Fighting Deck.
///
/// Flujo: al entrar se muestra una pantalla previa con el estrés
/// acumulado y un botón para empezar; al presionarlo se abre
/// `ParcialCombateScreen` (pantalla completa, sin el AppBar de
/// `EscenaScreen`, porque el combate necesita todo el espacio). Cuando el
/// combate termina y el jugador vuelve, se llama `onCompletada` para que
/// el mapa marque la escena como visitada igual que las demás (RF-04).
class ParcialContenido implements ContenidoEscena {
  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return _ParcialIntro(onCompletada: onCompletada);
  }
}

class _ParcialIntro extends StatelessWidget {
  final VoidCallback onCompletada;
  const _ParcialIntro({required this.onCompletada});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Es hora del primer parcial.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nivel de estrés acumulado: ${estadoJuego.nivelEstres}/100',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Presentar el parcial'),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const ParcialCombateScreen(),
                  ),
                );
                onCompletada();
                estadoMapa.completarEtapa('D');
              },
            ),
          ],
        ),
      ),
    );
  }
}