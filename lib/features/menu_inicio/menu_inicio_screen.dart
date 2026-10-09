import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../juego_identidad.dart';
import '../mapa_navegacion/screens/mapa_campus_screen.dart';

/// Pantalla de INICIO del juego. La portada `Menu.png` ya trae dibujados el
/// título ("Primiparo") y el botón "EMPEZAR", así que esta pantalla NO agrega
/// títulos ni botones propios encima: solo coloca un área táctil invisible
/// exactamente sobre el botón dibujado en la imagen.
///
/// La imagen se dibuja con `BoxFit.cover`; para que el área táctil siga al
/// botón en cualquier proporción de pantalla, la posición se calcula con la
/// misma matemática de `cover` (escala = max(ancho/imgAncho, alto/imgAlto),
/// imagen centrada y recortada).
class MenuInicioScreen extends StatefulWidget {
  const MenuInicioScreen({super.key});

  @override
  State<MenuInicioScreen> createState() => _MenuInicioScreenState();
}

class _MenuInicioScreenState extends State<MenuInicioScreen> {
  // Tamaño real de Menu.png.
  static const double _imgAncho = 1672;
  static const double _imgAlto = 941;

  // Botón "EMPEZAR" dentro de la imagen, como fracción de su ancho/alto
  // (medido sobre el PNG, incluyendo el borde oscuro del botón).
  static const double _izq = 0.384;
  static const double _der = 0.616;
  static const double _arr = 0.541;
  static const double _aba = 0.640;

  bool _presionado = false;

  @override
  void initState() {
    super.initState();
    // Estar en el menú significa que no hay partida en curso: si venimos de
    // la pantalla final, el audio de cierre no debe seguir sonando aquí.
    AudioService.instance.detenerFinal();
  }

  /// Arranca la partida: música de fondo en bucle y mapa del campus, que es
  /// el escenario donde transcurre la historia semana a semana.
  void _empezar() {
    AudioService.instance.iniciarSoundtrack();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapaCampusScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuegoIdentidad.fondo,
      body: LayoutBuilder(
        builder: (context, c) {
          final escala = (c.maxWidth / _imgAncho) > (c.maxHeight / _imgAlto)
              ? c.maxWidth / _imgAncho
              : c.maxHeight / _imgAlto;
          final ancho = _imgAncho * escala;
          final alto = _imgAlto * escala;
          final dx = (c.maxWidth - ancho) / 2;
          final dy = (c.maxHeight - alto) / 2;

          final rect = Rect.fromLTRB(
            dx + ancho * _izq,
            dy + alto * _arr,
            dx + ancho * _der,
            dy + alto * _aba,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/escenarios/Menu.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    Container(color: JuegoIdentidad.fondo),
              ),
              Positioned.fromRect(
                rect: rect,
                child: Semantics(
                  button: true,
                  label: 'Empezar',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) => setState(() => _presionado = true),
                    onTapCancel: () => setState(() => _presionado = false),
                    onTapUp: (_) => setState(() => _presionado = false),
                    onTap: _empezar,
                    // Sin dibujo propio: solo un leve oscurecimiento al
                    // presionar, para que el botón de la imagen "responda".
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(rect.height * 0.28),
                        color: _presionado
                            ? Colors.black.withValues(alpha: 0.22)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
