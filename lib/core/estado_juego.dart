import 'package:flutter/foundation.dart';

/// Estado global del progreso del jugador dentro del recorrido (distinto
/// de `EstadoMapa`, que solo sabe de navegación). Reúne los datos que las
/// historias de jugabilidad necesitan leer y escribir, para que ninguna
/// tenga que inventar dónde vive su dato ni duplicar estructuras.
///
/// Igual que `EstadoMapa`, es un `ChangeNotifier` simple a propósito, para
/// no adelantarse a la decisión de gestión de estado del paso de
/// arquitectura. Envuélvelo con Provider/Riverpod cuando se decida.
class EstadoJuego extends ChangeNotifier {
  // --- RF-06 / US-06: gestión del tiempo ---
  /// Horas disponibles para distribuir en la etapa actual.
  int tiempoDisponibleHoras = 0;

  /// Cuántas horas asignó el jugador a cada actividad (p. ej.
  /// {'estudio': 3, 'descanso': 2, 'trabajo_grupal': 1}).
  final Map<String, int> tiempoAsignadoPorActividad = {};

  void registrarTiempo(String actividad, int horas) {
    tiempoAsignadoPorActividad[actividad] =
        (tiempoAsignadoPorActividad[actividad] ?? 0) + horas;
    notifyListeners();
  }

  /// Retorna las horas asignadas previamente por actividad, o null si no
  /// hay guardado persistente disponible. Las pantallas llaman este método
  /// y verifican el null para usar valores por defecto.
  Future<Map<String, int>?> cargarTiempo(List<String> actividadesClave) async {
    return null;
  }

  // --- RF-08 / US-08: consecuencias acumuladas y estrés ---
  /// 0 = totalmente preparado, 100 = máximo estrés/menor preparación.
  int nivelEstres = 0;

  void ajustarEstres(int delta) {
    nivelEstres = (nivelEstres + delta).clamp(0, 100);
    notifyListeners();
  }

  // --- RF-16 / US-16: trazabilidad de decisiones de alto impacto ---
  final List<String> decisionesTomadas = [];

  void registrarDecision(String descripcion) {
    decisionesTomadas.add(descripcion);
    notifyListeners();
  }

  // --- RF-10 / US-10: insignias por hitos ---
  final Set<String> insigniasObtenidas = {};

  void otorgarInsignia(String id) {
    if (insigniasObtenidas.add(id)) notifyListeners();
  }

  // --- RF-05 / RF-14 / US-05 / US-14: etapas y progreso acumulado ---
  static const int totalEtapas = 3; // primeras clases, estudio independiente, parcial
  int etapasCompletadas = 0;

  void completarEtapa() {
    etapasCompletadas = (etapasCompletadas + 1).clamp(0, totalEtapas);
    notifyListeners();
  }

  double get progresoFraccional => etapasCompletadas / totalEtapas;

  // --- RF-15 / US-15: resultado final ---
  /// Se calcula al terminar el recorrido combinando estrés, tiempo
  /// asignado a estudio y decisiones tomadas. La fórmula real es decisión
  /// de diseño de US-08/US-15; se deja el método vacío como punto de
  /// extensión único (evita que cada pantalla calcule el resultado por su
  /// cuenta con lógica duplicada).
  String calcularResultadoFinal() {
    // TODO(US-15): reemplazar por la fórmula real acordada en Plan Mode.
    if (nivelEstres < 30) return 'Bien preparado';
    if (nivelEstres < 70) return 'Preparación irregular';
    return 'Poco preparado';
  }

  /// Reinicia un recorrido completo, borrando progreso, estrés, insignias,
  /// decisiones y tiempo asignado. Luego notifica a los listeners para que
  /// las pantallas se actualicen.
  void resetear() {
    nivelEstres = 0;
    tiempoDisponibleHoras = 0;
    tiempoAsignadoPorActividad.clear();
    etapasCompletadas = 0;
    insigniasObtenidas.clear();
    decisionesTomadas.clear();
    notifyListeners();
  }
}

final EstadoJuego estadoJuego = EstadoJuego();
