import 'package:flutter/material.dart';
import '../../core/contenido_escena.dart';
import '../../core/estado_juego.dart';
import '../../features/mapa_navegacion/state/estado_mapa.dart';

/// Contenido jugable para la FASE 3 del ciclo estudiantil (US-05):
/// "Estudio independiente y preparacion para el parcial".
///
/// El jugador debe gestionar su tiempo de estudio antes del parcial,
/// decidir que materias priorizar y como enfrentar el examen.
///
/// Flujo narrativo:
/// 1. Dialogo sobre la proximidad del parcial y la necesidad de estudiar.
/// 2. Eleccion de como distribuir el tiempo de estudio.
/// 3. Consecuencia sobre el nivel de preparacion y estrés.
class EstudioIndependienteContenido implements ContenidoEscena {
  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return _EstudioIndependienteScreen(onCompletada: onCompletada);
  }
}

class _EstudioIndependienteScreen extends StatefulWidget {
  final VoidCallback onCompletada;
  const _EstudioIndependienteScreen({required this.onCompletada});

  @override
  State<_EstudioIndependienteScreen> createState() =>
      _EstudioIndependienteScreenState();
}

class _EstudioIndependienteScreenState
    extends State<_EstudioIndependienteScreen> {
  int _indiceLinea = 0;

  final List<_Linea> _lineas = [
    _Linea(
      texto: 'El parcial se acerca y tu nivel de estrés aumenta. Necesitas decidir como prepararte.',
      hablante: 'Narrador',
    ),
    _Linea(
      texto: 'Tienes varias materias que repasar y poco tiempo. Que haces?',
      hablante: 'Tu reflexion',
      opciones: [
        _Opcion(
          texto: 'Estudiar todas las materias por igual',
          descripcion: 'Una aproximacion equilibrada pero que puede ser poco eficiente.',
          efectoEstres: 3,
          efectoTiempo: {'Estudio independiente': 5},
        ),
        _Opcion(
          texto: 'Priorizar la materia mas dificil y descansar antes del examen',
          descripcion: 'Enfocarte en lo mas dificil puede reducir tu ansiedad.',
          efectoEstres: -4,
          efectoTiempo: {'Estudio independiente': 3, 'Descanso y ocio': 2},
        ),
        _Opcion(
          texto: 'Estudiar solo lo que el profesor mostro en clase',
          descripcion: 'Racional pero podria dejar lagunas si el examen es amplio.',
          efectoEstres: 2,
          efectoTiempo: {'Clases y seminarios': 2, 'Estudio independiente': 3},
        ),
      ],
    ),
    _Linea(
      texto: 'Tras horas de estudio, sientes que estás listo para el parcial. El estrés disminuye y tu confianza aumenta.',
      hablante: 'Narrador',
      esFinal: true,
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
    estadoJuego.registrarDecision(
        'Estudio independiente: ${opcion.texto}');
    if (opcion.efectoEstres != 0) {
      estadoJuego.ajustarEstres(opcion.efectoEstres);
    }
    if (opcion.efectoTiempo.isNotEmpty) {
      opcion.efectoTiempo.forEach((actividad, horas) {
        estadoJuego.registrarTiempo(actividad, horas);
      });
    }
    setState(() => _indiceLinea++);
  }

  void _completar() {
  estadoJuego.completarEtapa();
  estadoMapa.completarEtapa('FASE_3');
  widget.onCompletada();
  }
  }

  class _Linea {
  final String texto;
  final String hablante;
  final List<_Opcion> opciones;
  final bool esFinal;
  _Linea({
  required this.texto,
  this.hablante = '',
  this.opciones = const [],
  this.esFinal = false,
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
