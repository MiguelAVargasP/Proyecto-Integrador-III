import 'package:flutter/material.dart';

/// Pantalla de progreso acumulado (US-14).
///
/// Muestra el progreso del jugador en el recorrido: etapas completadas,
/// estrés actual, insignias obtenidas y horas asignadas.
///
/// Se puede integrar como una escena en el mapa o como pantalla accesible
/// desde el menú principal.
class ProgresoScreen extends StatelessWidget {
  final int etapasCompletadas;
  final int totalEtapas;
  final int nivelEstres;
  final int tiempoDisponibleHoras;
  final Map<String, int> tiempoAsignadoPorActividad;
  final Set<String> insigniasObtenidas;
  final VoidCallback onVolver;

  const ProgresoScreen({
    super.key,
    required this.etapasCompletadas,
    required this.totalEtapas,
    required this.nivelEstres,
    required this.tiempoDisponibleHoras,
    required this.tiempoAsignadoPorActividad,
    required this.insigniasObtenidas,
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    final progreso = etapasCompletadas / totalEtapas;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tu progreso'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onVolver,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de progreso general
            _tituloSeccion('Progreso general'),
            const SizedBox(height: 8),
            Text(
              '$etapasCompletadas de $totalEtapas etapas completadas',
              style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progreso,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation(Colors.indigo),
              minHeight: 12,
            ),
            const SizedBox(height: 24),

            // Nivel de estrés
            _tituloSeccion('Nivel de estrés'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$nivelEstres / 100',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: nivelEstres / 100,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation(
                          nivelEstres < 30 ? Colors.greenAccent : (nivelEstres < 70 ? Colors.orange : Colors.redAccent),
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Horas asignadas
            _tituloSeccion('Tiempo asignado'),
            const SizedBox(height: 8),
            if (tiempoAsignadoPorActividad.isEmpty)
              const Text(
                'Aún no has asignado tiempo.',
                style: TextStyle(color: Colors.white70),
              )
            else
              ...tiempoAsignadoPorActividad.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(entry.key, style: const TextStyle(color: Colors.white))),
                      Text(
                        '${entry.value} h',
                        style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 24),

            // Insignias
            _tituloSeccion('Insignias obtenidas'),
            const SizedBox(height: 8),
            if (insigniasObtenidas.isEmpty)
              const Text(
                'Aún no has obtenido insignias.',
                style: TextStyle(color: Colors.white70),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: insigniasObtenidas.map((id) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amberAccent, width: 1),
                    ),
                    child: const Icon(Icons.star, color: Colors.amberAccent, size: 24),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Tiempo disponible
            _tituloSeccion('Horas disponibles'),
            const SizedBox(height: 8),
            Text(
              '$tiempoDisponibleHoras horas restantes para distribuir',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }
}
