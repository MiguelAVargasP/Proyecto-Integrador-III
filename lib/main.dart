import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/estado_juego.dart';
import 'features/mapa_navegacion/state/estado_mapa.dart';
import 'features/mapa_navegacion/screens/mapa_campus_screen.dart';
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
      home: const MapaCampusScreen(),
    );
  }
}