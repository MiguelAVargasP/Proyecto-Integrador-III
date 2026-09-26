import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/estado_juego.dart';
import 'features/mapa_navegacion/state/estado_mapa.dart';
import 'features/mapa_navegacion/screens/mapa_campus_screen.dart';
import 'features/menu_principal/menu_principal_screen.dart';
import 'registro_inicial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await estadoJuego.cargar();
  await estadoMapa.cargar();
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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      // El menú principal es ahora la pantalla de entrada. `Builder` nos
      // da un `context` que ya está debajo del `Navigator` de MaterialApp,
      // necesario para poder EMPUJAR el mapa hacia adelante (no hay nada
      // debajo todavía a donde "volver" — es la ruta raíz de la app).
      home: Builder(
        builder: (context) => MenuPrincipalScreen(
          onVolverAlMapa: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MapaCampusScreen()),
            );
          },
        ),
      ),
    );
  }
}