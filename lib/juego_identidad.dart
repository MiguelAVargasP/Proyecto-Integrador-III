import 'package:flutter/material.dart';

/// Identidad visual propia del juego (US-18): personaje, paleta de colores
/// e iconografia del juego, diferenciada de la identidad institucional UPB.
///
/// A diferencia de [UPBIdentidad] (que aplica la marca de la universidad),
/// esta clase define la identidad del Juego de Orientacion UPB como producto
/// independiente: sus colores de UI, su avatar/guia y los iconos que lo
/// representan.
class JuegoIdentidad {
  /// Paleta de colores propia del juego (no confundir con la identidad UPB).
  static const Color fondo = Color(0xFF0B0F1A);
  static const Color panel = Color(0xFF141824);
  static const Color borde = Color(0xFF2A3444);
  static const Color acento1 = Color(0xFF6C63FF);   // púrpura gameplay
  static const Color acento2 = Color(0xFF00D9FF);   // cyan gameplay
  static const Color exito = Color(0xFF2ECC71);      // verde éxito
  static const Color alerta = Color(0xFFE74C3C);     // rojo alerta
  static const Color aviso = Color(0xFFFFE66D);      // amarillo aviso
  static const Color primario = Color(0xFF1A237E);   // indigo (compatible con UPB)
  static const Color texto = Color(0xFFFFFFFF);      // Blanco

  /// Avatar/guía del jugador: el interlocutor que lo acompaña en el recorrido.
  /// Se muestra en las pantallas principales como referencia visual constante.
  static Widget avatar({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: acento1.withValues(alpha: 0.15),
        border: Border.all(color: acento1, width: 2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.7,
        color: acento1,
      ),
    );
  }

  /// Iconografía propia del juego (no la del sistema Material).
  /// Se usan estos iconos para que la app tenga un lenguaje visual propio.
  static IconData iconoAccion() => Icons.play_circle_outlined;
  static IconData iconoProgreso() => Icons.trending_up;
  static IconData iconoResultados() => Icons.analytics_outlined;
  static IconData iconoDecisiones() => Icons.compare_arrows;
  static IconData iconoReiniciar() => Icons.refresh;
  static IconData iconoGestionTiempo() => Icons.timer_outlined;
  static IconData iconoMapa() => Icons.map;
  static IconData iconoCerrar() => Icons.close;

  /// Título del juego, usado como heading en pantallas principales.
  static const String titulo = 'Orientacion UPB';
}