import 'package:flutter/material.dart';

/// Identidad visual UPB (US-17): colores y tipografía institucional.
///
/// Los colores de la marca UPB son:
/// - Indigo / Azul marino: #1A237E / #0D47A1
/// - Amarillo institucional: #FFC107
/// - Blanco para texto
///
/// Este archivo centraliza los colores para que toda la app use
/// una paleta coherente con la identidad de la universidad.
class UPBIdentidad {
  static const Color primario = Color(0xFF1A237E);   // Indigo UPB
  static const Color secundario = Color(0xFF0D47A1); // Azul marino
  static const Color acento = Color(0xFFFFC107);     // Amarillo institucional
  static const Color fondo = Color(0xFF0B0F1A);      // Fondo oscuro
  static const Color texto = Color(0xFFFFFFFF);      // Blanco

  /// Logo ASCII de UPB para pantallas de texto (uso en consola/debug).
  static const String logoASCII = '''
╔═══════════════════════╗
║   U P B - O R I E N T A
║   Orientación UPB
╚════════════════════════╝
  ''';
}
