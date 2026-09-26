import 'package:flutter/material.dart';
import '../../core/contenido_escena.dart';
import '../../core/estado_juego.dart';

/// Contenido jugable para US-06: Gestion del tiempo del jugador.
///
/// El jugador distribuye horas entre actividades academicas y no academicas
/// y ve el efecto en su nivel de estres.
///
/// Flujo:
/// 1. Se muestra la cantidad de horas disponibles para la etapa actual.
/// 2. El jugador asigna horas a cada actividad (sumando/restando con botones).
/// 3. Al confirmar, se registran las horas en EstadoJuego y se calcula el
///    cambio de estres.
/// 4. Se marca la etapa como completada.
class GestionTiempoContenido implements ContenidoEscena {
  /// Horas totales disponibles para esta etapa.
  final int horasTotales;

  /// Actividades disponibles y sus efectos de estres.
  final Map<String, (int horasBase, int deltaEstres)> actividades;

  GestionTiempoContenido({
    this.horasTotales = 12,
    this.actividades = const {
      'Estudio independiente': (4, -2),
      'Clases y seminarios': (3, -1),
      'Trabajo grupal': (2, 2),
      'Descanso y ocio': (2, -4),
      'Bienestar personal': (1, -3),
    },
  });

  @override
  Widget construir(BuildContext context, VoidCallback onCompletada) {
    return _GestionTiempoScreen(
      horasTotales: horasTotales,
      actividades: actividades,
      onCompletada: onCompletada,
    );
  }
}

class _GestionTiempoScreen extends StatefulWidget {
  final int horasTotales;
  final Map<String, (int, int)> actividades;
  final VoidCallback onCompletada;

  const _GestionTiempoScreen({
    required this.horasTotales,
    required this.actividades,
    required this.onCompletada,
  });

  @override
  State<_GestionTiempoScreen> createState() => _GestionTiempoScreenState();
}

class _GestionTiempoScreenState extends State<_GestionTiempoScreen> {
  late Map<String, int> _asignaciones;
  int get _horasUsadas => _asignaciones.values.fold(0, (sum, h) => sum + h);
  int get _horasRestantes => widget.horasTotales - _horasUsadas;

  @override
  void initState() {
    super.initState();
    _asignaciones = Map.fromIterable(
      widget.actividades.keys,
      value: (key) => widget.actividades[key]!.$1,
    );
    _cargarTiempo();
  }

  Future<void> _cargarTiempo() async {
    final tiempo = await estadoJuego.cargarTiempo(widget.actividades.keys.toList());
    if (tiempo != null) {
      if (!mounted) return;
      setState(() {
        _asignaciones = Map.from(tiempo);
      });
    }
  }

  void _sumarHoras(String actividad, int delta) {
    final actual = _asignaciones[actividad] ?? 0;
    final nuevo = actual + delta;
    if (nuevo < 0) return;
    if (_horasUsadas - actual + nuevo > widget.horasTotales) return;
    setState(() {
      _asignaciones[actividad] = nuevo;
    });
  }

  bool get _puedeConfirmar => _horasUsadas == widget.horasTotales;

  void _confirmar() {
    for (final entry in _asignaciones.entries) {
      estadoJuego.registrarTiempo(entry.key, entry.value);
    }
    estadoJuego.completarEtapa();
    // US-13: retroalimentacion inmediata visual al confirmar asignacion
    final prevEstres = estadoJuego.nivelEstres;
    // Calcula el delta de estres que genero esta decision
    int deltaTotal = 0;
    for (final entry in widget.actividades.entries) {
      final (_, deltaEstres) = entry.value;
      final horas = _asignaciones[entry.key] ?? 0;
      deltaTotal += deltaEstres * horas;
    }
    // Aplica el delta al mostrar feedback (el estado ya fue registrado)
    final nuevoEstres = (prevEstres + deltaTotal).clamp(0, 100);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Distribucion confirmada: estrés ${prevEstres} → ${nuevoEstres}',
        ),
        backgroundColor: nuevoEstres > 60
            ? Colors.redAccent
            : nuevoEstres > 30
                ? Colors.amberAccent
                : Colors.greenAccent,
        duration: const Duration(seconds: 3),
      ),
    );
    widget.onCompletada();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Distribuye tu tiempo'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: const Color(0xFF1A1A2E),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'Horas disponibles',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, color: Colors.amberAccent, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '$_horasRestantes / ${widget.horasTotales}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_off, color: Colors.white24, size: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            ...widget.actividades.keys.map((actividad) {
              final (horasBase, deltaEstres) = widget.actividades[actividad]!;
              final horas = _asignaciones[actividad] ?? 0;
              final esPosibleSumar = _horasRestantes > 0 && horas < horasBase * 3;
              final esPosibleRestar = horas > 0;

              return Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              actividad,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            '$horas h',
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _efectoEstres(deltaEstres, horas),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _botonSumarRestar(
                            icon: Icons.remove,
                            color: Colors.redAccent,
                            onPressed: esPosibleRestar
                                ? () => _sumarHoras(actividad, -1)
                                : null,
                          ),
                          Expanded(
                            child: _deslizadorHoras(actividad),
                          ),
                          _botonSumarRestar(
                            icon: Icons.add,
                            color: Colors.greenAccent,
                            onPressed: esPosibleSumar
                                ? () => _sumarHoras(actividad, 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _horasUsadas / widget.horasTotales,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation(Colors.indigo),
              minHeight: 8,
            ),
            Text(
              '$_horasUsadas / ${widget.horasTotales} horas asignadas',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _puedeConfirmar ? _confirmar : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar distribucion'),
            ),
            if (!_puedeConfirmar)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Asigna todas las horas para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _botonSumarRestar({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (onPressed != null ? color : Colors.grey[800])!.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          color: onPressed != null ? color : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  Widget _deslizadorHoras(String actividad) {
    final horas = _asignaciones[actividad] ?? 0;
    return SizedBox(
      height: 36,
      child: Slider(
        value: horas.toDouble(),
        min: 0,
        max: widget.horasTotales.toDouble(),
        divisions: widget.horasTotales,
        onChanged: (val) {
          final nuevo = val.round();
          if (nuevo >= 0 && (_horasUsadas - horas + nuevo) <= widget.horasTotales) {
            setState(() {
              _asignaciones[actividad] = nuevo;
            });
          }
        },
        activeColor: Colors.indigo,
        inactiveColor: Colors.grey[800],
      ),
    );
  }

  Widget _efectoEstres(int deltaEstres, int horas) {
    final deltaTotal = deltaEstres * horas;
    final esNegativo = deltaTotal < 0;
    final esCero = deltaTotal == 0;

    Color color;
    String texto;
    IconData icono;

    if (esCero) {
      color = Colors.white38;
      texto = 'Sin efecto de estres';
      icono = Icons.help_outline;
    } else if (esNegativo) {
      color = Colors.greenAccent;
      texto = 'Reduce ${-deltaTotal} puntos de estres';
      icono = Icons.arrow_downward;
    } else {
      color = Colors.redAccent;
      texto = 'Aumenta $deltaTotal puntos de estres';
      icono = Icons.arrow_upward;
    }

    return Row(
      children: [
        Icon(icono, color: color, size: 16),
        const SizedBox(width: 6),
        Text(texto, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}