import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../juego_identidad.dart';
import '../semanas/flujo_semanas_screen.dart';
import '../mapa_navegacion/screens/mapa_campus_screen.dart';

/// Pantalla de INICIO del juego (distinta del menú post-escena). Muestra la
/// imagen de portada `Menu.png` a pantalla completa y un botón de inicio que
/// arranca la lógica del juego serio (soundtrack en loop + flujo de 8 semanas).
///
/// No reemplaza a `MenuPrincipalScreen` (el menú de progreso/resultados que
/// ya existía): este es la nueva puerta de entrada. Si hay partida guardada,
/// ofrece además "Continuar" (reanuda el flujo) y "Ver mapa" (acceso libre).
class MenuInicioScreen extends StatelessWidget {
  const MenuInicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de portada del juego.
          Image.asset(
            'assets/images/escenarios/Menu.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              color: JuegoIdentidad.fondo,
            ),
          ),
          // Velo oscuro para que los botones resalten sobre la portada.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    JuegoIdentidad.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PixelifySans',
                      color: Colors.white,
                      fontSize: 34,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Un viaje de 8 semanas por tu primera experiencia universitaria',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: JuegoIdentidad.acento1,
                      minimumSize: const Size.fromHeight(54),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      'Iniciar recorrido',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _iniciar(context),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Explorar el mapa'),
                    onPressed: () {
                      AudioService.instance.iniciarSoundtrack();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MapaCampusScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Arranca la partida: reanuda el soundtrack en loop y empuja el flujo de
  /// las 8 semanas. Si es una partida nueva, arranca en la semana 1.
  void _iniciar(BuildContext context) {
    AudioService.instance.iniciarSoundtrack();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FlujoSemanasScreen()),
    );
  }
}
