import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado global del progreso del jugador dentro del recorrido (distinto
/// de `EstadoMapa`, que solo sabe de navegación). Reúne los datos que las
/// historias de jugabilidad necesitan leer y escribir, para que ninguna
/// tenga que inventar dónde vive su dato ni duplicar estructuras.
///
/// Igual que `EstadoMapa`, es un `ChangeNotifier` simple a propósito, para
/// no adelantarse a la decisión de gestión de estado del paso de
/// arquitectura. Envuélvelo con Provider/Riverpod cuando se decida.
class EstadoJuego extends ChangeNotifier {
  static const _clavePartida = 'partida_juego';

  // --- RF-06 / US-06: gestión del tiempo ---
  /// Horas disponibles para distribuir en la etapa actual.
  int tiempoDisponibleHoras = 0;

  /// Cuántas horas asignó el jugador a cada actividad (p. ej.
  /// {'estudio': 3, 'descanso': 2, 'trabajo_grupal': 1}).
  final Map<String, int> tiempoAsignadoPorActividad = {};

  /// Getter compatible con ReflexionEtapa (US-11): horas asignadas por actividad.
  Map<String, int> get tiempoPorActividad => tiempoAsignadoPorActividad;

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

  /// Devuelve verdadero si la descripción coincide con patrones de decisiones
  /// de alto impacto (RF-16: el sistema advierte antes de estas decisiones).
  bool esDecisionAltoImpacto(String descripcion) {
    final palabrasClave = [
      'estudiar menos',
      'rendirse',
      'no estudiar',
      'delegar toda',
      'copiar',
      'plagio',
      'entregar tarde',
      'faltar a clase',
      'impunidad',
      'evadir',
    ];
    final lower = descripcion.toLowerCase();
    for (final palabra in palabrasClave) {
      if (lower.contains(palabra)) return true;
    }
    return false;
  }

  /// Alias con ortografía anterior para compatibilidad.
  bool esDecicionAltoImpacto(String descripcion) => esDecisionAltoImpacto(descripcion);

  // --- RF-10 / US-10: insignias por hitos ---
  final Set<String> insigniasObtenidas = {};

  /// Callback para desacoplar la notificación visual cuando no se dispone de BuildContext.
  void Function(String id, String nombre)? onInsigniaOtorgada;

  /// Retorna un nombre legible y descriptivo para una insignia (US-10).
  static String nombreInsignia(String id) {
    switch (id) {
      case 'FASE_2':
        return 'Primeras Clases';
      case 'FASE_3':
        return 'Estudio Independiente';
      case 'D':
        return 'Superviviente del Parcial';
      default:
        return id;
    }
  }

  /// Otorga una insignia y dispara una notificación visible al jugador (US-10).
  void otorgarInsignia(String id, [BuildContext? context]) {
    if (insigniasObtenidas.add(id)) {
      notifyListeners();
      final nombre = nombreInsignia(id);
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
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
      } else if (onInsigniaOtorgada != null) {
        onInsigniaOtorgada!(id, nombre);
      }
    }
  }

  // --- RF-05 / RF-14 / US-05 / US-14: etapas y progreso acumulado ---
  static const int totalEtapas = 3; // primeras clases, estudio independiente, parcial
  int etapasCompletadas = 0;

  void completarEtapa() {
    etapasCompletadas = (etapasCompletadas + 1).clamp(0, totalEtapas);
    notifyListeners();
  }

  double get progresoFraccional => etapasCompletadas / totalEtapas;

  // --- Estructura de las 8 semanas (progresión del juego serio) ---
  // Son campos NUEVOS e independientes de `etapasCompletadas`/`totalEtapas`
  // (que miden el ciclo de 3 etapas). El recorrido narrativo se divide en 8
  // semanas; este estado solo lleva la cuenta de esa progresión sin alterar
  // la lógica ya construida de etapas.
  static const int totalSemanas = 8;

  /// Semana actual del recorrido narrativo (1..8). Empieza en 1.
  int semanaActual = 1;

  /// Semanas ya completadas (identificadas por su número, 1..8).
  final Set<int> semanasCompletadas = {};

  /// Id del nodo (bloque A..L o 'TEMPLO') actual dentro de la semana.
  String? nodoActualId;

  /// Bloques (A..L y 'TEMPLO') cuyo diálogo ya se completó en la semana
  /// actual. Se vacía al completar la semana. Se persiste con la partida.
  final Set<String> bloquesVisitadosSemana = {};

  /// Todos los bloques con diálogo en el mapa (A-L y el Templo).
  static const List<String> bloquesDeSemana = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'TEMPLO',
  ];

  /// Bloques OBLIGATORIOS para completar la semana: A-L. El Templo es
  /// opcional (se puede visitar, pero no se exige).
  static const List<String> bloquesObligatorios = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L',
  ];

  /// Cuántos bloques obligatorios ya se recorrieron esta semana.
  int get obligatoriosVisitados => bloquesObligatorios
      .where(bloquesVisitadosSemana.contains)
      .length;

  /// `true` cuando ya se recorrieron todos los bloques obligatorios.
  bool get semanaListaParaCompletar =>
      obligatoriosVisitados >= bloquesObligatorios.length;

  /// Registra que el diálogo de un bloque se completó (y guarda la partida).
  void marcarBloqueVisitado(String id) {
    if (!bloquesDeSemana.contains(id)) return;
    if (bloquesVisitadosSemana.add(id)) {
      nodoActualId = id;
      notifyListeners();
      guardar();
    }
  }

  /// `true` una vez superado el evento del parcial (fin del recorrido).
  bool parcialSuperado = false;

  /// Porcentaje de progreso narrativo (0.0 a 1.0) sobre las 8 semanas.
  double get progresoSemanasFraccional => semanasCompletadas.length / totalSemanas;

  /// Marca una semana como completada y avanza `semanaActual` a la siguiente
  /// si corresponde (sin pasarse de `totalSemanas`). Idempotente.
  void completarSemana(int semana) {
    if (semana < 1 || semana > totalSemanas) return;
    semanasCompletadas.add(semana);
    if (semanaActual == semana && semana < totalSemanas) {
      semanaActual = semana + 1;
    }
    bloquesVisitadosSemana.clear();
    notifyListeners();
    guardar();
  }

  /// Indica si una semana está desbloqueada para jugar. La semana 1 siempre
  /// lo está; la N requiere la N-1 completada (progresión encadenada).
  bool semanaDesbloqueada(int semana) {
    if (semana <= 1) return true;
    return semanasCompletadas.contains(semana - 1);
  }

  /// Fija el nodo (blque) actual del recorrido.
  void seleccionarNodo(String id) {
    nodoActualId = id;
    notifyListeners();
  }


  // --- RF-15 / US-15: resultado final ---
  /// Calcula el resultado final del recorrido (US-15).
  ///
  /// Fórmula acordada para el cierre del ciclo:
  /// - `nivelEstres < 30`: 'Bien preparado' (preparación sólida, equilibrio saludable).
  /// - `nivelEstres < 70`: 'Preparación irregular' (preparación media con sobrecarga o vacíos).
  /// - `nivelEstres >= 70`: 'Poco preparado' (alto estrés o decisiones académicas perjudiciales).
  String calcularResultadoFinal() {
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
    // Reinicia también la progresión de las 8 semanas.
    semanaActual = 1;
    semanasCompletadas.clear();
    bloquesVisitadosSemana.clear();
    nodoActualId = null;
    parcialSuperado = false;
    notifyListeners();
    guardar();
  }

  // --- US-20: guardado, reanudación y gestión de partidas ---

  /// Serializa el estado actual a JSON para guardarlo persistentemente.
  Map<String, dynamic> toJson() => {
        'nivelEstres': nivelEstres,
        'tiempoDisponibleHoras': tiempoDisponibleHoras,
        'tiempoAsignadoPorActividad': tiempoAsignadoPorActividad,
        'decisionesTomadas': decisionesTomadas,
        'insigniasObtenidas': insigniasObtenidas.toList(),
        'etapasCompletadas': etapasCompletadas,
        'semanaActual': semanaActual,
        'semanasCompletadas': semanasCompletadas.toList(),
        'nodoActualId': nodoActualId,
        'bloquesVisitadosSemana': bloquesVisitadosSemana.toList(),
        'parcialSuperado': parcialSuperado,
      };

  /// Deserializa desde JSON y reinicia el estado actual con esos datos.
  void fromJson(Map<String, dynamic> json) {
    nivelEstres = json['nivelEstres'] as int? ?? 0;
    tiempoDisponibleHoras = json['tiempoDisponibleHoras'] as int? ?? 0;
    etapasCompletadas = json['etapasCompletadas'] as int? ?? 0;
    final tiempoJson = json['tiempoAsignadoPorActividad'] as Map<String, dynamic>?;
    if (tiempoJson != null) {
      tiempoAsignadoPorActividad.clear();
      tiempoJson.forEach((k, v) {
        tiempoAsignadoPorActividad[k] = v as int;
      });
    }
    final decJson = json['decisionesTomadas'] as List<dynamic>?;
    if (decJson != null) {
      decisionesTomadas.clear();
      decisionesTomadas.addAll(decJson.cast<String>());
    }
    final insJson = json['insigniasObtenidas'] as List<dynamic>?;
    if (insJson != null) {
      insigniasObtenidas.clear();
      insigniasObtenidas.addAll(insJson.cast<String>());
    }
    // Progresión de las 8 semanas. Se leen con defaults seguros para que una
    // partida guardada ANTES de esta función siga cargando sin romperse.
    semanaActual = (json['semanaActual'] as int?) ?? 1;
    final semJson = json['semanasCompletadas'] as List<dynamic>?;
    if (semJson != null) {
      semanasCompletadas.clear();
      semanasCompletadas.addAll(semJson.cast<int>());
    }
    nodoActualId = json['nodoActualId'] as String?;
    final bloquesJson = json['bloquesVisitadosSemana'] as List<dynamic>?;
    bloquesVisitadosSemana.clear();
    if (bloquesJson != null) {
      bloquesVisitadosSemana.addAll(bloquesJson.cast<String>());
    }
    parcialSuperado = json['parcialSuperado'] as bool? ?? false;
    notifyListeners();
  }

  /// Guarda el estado actual en `shared_preferences` (disk).
  Future<bool> guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(toJson());
      return await prefs.setString(_clavePartida, json);
    } catch (_) {
      return false;
    }
  }

  /// Carga el estado guardado desde `shared_preferences` (disk).
  /// Retorna `true` si existía una partida guardada y se cargó.
  Future<bool> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_clavePartida);
      if (jsonStr == null) return false;
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      fromJson(json);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Elimina el guardado persistente (reiniciar limpio entre sesiones).
  Future<bool> borrarGuardado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_clavePartida);
    } catch (_) {
      return false;
    }
  }
}

final EstadoJuego estadoJuego = EstadoJuego();
