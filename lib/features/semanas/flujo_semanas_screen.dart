import 'package:flutter/material.dart';

import '../../core/estado_juego.dart';
import '../../core/audio/audio_service.dart';
import '../dialogo/pantallas/dialogo_screen.dart';
import 'guion_semanas.dart';

/// Pantalla de progresión del juego serio: organiza el recorrido en las 8
/// semanas del guion. Es la "lógica del juego" a la que lleva el botón de
/// inicio del menú.
///
/// Diseño (sin romper lo existente):
/// - NO reimplementa el motor de diálogo: delega en `DialogoScreen` (el mismo
///   widget que ya usa el mapa) pasándole las líneas de [GuionSemanas].
/// - NO altera `EstadoJuego` salvo por los campos nuevos de semanas.
/// - El mapa del campus sigue disponible e intacto desde el menú principal.
///
/// Progresión: una semana se completa cuando el jugador dialogó todos sus
/// nodos. La semana N+1 se desbloquea al completar la N-1.
class FlujoSemanasScreen extends StatefulWidget {
  const FlujoSemanasScreen({super.key});

  @override
  State<FlujoSemanasScreen> createState() => _FlujoSemanasScreenState();
}

class _FlujoSemanasScreenState extends State<FlujoSemanasScreen>
    with WidgetsBindingObserver {
  /// Nodos visitados en la semana visible; al completarlos todos se habilita
  /// "completar semana". Se reinicia al cambiar de semana.
  final Set<String> _visitadosEstaSemana = {};

  static const List<String> _ordenBloques = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'TEMPLO',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausa/reanuda el soundtrack al sacar/traer la app al frente, para no
    // dejar la música sonando en segundo plano.
    if (state == AppLifecycleState.paused) {
      AudioService.instance.detenerSoundtrack();
    } else if (state == AppLifecycleState.resumed) {
      AudioService.instance.iniciarSoundtrack();
    }
  }

  Future<void> _abrirBloque(int semana, String bloque) async {
    final lineas = GuionSemanas.lineasDe(semana, bloque);
    if (lineas == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DialogoScreen(lineas: lineas, idEscena: bloque),
      ),
    );
    if (!mounted) return;
    setState(() => _visitadosEstaSemana.add(bloque));
    estadoJuego.seleccionarNodo(bloque);
  }

  void _completarSemana(int semana) {
    estadoJuego.completarSemana(semana);
    setState(() => _visitadosEstaSemana.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Semana $semana completada! Estrés: ${estadoJuego.nivelEstres}/100',
        ),
        backgroundColor: const Color(0xFF1A237E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: estadoJuego,
      builder: (context, _) {
        final semana = estadoJuego.semanaActual;
        final intro = GuionSemanas.introDe(semana) ?? '';
        final visitados = _visitadosEstaSemana.length;
        final total = _ordenBloques.length;
        final desbloqueada = estadoJuego.semanaDesbloqueada(semana);
        final esUltima = semana >= EstadoJuego.totalSemanas;

        return Scaffold(
          backgroundColor: const Color(0xFF0B0F1A),
          appBar: AppBar(
            title: Text('Semana $semana de ${EstadoJuego.totalSemanas}'),
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _encabezado(semana, intro),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Escenas recorridas: $visitados / $total',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: desbloqueada
                    ? _listaBloques(semana)
                    : _bloqueado(semana),
              ),
              _barraAccion(semana, visitados, total, desbloqueada, esUltima),
            ],
          ),
        );
      },
    );
  }

  Widget _encabezado(int semana, String intro) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141824),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6C63FF), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_view_week, color: Color(0xFF00D9FF)),
              const SizedBox(width: 8),
              Text(
                'Semana $semana',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            intro,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _listaBloques(int semana) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _ordenBloques.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final bloque = _ordenBloques[i];
        final nombre = bloque == 'TEMPLO' ? 'El Templo' : 'Bloque $bloque';
        final visto = _visitadosEstaSemana.contains(bloque);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                visto ? const Color(0xFF2ECC71) : const Color(0xFF2A3444),
            child: Text(
              bloque == 'TEMPLO' ? 'T' : bloque,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(nombre, style: const TextStyle(color: Colors.white)),
          trailing: Icon(
            visto ? Icons.check_circle : Icons.chevron_right,
            color: visto ? const Color(0xFF2ECC71) : Colors.white38,
          ),
          onTap: () => _abrirBloque(semana, bloque),
        );
      },
    );
  }

  Widget _bloqueado(int semana) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: Colors.white38, size: 48),
            const SizedBox(height: 12),
            Text(
              'La Semana $semana está bloqueada.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Completa la semana anterior para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barraAccion(
      int semana, int visitados, int total, bool desbloqueada, bool esUltima) {
    final puedeCompletar = desbloqueada && visitados >= total;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (esUltima &&
                estadoJuego.semanasCompletadas.contains(EstadoJuego.totalSemanas))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Recorrido completo · ${estadoJuego.calcularResultadoFinal()}',
                  style: const TextStyle(
                    color: Color(0xFFFFE66D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: puedeCompletar ? () => _completarSemana(semana) : null,
              icon: const Icon(Icons.flag),
              label: Text(
                puedeCompletar
                    ? (esUltima ? 'Finalizar recorrido' : 'Completar semana $semana')
                    : 'Recorre todas las escenas ($visitados/$total)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
