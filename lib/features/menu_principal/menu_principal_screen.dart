import 'package:flutter/material.dart';
import '../../core/estado_juego.dart';
import '../progreso/progreso_screen.dart' as progreso;
import '../resultados/resultados_screen.dart' as resultados;
import '../decisiones/decisiones_screen.dart' as decisiones;
import '../reiniciar/reiniciar_screen.dart' as reiniciar;
import '../gestion_tiempo/gestion_tiempo_contenido.dart' as gestion;

/// Pantalla de menu principal/activity (post-escena).
///
/// Muestra las opciones disponibles al jugador despues de navegar por el mapa:
/// ver progreso, resultados, decisiones, reiniciar, o volver al mapa.
///
/// Se integra como pantalla intermedia entre el mapa y las escenas,
/// o como pantalla de cierre tras una escena.
class MenuPrincipalScreen extends StatelessWidget {
  final VoidCallback onVolverAlMapa;

  const MenuPrincipalScreen({
    super.key,
    required this.onVolverAlMapa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Orientacion UPB'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.map),
          onPressed: onVolverAlMapa,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _estadoActualCard(),
            const SizedBox(height: 24),
            _opcionMenu(
              icon: Icons.trending_up,
              titulo: 'Ver mi progreso',
              descripcion: 'Consulta tus etapas completadas, estres e insignias',
              color: Colors.indigo,
              onTap: () => _abrirProgreso(context),
            ),
            _opcionMenu(
              icon: Icons.assessment,
              titulo: 'Ver resultados',
              descripcion: 'Consulta tu resultado parcial o final del recorrido',
              color: Colors.amberAccent,
              onTap: () => _abrirResultados(context),
            ),
            _opcionMenu(
              icon: Icons.history,
              titulo: 'Ver mis decisiones',
              descripcion: 'Revisa las decisiones que has tomado y su impacto',
              color: Colors.greenAccent,
              onTap: () => _abrirDecisiones(context),
            ),
            _opcionMenu(
              icon: Icons.refresh,
              titulo: 'Reiniciar recorrido',
              descripcion: 'Borra tu progreso y comienza de nuevo',
              color: Colors.redAccent,
              onTap: () => _abrirReiniciar(context),
            ),
            _opcionMenu(
              icon: Icons.timer,
              titulo: 'Gestion del tiempo',
              descripcion: 'Distribuye tus horas entre actividades academicas y no academicas',
              color: Colors.purpleAccent,
              onTap: () => _abrirGestionTiempo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoActualCard() {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado actual',
              style: TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            const SizedBox(height: 8),
            _filaEstado('Etapas', '${estadoJuego.etapasCompletadas}/${EstadoJuego.totalEtapas}'),
            _filaEstado('Estres', '${estadoJuego.nivelEstres}/100'),
            _filaEstado('Insignias', '${estadoJuego.insigniasObtenidas.length}'),
            _filaEstado('Decisiones', '${estadoJuego.decisionesTomadas.length}'),
          ],
        ),
      ),
    );
  }

  Widget _filaEstado(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _opcionMenu({
    required IconData icon,
    required String titulo,
    required String descripcion,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descripcion,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirProgreso(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => progreso.ProgresoScreen(
          etapasCompletadas: estadoJuego.etapasCompletadas,
          totalEtapas: EstadoJuego.totalEtapas,
          nivelEstres: estadoJuego.nivelEstres,
          tiempoDisponibleHoras: estadoJuego.tiempoDisponibleHoras,
          tiempoAsignadoPorActividad: Map.of(estadoJuego.tiempoAsignadoPorActividad),
          insigniasObtenidas: Set.of(estadoJuego.insigniasObtenidas),
          onVolver: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _abrirResultados(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => resultados.ResultadosScreen(
          nivelEstres: estadoJuego.nivelEstres,
          etapasCompletadas: estadoJuego.etapasCompletadas,
          totalEtapas: EstadoJuego.totalEtapas,
          decisionesTomadas: List.of(estadoJuego.decisionesTomadas),
          insigniasObtenidas: Set.of(estadoJuego.insigniasObtenidas),
          tiempoAsignadoPorActividad: Map.of(estadoJuego.tiempoAsignadoPorActividad),
          onReiniciar: () {
            Navigator.of(context).pop();
          },
          onVolverAlMenu: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _abrirDecisiones(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => decisiones.DecisionesScreen(
          decisionesTomadas: List.of(estadoJuego.decisionesTomadas),
          onVolver: () => Navigator.of(context).pop(),
          titulo: 'Mis decisiones',
        ),
      ),
    );
  }

  void _abrirReiniciar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => reiniciar.ReiniciarScreen(
          onReiniciar: () {
            Navigator.of(context).pop();
            estadoJuego.resetear();
          },
          onVolver: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _abrirGestionTiempo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => gestion.GestionTiempoContenido().construir(
              context,
              () => Navigator.of(context).pop(),
            ),
      ),
    );
  }
}
