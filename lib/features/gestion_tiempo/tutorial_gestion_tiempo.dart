import 'package:flutter/material.dart';

/// Tutorial breve de la mecánica de gestión del tiempo (US-21/RF-21).
///
/// Se muestra antes de que el jugador deba distribuir sus horas, de modo
/// que entienda qué hace cada actividad antes de tomar sus decisiones.
/// El jugador puede saltar el tutorial en cualquier momento.
class TutorialGestionTiempo extends StatelessWidget {
  final VoidCallback onSalir;

  const TutorialGestionTiempo({super.key, required this.onSalir});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('¿Cómo funciona la gestión del tiempo?'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onSalir,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'En esta etapa tendrás 12 horas disponibles al día para distribuir\nentre distintas actividades. Cada actividad afecta tu nivel de estrés.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            _tutorialFila(
              icon: Icons.school,
              titulo: 'Estudio independiente',
              descripcion: 'Reduce estrés (-3 por hora). Ideal para preparar examenes.',
              color: Colors.greenAccent,
            ),
            _tutorialFila(
              icon: Icons.play_circle_outline,
              titulo: 'Clases y seminarios',
              descripcion: 'Sin efecto de estrés. Es tu actividad académica principal.',
              color: Colors.amberAccent,
            ),
            _tutorialFila(
              icon: Icons.group_work,
              titulo: 'Trabajo grupal',
              descripcion: 'Aumenta estrés (+2 por hora). Productivo pero cansino.',
              color: Colors.redAccent,
            ),
            _tutorialFila(
              icon: Icons.bed,
              titulo: 'Descanso y ocio',
              descripcion: 'Reduce mucho estrés (-5 por hora). Esencial para recargar.',
              color: Colors.blueAccent,
            ),
            _tutorialFila(
              icon: Icons.fitness_center,
              titulo: 'Bienestar personal',
              descripcion: 'Reduce estrés (-4 por hora). Ejercicio o hobbies.',
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Consejo: equilibra actividades productivas con descanso para\nmantener un nivel de estrés bajo antes del parcial.',
              style: TextStyle(color: Colors.amberAccent, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onSalir,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Entendido, quiero empezar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tutorialFila({
    required IconData icon,
    required String titulo,
    required String descripcion,
    required Color color,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descripcion,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
