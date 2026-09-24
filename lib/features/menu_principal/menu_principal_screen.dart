import 'package:flutter/material.dart';
import '../../core/estado_juego.dart';
import '../../juego_identidad.dart';
import '../progreso/progreso_screen.dart' as progreso;
import '../resultados/resultados_screen.dart' as resultados;
import '../decisiones/decisiones_screen.dart' as decisiones;
import '../reiniciar/reiniciar_screen.dart' as reiniciar;
import '../gestion_tiempo/gestion_tiempo_contenido.dart' as gestion;

/// Pantalla de menu principal (post-escena).
///
/// Muestra las opciones disponibles al jugador despues de navegar por el mapa:
/// ver progreso, resultados, decisiones, reiniciar, o volver al mapa.
class MenuPrincipalScreen extends StatelessWidget {
  final VoidCallback onVolverAlMapa;

  const MenuPrincipalScreen({
    super.key,
    required this.onVolverAlMapa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JuegoIdentidad.fondo,
      appBar: AppBar(
        title: const Text(JuegoIdentidad.titulo),
        backgroundColor: JuegoIdentidad.primario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.map),
          onPressed: onVolverAlMapa,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: JuegoIdentidad.fondo,
                  title: const Text('Reiniciar'),
                  content: const Text(
                    'Esta accion borra tu progreso actual. Continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onVolverAlMapa();
                      },
                      child: const Text('Continuar'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Reiniciar (desde menu)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _avatarGuia(),
            const SizedBox(height: 16),
            _estadoActualCard(),
            const SizedBox(height: 24),
            _opcionMenu(
              icono: JuegoIdentidad.iconoProgreso(),
              titulo: 'Ver mi progreso',
              descripcion: 'Consulta tus etapas completadas, estres e insignias',
              color: JuegoIdentidad.acento1,
              onTap: () => _abrirProgreso(context),
            ),
            _opcionMenu(
              icono: JuegoIdentidad.iconoResultados(),
              titulo: 'Ver resultados',
              descripcion: 'Consulta tu resultado parcial o final del recorrido',
              color: JuegoIdentidad.acento2,
              onTap: () => _abrirResultados(context),
            ),
            _opcionMenu(
              icono: JuegoIdentidad.iconoDecisiones(),
              titulo: 'Ver mis decisiones',
              descripcion: 'Revisa las decisiones que has tomado y su impacto',
              color: JuegoIdentidad.exito,
              onTap: () => _abrirDecisiones(context),
            ),
            _opcionMenu(
              icono: JuegoIdentidad.iconoReiniciar(),
              titulo: 'Reiniciar recorrido',
              descripcion: 'Borra tu progreso y comienza de nuevo',
              color: JuegoIdentidad.alerta,
              onTap: () => _abrirReiniciar(context),
            ),
            _opcionMenu(
              icono: JuegoIdentidad.iconoGestionTiempo(),
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

  Widget _avatarGuia() {
    return Column(
      children: [
        JuegoIdentidad.avatar(size: 56),
        const SizedBox(height: 8),
        const Text(
          'Tu guia en el recorrido',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _estadoActualCard() {
    return Card(
      color: JuegoIdentidad.panel,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                JuegoIdentidad.avatar(size: 32),
                const SizedBox(width: 8),
                const Text(
                  'Estado actual',
                  style: TextStyle(
                      color: JuegoIdentidad.acento2,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
              style: const TextStyle(color: JuegoIdentidad.texto, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _opcionMenu({
    required IconData icono,
    required String titulo,
    String? descripcion,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: JuegoIdentidad.panel,
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
                child: Icon(icono, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: JuegoIdentidad.texto,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (descripcion != null)
                      Text(
                        descripcion,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
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
