import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/estado_juego.dart';
import '../../dialogo/pantallas/dialogo_screen.dart';
import '../../resultados/resultados_screen.dart';
import '../../semanas/guion_semanas.dart';
import '../models/escena_campus.dart';
import '../state/estado_mapa.dart';
import '../widgets/hotspot_escena.dart';
import 'escena_screen.dart';
import '../../menu_principal/menu_principal_screen.dart';

/// RF-01: mapa ilustrado del campus como punto de entrada visual a las
/// escenas del juego. Es el ESCENARIO de la historia de 8 semanas: en cada
/// semana el jugador toca los 13 bloques del mapa (A-L y el Templo), vive el
/// diálogo de cada uno y, cuando los recorrió todos, se habilita el botón
/// para completar la semana y avanzar a la siguiente. Al completar la
/// semana 8 se presenta el parcial y, tras él, la pantalla final (la única
/// donde suena el audio de cierre).
class MapaCampusScreen extends StatefulWidget {
  const MapaCampusScreen({super.key});

  @override
  State<MapaCampusScreen> createState() => _MapaCampusScreenState();
}

class _MapaCampusScreenState extends State<MapaCampusScreen>
    with WidgetsBindingObserver {
  /// Semana cuya introducción ya se mostró (para no repetirla).
  int _introMostrada = 0;
  bool _ocupado = false;

  /// Ids de los bloques que cuentan para la historia de las semanas.
  static final Set<String> _bloquesHistoria =
      EstadoJuego.bloquesDeSemana.toSet();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Repinta los hotspots cuando cambie la escena actual/visitada (RF-03)
    // o el progreso de la semana.
    estadoMapa.addListener(_onEstadoCambiado);
    estadoJuego.addListener(_onEstadoCambiado);
    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarIntroSemana());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    estadoMapa.removeListener(_onEstadoCambiado);
    estadoJuego.removeListener(_onEstadoCambiado);
    super.dispose();
  }

  void _onEstadoCambiado() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // La música no debe seguir sonando con la app en segundo plano, y al
    // volver solo se reanuda el soundtrack (nunca el audio de cierre).
    if (state == AppLifecycleState.paused) {
      AudioService.instance.detenerSoundtrack();
    } else if (state == AppLifecycleState.resumed &&
        !AudioService.instance.finalSonando) {
      AudioService.instance.iniciarSoundtrack();
    }
  }

  bool get _recorridoCompleto =>
      estadoJuego.semanasCompletadas.contains(EstadoJuego.totalSemanas);

  /// Muestra la introducción narrativa de la semana actual (una vez).
  Future<void> _mostrarIntroSemana() async {
    if (!mounted || _recorridoCompleto) return;
    final semana = estadoJuego.semanaActual;
    if (_introMostrada == semana) return;
    // Si la semana ya está avanzada (partida reanudada), no se repite.
    if (estadoJuego.bloquesVisitadosSemana.isNotEmpty) {
      _introMostrada = semana;
      return;
    }
    _introMostrada = semana;
    final intro = GuionSemanas.introDe(semana);
    if (intro == null) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141824),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        title: Text(
          'Semana $semana',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            intro,
            style: const TextStyle(
                color: Colors.white70, fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF)),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Salir a recorrer el campus'),
          ),
        ],
      ),
    );
  }

  /// Abre el menú principal (progreso, resultados, decisiones, reiniciar
  /// y gestión del tiempo) — antes de esto, esas 5 pantallas existían en
  /// el código pero no había forma de llegar a ninguna desde el juego.
  void _abrirMenuPrincipal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MenuPrincipalScreen(
          onVolverAlMapa: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Indica si una escena es una etapa del ciclo estudiantil (US-05) que
  /// puede mostrarse como completada en el marcador del mapa.
  bool _esEtapaCompletada(EscenaCampus escena) {
    if (_bloquesHistoria.contains(escena.id)) {
      return estadoJuego.bloquesVisitadosSemana.contains(escena.id);
    }
    if (escena.id == 'GESTION' || escena.id == 'FASE_2' || escena.id == 'FASE_3' || escena.id == 'D') {
      return estadoMapa.etapaCompletada(escena.id);
    }
    return false;
  }

  Future<void> _irAEscena(EscenaCampus escena) async {
    if (_ocupado) return;
    estadoMapa.seleccionarEscena(escena.id);
    // Bloques A-L y Templo: la historia de la semana en curso.
    if (_bloquesHistoria.contains(escena.id)) {
      await _abrirBloqueHistoria(escena);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EscenaScreen(escena: escena)),
    );
    // Al volver del Navigator.pop de EscenaScreen, el mapa ya refleja el
    // marcador de "escena actual" gracias al listener de estadoMapa.
  }

  /// Abre el diálogo del bloque para la semana actual. El bloque solo cuenta
  /// como recorrido si el diálogo se completó (no si se salió con la X).
  Future<void> _abrirBloqueHistoria(EscenaCampus escena) async {
    if (_recorridoCompleto) {
      _aviso('Ya terminaste el recorrido de las 8 semanas.');
      return;
    }
    final semana = estadoJuego.semanaActual;
    final lineas = GuionSemanas.lineasDe(semana, escena.id);
    if (lineas == null) return;
    if (estadoJuego.bloquesVisitadosSemana.contains(escena.id)) {
      _aviso('Ya recorriste ${escena.nombre} esta semana.');
      return;
    }
    _ocupado = true;
    final completo = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DialogoScreen(lineas: lineas, idEscena: escena.id),
      ),
    );
    _ocupado = false;
    if (!mounted) return;
    if (completo == true) {
      estadoJuego.marcarBloqueVisitado(escena.id);
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        backgroundColor: const Color(0xFF1A237E),
        duration: const Duration(seconds: 2),
      ));
  }

  /// Completa la semana actual. En la semana 8 primero se presenta el parcial.
  Future<void> _completarSemana() async {
    if (_ocupado) return;
    final semana = estadoJuego.semanaActual;
    if (semana < EstadoJuego.totalSemanas) {
      estadoJuego.completarSemana(semana);
      _aviso('¡Semana $semana completada! Estrés: ${estadoJuego.nivelEstres}/100');
      await _mostrarIntroSemana();
      return;
    }
    // Semana 8: el parcial cierra el recorrido.
    _ocupado = true;
    estadoJuego.parcialSuperado = false;
    final escenaParcial = escenasCampus.firstWhere((e) => e.id == 'D');
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EscenaScreen(escena: escenaParcial)),
    );
    _ocupado = false;
    if (!mounted) return;
    if (estadoJuego.parcialSuperado) {
      estadoJuego.completarSemana(semana);
      await _abrirFinal();
    }
  }

  /// Pantalla final: aquí (y solo aquí) suena el audio de cierre. Al salir
  /// de ella se corta y vuelve el soundtrack.
  Future<void> _abrirFinal() async {
    AudioService.instance.reproducirFinal();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ResultadosScreen(
          nivelEstres: estadoJuego.nivelEstres,
          etapasCompletadas: estadoJuego.etapasCompletadas,
          totalEtapas: EstadoJuego.totalEtapas,
          decisionesTomadas: List.of(estadoJuego.decisionesTomadas),
          insigniasObtenidas: Set.of(estadoJuego.insigniasObtenidas),
          tiempoAsignadoPorActividad:
              Map.of(estadoJuego.tiempoAsignadoPorActividad),
          resultadoFinal: estadoJuego.calcularResultadoFinal(),
          onReiniciar: () {
            estadoJuego.resetear();
            estadoMapa.resetear();
            Navigator.of(ctx).pop();
          },
          onVolverAlMenu: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
    // Cualquier salida de la pantalla final corta el audio de cierre.
    await AudioService.instance.detenerFinal();
    await AudioService.instance.iniciarSoundtrack();
    if (mounted) await _mostrarIntroSemana();
  }

  /// Panel de progreso de la semana, en la parte INFERIOR de la pantalla.
  /// Es una franja compacta y horizontal para no tapar el mapa; cuando se
  /// cumple la condición aparece el botón para avanzar.
  Widget _panelSemana() {
    final semana = estadoJuego.semanaActual;
    final total = EstadoJuego.bloquesObligatorios.length;
    final visitados = estadoJuego.obligatoriosVisitados;
    final listo = estadoJuego.semanaListaParaCompletar;
    final esUltima = semana >= EstadoJuego.totalSemanas;
    final templo = estadoJuego.bloquesVisitadosSemana.contains('TEMPLO');

    if (_recorridoCompleto) {
      return _franja(
        children: [
          const Expanded(
            child: Text('Recorrido completo',
                style: TextStyle(
                    color: Color(0xFFFFE66D), fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                visualDensity: VisualDensity.compact),
            onPressed: _abrirFinal,
            child: const Text('Ver resultados'),
          ),
        ],
      );
    }

    return _franja(
      children: [
        Text('Semana $semana de ${EstadoJuego.totalSemanas}',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listo
                    ? '¡Recorriste todo el campus!'
                    : 'Bloques recorridos: $visitados / $total'
                        '${templo ? ' · Templo ✓' : ' · Templo (opcional)'}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: visitados / total,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  color:
                      listo ? const Color(0xFF2ECC71) : const Color(0xFF00D9FF),
                ),
              ),
            ],
          ),
        ),
        if (listo) ...[
          const SizedBox(width: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.black,
                visualDensity: VisualDensity.compact),
            onPressed: _completarSemana,
            icon: const Icon(Icons.flag, size: 18),
            label: Text(esUltima
                ? 'Presentar el parcial'
                : 'Completar semana $semana'),
          ),
        ],
      ],
    );
  }

  Widget _franja({required List<Widget> children}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6C63FF), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  /// Utilidad SOLO de desarrollo: mantén presionado sobre el mapa para
  /// imprimir en consola la posición fraccional exacta del toque, y así
  /// calibrar `posicionRelativa` en escena_campus.dart contra el asset
  /// real. Las coordenadas que imprime son relativas al recuadro del
  /// mapa, que es exactamente el sistema de coordenadas que usa
  /// `escena_campus.dart`.
  void _debugImprimirCoordenada(
      LongPressStartDetails details, BoxConstraints constraints) {
    if (!kDebugMode) return;
    final dx = details.localPosition.dx / constraints.maxWidth;
    final dy = details.localPosition.dy / constraints.maxHeight;
    debugPrint(
        'Coordenada fraccional tocada: Offset(${dx.toStringAsFixed(2)}, ${dy.toStringAsFixed(2)})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;
          final alto = constraints.maxHeight;

          return GestureDetector(
            onLongPressStart: (details) =>
                _debugImprimirCoordenada(details, constraints),
            child: Stack(
              children: [
                // Sin AspectRatio: la imagen se estira para llenar
                // exactamente el espacio disponible, sin franjas
                // laterales ni superiores — el modo inmersivo
                // (main.dart) ya se encarga de que no haya barra de
                // estado que tapar.
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/mapa_campus.png',
                    fit: BoxFit.fill,
                  ),
                ),
                for (final escena in escenasCampus)
                  Positioned(
                    left: escena.posicionRelativa.dx * ancho -
                        HotspotEscena.tamano / 2,
                    top: escena.posicionRelativa.dy * alto -
                        HotspotEscena.tamano / 2,
                    child: HotspotEscena(
                      escena: escena,
                      esActual: estadoMapa.esEscenaActual(escena.id),
                      visitada: estadoMapa.fueVisitada(escena.id),
                      etapaCompletada: _esEtapaCompletada(escena),
                      onTap: () => _irAEscena(escena),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 8,
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _panelSemana(),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: IconButton(
                      onPressed: _abrirMenuPrincipal,
                      icon: const Icon(Icons.menu, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.black45),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}