import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/mapa_navegacion/screens/mapa_campus_screen.dart';
import 'registro_inicial.dart';

void main() {
  registrarContenidoDeEscenas();

  // Modo inmersivo: oculta la barra de estado y la barra de navegación
  // del sistema, para que el mapa (y el resto del juego) cubran el 100%
  // de la pantalla sin que ningún ícono del sistema tape marcadores como
  // L. "immersiveSticky" permite recuperar las barras temporalmente con
  // un deslizamiento desde el borde si el jugador lo necesita, y vuelven
  // a ocultarse solas — es el modo estándar para apps de pantalla
  // completa tipo juego.
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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MapaCampusScreen(),
    );
  }
}