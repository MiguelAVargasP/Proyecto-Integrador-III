import 'package:flutter/material.dart';
import '../models/escena_campus.dart';

/// Área táctil invisible sobre el marcador de una escena ya dibujado en la
/// imagen del mapa (el círculo con letra para A-L, o la etiqueta de texto
/// para el Templo). Este widget no dibuja nada por defecto: solo captura
/// el toque y, opcionalmente, resalta la escena actual (RF-03) con un
/// anillo blanco.
class HotspotEscena extends StatelessWidget {
  final EscenaCampus escena;
  final bool esActual;
  final bool visitada;
  final bool etapaCompletada;
  final VoidCallback onTap;

  /// Tamaño del área táctil. 48 es el mínimo recomendado de accesibilidad
  /// táctil (Material Design); súbelo si los marcadores del mapa son más
  /// grandes que eso en la resolución final del asset.
  static const double tamano = 48;

  const HotspotEscena({
    super.key,
    required this.escena,
    required this.onTap,
    this.esActual = false,
    this.visitada = false,
    this.etapaCompletada = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        button: true,
        label: 'Ir a ${escena.nombre}',
        child: SizedBox(
          width: tamano,
          height: tamano,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Si la etapa está completada, mostrar círculo verde de progreso
              if (etapaCompletada)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent.withOpacity(0.3),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                )
              // Si es la escena actual, resaltar con anillo blanco
              else if (esActual)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}