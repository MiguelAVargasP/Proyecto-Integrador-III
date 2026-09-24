import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/contenido_escena.dart';
import '../../../core/estado_juego.dart';
import '../../../features/mapa_navegacion/state/estado_mapa.dart';
import '../../../features/eventos/evento_imprevisto.dart';
import '../../../features/reflexion/reflexion_etapa.dart';
import '../pantallas/parcial_combate_screen.dart';

/// Contenido jugable de la escena del parcial simulado (RF-05, RF-08).
///
/// Flujo:
/// 1. Pantalla previa con nivel de estrés.
/// 2. Combate simulado (ParcialCombateScreen).
/// 3. Al finalizar: US-07 (evento imprevisto aleatorio), US-11 (reflexión),
///    otorgamiento de insignia y marcado de etapa completada.
class ParcialContenido implements ContenidoEscena {
  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return _ParcialIntro(onCompletada: onCompletada);
  }
}

class _ParcialIntro extends StatefulWidget {
  final VoidCallback onCompletada;
  const _ParcialIntro({required this.onCompletada});

  @override
  State<_ParcialIntro> createState() => _ParcialIntroState();
}

class _ParcialIntroState extends State<_ParcialIntro> {
  bool _mostrarReflexion = false;

  @override
  Widget build(BuildContext context) {
    if (_mostrarReflexion) {
      return ReflexionEtapa(
        nombreEtapa: 'Examen parcial simulado',
        nivelEstres: estadoJuego.nivelEstres,
        tiempoPorActividad: estadoJuego.tiempoPorActividad,
        onContinuar: () {
          setState(() => _mostrarReflexion = false);
          widget.onCompletada();
        },
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Es hora del primer parcial.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nivel de estrés acumulado: ${estadoJuego.nivelEstres}/100',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Presentar el parcial'),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const ParcialCombateScreen(),
                  ),
                );
                _completar();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _completar() {
    // US-10: Insignía por completar el parcial
    estadoJuego.otorgarInsignia('D');
    // US-05/RF-04: marcar etapa completada en mapa
    estadoMapa.completarEtapa('D');

    // US-07: Evento imprevisto aleatorio (opcional)
    final random = Random();
    final evento = EventoImprevisto.aleatorio(random);
    final deltaEstres = evento.aplicar(false);
    if (deltaEstres > 0) {
      estadoJuego.ajustarEstres(deltaEstres);
      estadoJuego.registrarDecision(
          'Evento imprevisto: ${evento.titulo} (+$deltaEstres estres)');
    }

    // US-11: Momento de reflexión antes de completar
    setState(() {
      _mostrarReflexion = true;
    });
  }
}
