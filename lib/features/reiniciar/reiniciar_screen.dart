import 'package:flutter/material.dart';

/// Pantalla de reinicio del recorrido (US-09).
///
/// Permite al jugador reiniciar el recorrido completo, borrando el progreso
/// actual y volviendo al estado inicial.
///
/// Debe mostrarse como opción en el menú principal o al finalizar una partida.
class ReiniciarScreen extends StatelessWidget {
  final VoidCallback onReiniciar;
  final VoidCallback onVolver;

  const ReiniciarScreen({
    super.key,
    required this.onReiniciar,
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Reiniciar recorrido'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onVolver,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              '¿Reiniciar el recorrido?',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Se borrará todo tu progreso actual: etapas completadas, '
              'nivel de estrés, decisiones tomadas e insignias obtenidas. '
              'Esta acción no se puede deshacer.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onReiniciar,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Sí, reiniciar'),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onVolver,
              icon: const Icon(Icons.cancel),
              label: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}
