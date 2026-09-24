import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/menu_principal/menu_principal_screen.dart';
import 'features/mapa_navegacion/screens/mapa_campus_screen.dart';
import 'registro_inicial.dart';

void main() {
  registrarContenidoDeEscenas();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const OrientacionUpbApp());
}

class OrientacionUpbApp extends StatelessWidget {
  const OrientacionUpbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orientación UPB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F1A),
      ),
      home: const MapaCampusScreen(),
    );
  }
}

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
╚═══════════════════════╝
  ''';
}
