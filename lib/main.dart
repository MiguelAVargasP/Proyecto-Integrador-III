import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/estado_juego.dart';
import 'features/mapa_navegacion/state/estado_mapa.dart';
import 'features/menu_inicio/menu_inicio_screen.dart';
import 'registro_inicial.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await estadoJuego.cargar();
  await estadoMapa.cargar();
  registrarContenidoDeEscenas();

  estadoJuego.onInsigniaOtorgada = (id, nombre) {
    rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amberAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '¡Nueva insignia obtenida: $nombre!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  };

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const OrientacionUpbApp());
}

class OrientacionUpbApp extends StatelessWidget {
  const OrientacionUpbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Orientación UPB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      // La puerta de entrada es ahora el menú de inicio (portada + botón que
      // arranca el soundtrack y el flujo de 8 semanas). `MenuPrincipalScreen`
      // (progreso/resultados/decisiones) sigue disponible desde el mapa. Se
      // envuelve en `Builder` para tener un `context` debajo del Navigator.
      home: Builder(
        builder: (context) => const MenuInicioScreen(),
      ),
    );
  }
}