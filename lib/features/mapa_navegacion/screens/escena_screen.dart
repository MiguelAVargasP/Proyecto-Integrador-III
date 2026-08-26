import 'package:flutter/material.dart';
import '../../../core/registro_contenido_escenas.dart';
import '../models/escena_campus.dart';

/// Pantalla de escena a la que llega el jugador al seleccionar un edificio
/// en el mapa (RF-02/RF-03).
///
/// No contiene jugabilidad propia: consulta `registroContenidoEscenas`
/// para saber si ya existe una implementación para esta escena (ver
/// `core/contenido_escena.dart`). Si no la hay, muestra un placeholder que
/// confirma que la navegación funciona, sin bloquear el desarrollo de las
/// demás historias.
class EscenaScreen extends StatelessWidget {
  final EscenaCampus escena;

  const EscenaScreen({super.key, required this.escena});

  @override
  Widget build(BuildContext context) {
    final contenido = registroContenidoEscenas[escena.id];

    return Scaffold(
      appBar: AppBar(title: Text(escena.nombre)),
      body: contenido != null
          ? contenido.construir(
              context,
              () => Navigator.of(context).pop(),
            )
          : _PlaceholderEscena(escena: escena),
    );
  }
}

class _PlaceholderEscena extends StatelessWidget {
  final EscenaCampus escena;
  const _PlaceholderEscena({required this.escena});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Escena "${escena.nombre}" (${escena.id})',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Todavía no tiene contenido jugable registrado.'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Volver al mapa'),
          ),
        ],
      ),
    );
  }
}