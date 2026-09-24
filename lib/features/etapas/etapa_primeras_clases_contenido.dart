import 'package:flutter/material.dart';
import '../../core/contenido_escena.dart';
import '../../core/estado_juego.dart';
import '../../features/mapa_navegacion/state/estado_mapa.dart';

/// Contenido jugable para la FASE 2 del ciclo estudiantil (US-05):
/// "Primeras clases y adaptación al nuevo horario".
///
/// El jugador recibe información sobre las primeras semanas de clases:
/// organizacion, asistencia, profesores, etc., y toma decisiones
/// que afectan su estrés y preparación.
///
/// Flujo narrativo sugerido:
/// 1. Diálogo de bienvenida y presentación del contexto.
/// 2. Opción de como enfocarse en las primeras clases.
/// 3. Consecuencia sobre la gestion del tiempo y el estrés.
class PrimerasClasesContenido implements ContenidoEscena {
  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return _PrimerasClasesScreen(onCompletada: onCompletada);
  }
}

class _PrimerasClasesScreen extends StatefulWidget {
  final VoidCallback onCompletada;
  const _PrimerasClasesScreen({required this.onCompletada});

  @override
  State<_PrimerasClasesScreen> createState() => _PrimerasClasesScreenState();
}

class _PrimerasClasesScreenState extends State<_PrimerasClasesScreen> {
  int _indiceLinea = 0;

  final List<_Linea> _lineas = [
    _Linea(
      texto: 'Llegas a tu primera clase de la semana. El aula esta llena y hay un ambiente de expectativa.',
      hablante: 'Narrador',
    ),
    _Linea(
      texto: 'El profesor comienza a explicar el programa de la materia. Tú tienes que decidir como enfrentar este nuevo reto.',
      hablante: 'Narrador',
    ),
    _Linea(
      texto: '¿Como quieres enfocarte en estas primeras clases?',
      hablante: 'Tu companero de estudio',
      opciones: [
        _Opcion(
          texto: 'Asistir a todas las clases y tomar notas detalladas',
          descripcion: 'Aumenta tu preparacion pero puede generar mas estrés por la carga.',
          efectoEstres: 5,
          efectoTiempo: {'Clases y seminarios': 3},
        ),
        _Opcion(
          texto: 'Asistir solo a las clases mas importantes y estudiar por tu cuenta',
          descripcion: 'Ahorras tiempo pero podrias perder informacion clave.',
          efectoEstres: -2,
          efectoTiempo: {'Estudio independiente': 4},
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_indiceLinea >= _lineas.length) {
      _completar();
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Etapa completada',
            style: TextStyle(color: Colors.amberAccent, fontSize: 18),
          ),
        ),
      );
    }

    final linea = _lineas[_indiceLinea];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (linea.hablante.isNotEmpty)
                Text(
                  linea.hablante,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                linea.texto,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (linea.opciones.isNotEmpty)
                ...linea.opciones.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final opcion = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _elegir(idx),
                      child: Column(
                        children: [
                          Text(
                            opcion.texto,
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (opcion.descripcion.isNotEmpty)
                            Text(
                              opcion.descripcion,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              if (linea.opciones.isEmpty)
                FilledButton(
                  onPressed: () => _avanzar(),
                  child: const Text('Continuar'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _avanzar() {
    setState(() => _indiceLinea++);
  }

  void _elegir(int indice) {
    final opcion = _lineas[_indiceLinea].opciones[indice];
    // Registrar decision
    estadoJuego.registrarDecision(
        'Primeras clases: ${opcion.texto}');
    // Aplicar efecto de estrés
    if (opcion.efectoEstres != 0) {
      estadoJuego.ajustarEstres(opcion.efectoEstres);
    }
    // Registrar tiempo asignado
    if (opcion.efectoTiempo.isNotEmpty) {
      opcion.efectoTiempo.forEach((actividad, horas) {
        estadoJuego.registrarTiempo(actividad, horas);
      });
    }
    setState(() => _indiceLinea++);
  }

  void _completar() {
  estadoJuego.completarEtapa();
  estadoMapa.completarEtapa('FASE_2');
  widget.onCompletada();
  }
  }

  class _Linea {
  final String texto;
  final String hablante;
  final List<_Opcion> opciones;
  _Linea({
  required this.texto,
  this.hablante = '',
  this.opciones = const [],
  });
  }

class _Opcion {
  final String texto;
  final String descripcion;
  final int efectoEstres;
  final Map<String, int> efectoTiempo;
  _Opcion({
    required this.texto,
    this.descripcion = '',
    this.efectoEstres = 0,
    this.efectoTiempo = const {},
  });
}
