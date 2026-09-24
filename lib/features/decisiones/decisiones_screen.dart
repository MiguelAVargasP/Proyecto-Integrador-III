import 'package:flutter/material.dart';

/// Pantalla de transparencia sobre decisiones de alto impacto (US-16).
///
/// Muestra al jugador qué decisiones registró durante el recorrido,
/// con su impacto en el estrés y las consecuencias asociadas.
///
/// De acuerdo con RF-16: el sistema advierte antes de decisiones de alto
/// impacto y explica, al final, cuáles decisiones influyeron en el resultado.
class DecisionesScreen extends StatelessWidget {
  final List<String> decisionesTomadas;
  final VoidCallback onVolver;
  final String? titulo;

  const DecisionesScreen({
    super.key,
    required this.decisionesTomadas,
    required this.onVolver,
    this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo ?? 'Decisiones'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onVolver,
        ),
      ),
      body: decisionesTomadas.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 48, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'Aún no has tomado decisiones.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: decisionesTomadas.length,
              itemBuilder: (context, index) {
                final decision = decisionesTomadas[index];
                // Heurística simple: si la decisión contiene palabras clave,
                // clasificarla como de alto impacto.
                final esAltoImpacto = _esDecicionAltoImpacto(decision);
                return Card(
                  color: esAltoImpacto ? Colors.grey[800] : Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          esAltoImpacto ? Icons.warning_amber : Icons.check_circle_outline,
                          color: esAltoImpacto ? Colors.orange : Colors.greenAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                decision,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: esAltoImpacto ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (esAltoImpacto)
                                const Text(
                                  'Decisión de alto impacto',
                                  style: TextStyle(color: Colors.orange, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  bool _esDecicionAltoImpacto(String decision) {
    final palabrasClave = [
      'parcial', 'examen', 'aprobar', 'reprobar', 'estrés',
      'consecuencia', 'registro', 'impacto', 'alto',
    ];
    final lower = decision.toLowerCase();
    return palabrasClave.any((p) => lower.contains(p));
  }
}
