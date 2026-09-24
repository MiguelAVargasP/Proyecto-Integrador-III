import 'package:flutter/material.dart';
import '../../core/contenido_escena.dart';
import '../../core/estado_juego.dart';

/// Implementacion de US-06: Gestion del tiempo del jugador.
///
/// El jugador distribuye horas entre actividades academicas y no academicas.
/// Cada actividad tiene un valor de estres asociado (negativo = calma,
/// positivo = mas estres). Al confirmar, se registra en EstadoJuego y se
/// marca la etapa como completada.
///
/// Uso en registro_inicial.dart:
/// ```dart
/// registroContenidoEscenas['ETAPA_GESTION'] = GestionTiempoContenido();
/// ```
class GestionTiempoContenido implements ContenidoEscena {
  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return _GestionTiempoScreen(onCompletada: onCompletada);
  }
}

class _GestionTiempoScreen extends StatefulWidget {
  final VoidCallback onCompletada;
  const _GestionTiempoScreen({required this.onCompletada});

  @override
  State<_GestionTiempoScreen> createState() => _GestionTiempoScreenState();
}

class _GestionTiempoScreenState extends State<_GestionTiempoScreen>
    with TickerProviderStateMixin {
  // Horas disponibles para distribuir
  int horasDisponibles = 12;

  // Horas asignadas a cada actividad
  final Map<String, int> asignaciones = {
    'Estudio independiente': 0,
    'Clases y seminarios': 0,
    'Trabajo grupal': 0,
    'Descanso y ocio': 0,
    'Bienestar personal': 0,
  };

  // Efectos de estres por actividad (negativo = reduce estres, positivo = aumenta)
  final Map<String, int> estresPorActividad = {
    'Estudio independiente': -3,
    'Clases y seminarios': 0,
    'Trabajo grupal': 2,
    'Descanso y ocio': -5,
    'Bienestar personal': -4,
  };

  void _asignarHoras(String actividad, int horas) {
    final actual = asignaciones[actividad] ?? 0;
    final nueva = actual + horas;
    if (nueva < 0) return;
    setState(() {
      asignaciones[actividad] = nueva;
    });
  }

  int get _totalAsignado => asignaciones.values.fold(0, (a, b) => a + b);

  int get _horasRestantes => horasDisponibles - _totalAsignado;

  bool get _puedeConfirmar =>
      _totalAsignado == horasDisponibles && horasDisponibles > 0;

  void _confirmar() {
    for (final entry in asignaciones.entries) {
      if (entry.value > 0) {
        estadoJuego.registrarTiempo(entry.key, entry.value);
        final deltaEstres = estresPorActividad[entry.key] ?? 0;
        if (deltaEstres != 0) {
          estadoJuego.ajustarEstres(deltaEstres * entry.value);
        }
      }
    }
    estadoJuego.completarEtapa();
    widget.onCompletada();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Distribuye tu tiempo'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Distribuye tus 12 horas disponibles entre las actividades del dia.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Horas disponibles: $horasDisponibles | Asignadas: $_totalAsignado | Restantes: $_horasRestantes',
              style: const TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...asignaciones.keys.map((actividad) {
              final horas = asignaciones[actividad] ?? 0;
              final deltaEstres = estresPorActividad[actividad] ?? 0;
              String estresText;
              if (deltaEstres < 0) {
                estresText =
                    'Reduce estres ($deltaEstres * $horas = ${deltaEstres * horas})';
              } else if (deltaEstres > 0) {
                estresText =
                    'Aumenta estres ($deltaEstres * $horas = ${deltaEstres * horas})';
              } else {
                estresText = 'Sin efecto de estres';
              }
              return Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actividad,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estresText,
                        style: TextStyle(
                          color: deltaEstres < 0
                              ? Colors.greenAccent
                              : (deltaEstres > 0
                                  ? Colors.redAccent
                                  : Colors.white70),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove,
                                color: Colors.redAccent),
                            onPressed: horas > 0
                                ? () => _asignarHoras(actividad, -1)
                                : null,
                          ),
                          Text(
                            '$horas h',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add,
                                color: Colors.greenAccent),
                            onPressed: _horasRestantes > 0
                                ? () => _asignarHoras(actividad, 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _puedeConfirmar ? _confirmar : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar distribucion'),
            ),
            const SizedBox(height: 8),
            if (!_puedeConfirmar)
              Text(
                'Distribuye todas las horas disponibles para continuar.',
                style:
                    TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
