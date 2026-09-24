import 'package:flutter/material.dart';

/// Pantalla de resultados finales (US-15).
///
/// Muestra un resumen del recorrido del jugador: estr&eacute;s final, decisiones
/// m&aacute;s relevantes, insignias obtenidas y resultado general.
///
/// Debe mostrarse al finalizar el recorrido (todas las etapas completadas
/// o cuando el jugador decide terminar).
class ResultadosScreen extends StatelessWidget {
  final int nivelEstres;
  final int etapasCompletadas;
  final int totalEtapas;
  final List<String> decisionesTomadas;
  final Set<String> insigniasObtenidas;
  final Map<String, int> tiempoAsignadoPorActividad;
  final VoidCallback onReiniciar;
  final VoidCallback onVolverAlMenu;

  const ResultadosScreen({
    super.key,
    required this.nivelEstres,
    required this.etapasCompletadas,
    required this.totalEtapas,
    required this.decisionesTomadas,
    required this.insigniasObtenidas,
    required this.tiempoAsignadoPorActividad,
    required this.onReiniciar,
    required this.onVolverAlMenu,
  });

  String get _resultadoFinal {
    if (nivelEstres < 30) return 'Bien preparado';
    if (nivelEstres < 70) return 'Preparaci&oacute;n irregular';
    return 'Poco preparado';
  }

  Color get _colorResultado {
    if (nivelEstres < 30) return const Color(0xFF4CAF50);
    if (nivelEstres < 70) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.assessment, size: 48, color: Colors.amberAccent),
              const SizedBox(height: 16),
              const Text(
                'Resultados de tu recorrido',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Recorrido UPB &mdash; Orientaci&oacute;n Universitaria',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _colorResultado.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _colorResultado, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tu resultado final',
                      style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _resultadoFinal,
                      style: TextStyle(
                        color: _colorResultado,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _seccionEstadisticas(),
              const SizedBox(height: 24),

              if (decisionesTomadas.isNotEmpty) ...[
                _tituloSeccion('Decisiones clave'),
                const SizedBox(height: 8),
                ...decisionesTomadas.take(5).map((d) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: Colors.greenAccent),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(d,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 13))),
                      ],
                    ),
                  );
                }),
                if (decisionesTomadas.length > 5)
                  Text(
                    '... y ${decisionesTomadas.length - 5} m&aacute;s',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                const SizedBox(height: 16),
              ],

              if (insigniasObtenidas.isNotEmpty) ...[
                _tituloSeccion('Insignias'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: insigniasObtenidas.map((id) {
                    return Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.star,
                          color: Colors.amberAccent, size: 20),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              FilledButton.icon(
                onPressed: onVolverAlMenu,
                icon: const Icon(Icons.home),
                label: const Text('Volver al mapa'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onReiniciar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar recorrido'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
          color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }

  Widget _seccionEstadisticas() {
    int estudioHoras = 0;
    if (tiempoAsignadoPorActividad['Estudio independiente'] != null) {
      estudioHoras += tiempoAsignadoPorActividad['Estudio independiente']!;
    }
    if (tiempoAsignadoPorActividad['Clases y seminarios'] != null) {
      estudioHoras += tiempoAsignadoPorActividad['Clases y seminarios']!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion('Tus estad&iacute;sticas'),
        const SizedBox(height: 8),
        _filaStat('Etapas completadas', '$etapasCompletadas / $totalEtapas'),
        _filaStat('Nivel de estr&eacute;s', '$nivelEstres / 100'),
        _filaStat('Horas de estudio', '$estudioHoras h'),
        _filaStat('Decisiones tomadas', '${decisionesTomadas.length}'),
        _filaStat('Insignias', '${insigniasObtenidas.length}'),
      ],
    );
  }

  Widget _filaStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
