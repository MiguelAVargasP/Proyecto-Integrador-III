import 'dart:math';
import 'package:flutter/material.dart';

/// Modelo de evento imprevisto universitario (US-07 / RF-07).
///
/// Cada evento tiene un texto descriptivo, un impacto de estrés y una
/// opcion de como reaccionar. El jugador puede aceptar el evento y su
/// consecuencia, o intentar manejarlo (lo que puede reducir el impacto).
///
/// Criterio de aceptacion US-07: se incluye al menos un evento imprevisto
/// dentro del recorrido.
class EventoImprevisto {
  final String titulo;
  final String descripcion;
  final int impactoEstres; // positivo = aumenta estrés
  final String consejo;

  const EventoImprevisto({
    required this.titulo,
    required this.descripcion,
    required this.impactoEstres,
    required this.consejo,
  });

  /// Aplica el evento: devuelve el delta de estrés (puede reducirse
  /// si el jugador elige reaccionar).
  int aplicar(bool reacciono) {
    // Si reacciono, reducimos la mitad del impacto (manejo activo).
    return reacciono ? (impactoEstres / 2).round() : impactoEstres;
  }

  static final List<EventoImprevisto> eventosDisponibles = [
    const EventoImprevisto(
      titulo: 'Cambio de horario de clase',
      descripcion:
          'Tu profesor anuncio un cambio de horario de ultima hora. '
          'Tendras que reajustar tu agenda de estudio.',
      impactoEstres: 10,
      consejo: 'Reorganiza tus horas de estudio en consecuencia.',
    ),
    const EventoImprevisto(
      titulo: 'Entrega tardia',
      descripcion:
          'Un grupo de trabajo te pide ayuda con una entrega que vence '
          'esta noche. Demoraste un trabajo importante.',
      impactoEstres: 15,
      consejo: 'Prioriza y negocia plazos si es posible.',
    ),
    const EventoImprevisto(
      titulo: 'Examen sorpresa',
      descripcion:
          'El profesor anuncia un examen corto la proxima clase. '
          'No tenias el tema en tu plan de estudio esta semana.',
      impactoEstres: 12,
      consejo: 'Repasa lo esencial y descansa antes del examen.',
    ),
    const EventoImprevisto(
      titulo: 'Problema de transporte',
      descripcion:
          'El bus universitario tuvo un desperfecto y llegas tarde por '
          'primera vez en el semestre.',
      impactoEstres: 8,
      consejo: 'Considera alternativas de transporte o sal temprano.',
    ),
    const EventoImprevisto(
      titulo: 'Conflicto de grupo',
      descripcion:
          'Un companero de grupo no cumple con su parte del trabajo. '
          'Tienes que decidir como proceder.',
      impactoEstres: 14,
      consejo: 'Comunica el problema al profesor si es recurrente.',
    ),
    const EventoImprevisto(
      titulo: 'Emergencia familiar',
      descripcion:
          'Un familiar requiere tu atencion inesperadamente. '
          'Debes balancear lo academico con lo personal.',
      impactoEstres: 20,
      consejo: 'Comunica la situacion a tus docentes si es necesario.',
    ),
    const EventoImprevisto(
      titulo: 'Plaga de parciales',
      descripcion:
          'Dos de tus materias coinciden examenes el mismo dia. '
          'Tienes que repartir tu tiempo de repaso.',
      impactoEstres: 18,
      consejo: 'Haz prioridades segun el peso de cada examen.',
    ),
    const EventoImprevisto(
      titulo: 'Falla de internet',
      descripcion:
          'El internet universitario falla en el momento de entregar '
          'un trabajo online. ¡Casi pierdes la entrega!',
      impactoEstres: 12,
      consejo: 'Ten siempre un plan B: datos moviles, descarga anticipada.',
    ),
  ];

  /// Devuelve un evento aleatorio de la lista.
  static EventoImprevisto aleatorio(Random r) {
    return eventosDisponibles[r.nextInt(eventosDisponibles.length)];
  }
}

/// Widget para mostrar un evento imprevisto y permitir reaccionar (US-07).
class EventoImprevistoWidget extends StatelessWidget {
  final EventoImprevisto evento;
  final bool reacciono;
  final VoidCallback onAceptar;

  const EventoImprevistoWidget({
    super.key,
    required this.evento,
    required this.reacciono,
    required this.onAceptar,
  });

  @override
  Widget build(BuildContext context) {
    final deltaStr = reacciono
        ? '(-${evento.impactoEstres ~/ 2} estres)'
        : '(+${evento.impactoEstres} estres)';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        title: Text(evento.titulo, style: const TextStyle(color: Colors.amberAccent)),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.warning_amber),
          onPressed: onAceptar,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              evento.descripcion,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF141824),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, size: 20, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Impacto: $deltaStr',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Consejo: ${evento.consejo}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onAceptar,
              style: FilledButton.styleFrom(
                backgroundColor: reacciono ? Colors.greenAccent : Colors.redAccent,
              ),
              child: Text(reacciono
                  ? '¡Reaccione y redujo el impacto!'
                  : 'Aceptar consecuencia'),
            ),
          ],
        ),
      ),
    );
  }
}
