import 'package:flutter/material.dart';

/// Representa una escena seleccionable del campus (RF-02): un edificio o
/// espacio representativo, marcado en el mapa ilustrado con una letra.
///
/// La [posicionRelativa] se expresa como fracción (0.0 a 1.0) del ancho y
/// alto de la imagen del mapa, no en píxeles absolutos, para que los
/// hotspots se reposicionen correctamente en cualquier tamaño de pantalla
/// (`Positioned` calcula la posición real multiplicando por el tamaño
/// disponible en tiempo de build).
///
/// IMPORTANTE: los valores de [posicionRelativa] de abajo son una primera
/// estimación visual sobre la imagen `mapa_campus.png`. Ajústalos con la
/// utilidad de calibración incluida en `MapaCampusScreen` (mantén
/// presionado sobre el mapa en modo debug para ver la posición fraccional
/// exacta donde tocaste, impresa en la consola).
class EscenaCampus {
  final String id; // Letra del marcador tal como aparece en el mapa (A-L)
  final String nombre; // Nombre legible de la escena
  final Offset posicionRelativa; // (dx, dy) entre 0.0 y 1.0

  const EscenaCampus({
    required this.id,
    required this.nombre,
    required this.posicionRelativa,
  });
}

/// Catálogo de las escenas representativas del campus (RF-02): 12
/// edificios marcados con letra (A-L) más el Templo, identificado con su
/// propia etiqueta de texto en el mapa. Todas navegables desde ya; cuáles
/// tienen contenido jugable real depende únicamente de qué haya en
/// `registroContenidoEscenas` (ver `registro_inicial.dart`) — una escena
/// sin contenido registrado sigue siendo navegable y muestra un
/// placeholder, no se oculta del mapa.
const List<EscenaCampus> escenasCampus = [
  EscenaCampus(id: 'A', nombre: 'Bloque A', posicionRelativa: Offset(0.263, 0.575)),
  EscenaCampus(id: 'B', nombre: 'Bloque B', posicionRelativa: Offset(0.296, 0.673)),
  EscenaCampus(id: 'C', nombre: 'Bloque C', posicionRelativa: Offset(0.412, 0.675)),
  EscenaCampus(id: 'D', nombre: 'Bloque D', posicionRelativa: Offset(0.492, 0.475)),
  EscenaCampus(id: 'E', nombre: 'Bloque E', posicionRelativa: Offset(0.684, 0.428)),
  EscenaCampus(id: 'F', nombre: 'Bloque F', posicionRelativa: Offset(0.747, 0.507)),
  EscenaCampus(id: 'G', nombre: 'Bloque G', posicionRelativa: Offset(0.795, 0.560)),
  EscenaCampus(id: 'H', nombre: 'Bloque H', posicionRelativa: Offset(0.809, 0.420)),
  EscenaCampus(id: 'I', nombre: 'Bloque I', posicionRelativa: Offset(0.745, 0.236)),
  EscenaCampus(id: 'J', nombre: 'Bloque J', posicionRelativa: Offset(0.481, 0.755)),
  EscenaCampus(id: 'K', nombre: 'Bloque K', posicionRelativa: Offset(0.557, 0.189)),
  EscenaCampus(id: 'L', nombre: 'Bloque L', posicionRelativa: Offset(0.827, 0.158)),
  // A diferencia de A-L, el Templo no tiene un círculo con letra, pero sí
  // tiene su propio marcador visual en la imagen: la etiqueta rectangular
  // morada con el texto "TEMPLO". El hotspot se ubica exactamente sobre
  // esa etiqueta.
  EscenaCampus(
    id: 'TEMPLO',
    nombre: 'Templo',
    posicionRelativa: Offset(0.125, 0.435),
  ),
];