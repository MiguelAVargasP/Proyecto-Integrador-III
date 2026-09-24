import 'package:flutter/material.dart';

/// Momento de reflexion tras finalizar una etapa (US-11/RF-11).
///
/// Se muestra al completar una etapa del ciclo estudiantil (FASE_2,
/// FASE_3, D) antes de volver al mapa, ofreciendo un breve espacio de
/// sintesis de lo vivido: el nivel de estres, las horas que se asignaron
/// y un mensaje de cierre.
///
/// Criterio de aceptacion US-11: al finalizar al menos una etapa se presenta
/// un breve espacio de reflexion o sintesis.
class ReflexionEtapa extends StatelessWidget {
  final String nombreEtapa;
  final int nivelEstres;
  final Map<String, int> tiempoPorActividad;
  final String? decision;
  final VoidCallback onContinuar;

  const ReflexionEtapa({
    super.key,
    required this.nombreEtapa,
    required this.nivelEstres,
    required this.tiempoPorActividad,
    this.decision,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        title: const Text('Reflexion'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onContinuar,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has completado "$nombreEtapa".\n\n'
              'Tomate un momento para reflexionar sobre lo que viviste:\n\n'
              '• Como se sintio tu nivel de estres?',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Card(
              color: const Color(0xFF141824),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de esta etapa',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _filaResumen(
                      'Nivel de estres',
                      '$nivelEstres / 100',
                      nivelEstres < 30
                          ? Colors.greenAccent
                          : nivelEstres < 70
                              ? Colors.amberAccent
                              : Colors.redAccent,
                    ),
                    const SizedBox(height: 8),
                    if (tiempoPorActividad.isNotEmpty) ...[
                      const Text(
                        'Horas asignadas:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      ...tiempoPorActividad.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 2),
                        child: Text(
                          '${e.key}: ${e.value} horas',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onContinuar,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaResumen(String label, String valor, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(valor, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
