import 'package:flutter/material.dart';
import '../../core/contenido_escena.dart';
import '../../core/estado_juego.dart';

/// EJEMPLO ILUSTRATIVO — no es una implementación real de ninguna historia
/// del backlog, solo demuestra cómo se conecta el contrato
/// `ContenidoEscena` con `estadoJuego`. Bórralo cuando implementes la
/// primera historia de jugabilidad de verdad (US-06, gestión del tiempo,
/// es la candidata natural por no depender de nada más).
///
/// Patrón a seguir para una historia real:
/// 1. Crea tu propia carpeta en `features/` (p. ej. `features/gestion_tiempo/`).
/// 2. Implementa `ContenidoEscena` con la interacción real de esa historia.
/// 3. Regístrala en `registro_inicial.dart`:
///    `registroContenidoEscenas['D'] = GestionTiempoContenido();`
class EjemploContenidoEscena implements ContenidoEscena {
  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ejemplo de contenido jugable conectado a estadoJuego'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              // Así es como una historia real actualizaría el estado antes
              // de señalar que la escena terminó.
              estadoJuego.completarEtapa();
              estadoJuego.ajustarEstres(-10);
              onCompletada();
            },
            child: const Text('Completar esta etapa (ejemplo)'),
          ),
        ],
      ),
    );
  }
}
