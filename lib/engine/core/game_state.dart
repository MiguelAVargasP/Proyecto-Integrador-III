/// Estado serializable del juego.
///
/// El motor es agnóstico de contenido: los identificadores de etapa, escena,
/// decisión o insignia son cadenas opacas definidas por la capa de juego
/// (DATA). El motor solo gestiona el contenedor de estado, sus estadísticas
/// numéricas y los registros de progreso.
///
/// Diseñado para que el guardado (US-20) pueda reconstruir la partida a partir
/// de [toJson]/[fromJson], estructurado con un `schemaVersion` versionable.
library;

import 'dart:convert';

/// Versión actual del esquema de serialización del estado.
const int kGameStateSchemaVersion = 1;

class GameState {
  GameState({
    this.schemaVersion = kGameStateSchemaVersion,
    this.stageId = '',
    this.sceneId = '',
    this.progressIndex = 0,
    Map<String, double>? stats,
    Map<String, String>? strings,
  })  : stats = Map.of(stats ?? {}),
        strings = Map.of(strings ?? {});

  /// Versión del esquema de serialización (para migraciones futuras).
  final int schemaVersion;

  /// Identificador (opaco) de la etapa actual del ciclo estudiantil.
  String stageId;

  /// Identificador (opaco) de la escena actual.
  String sceneId;

  /// Índice de avance global del recorrido (0 = inicio, N = fin).
  int progressIndex;

  /// Valores numéricos del jugador, p. ej. estrés, preparación, desempeño.
  final Map<String, double> stats;

  /// Valores de texto configurables (preferencias, extras).
  final Map<String, String> strings;

  /// Escenas visitadas durante la partida (sin duplicados).
  final List<String> visitedScenes = [];

  /// Historial de decisiones tomadas, en orden.
  final List<String> decisionLog = [];

  /// Insignias conseguidas (hitos), sin duplicados.
  final List<String> badges = [];

  /// Indica si la partida alcanzó un estado final (boletín emitido).
  bool isFinished = false;

  bool get hasStats => stats.isNotEmpty;

  /// Devuelve el valor de una estadística (o [fallback] si no existe).
  double stat(String key, {double fallback = 0.0}) => stats[key] ?? fallback;

  /// Fija una estadística acotada entre [min] y [max]; devuelve el valor final.
  double setStat(String key, double value,
      {double min = 0.0, double max = 100.0}) {
    final v = value.clamp(min, max).toDouble();
    stats[key] = v;
    return v;
  }

  /// Modifica una estadística en [delta], acotada entre [min, max].
  double modifyStat(String key, double delta,
          {double min = 0.0, double max = 100.0}) =>
      setStat(key, stat(key) + delta, min: min, max: max);

  /// Registra que la escena [sceneId] fue visitada (sin duplicados).
  void recordVisitedScene(String sceneKey) {
    if (!visitedScenes.contains(sceneKey)) visitedScenes.add(sceneKey);
  }

  /// Registra una decisión tomada, en orden.
  void recordDecision(String decisionId) => decisionLog.add(decisionId);

  /// Otorga una insignia (sin duplicados).
  void awardBadge(String badgeId) {
    if (!badges.contains(badgeId)) badges.add(badgeId);
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'stageId': stageId,
      'sceneId': sceneId,
      'progressIndex': progressIndex,
      'stats': stats,
      'strings': strings,
      'visitedScenes': visitedScenes,
      'decisionLog': decisionLog,
      'badges': badges,
      'isFinished': isFinished,
    };
  }

  /// Devuelve una representación JSON/string del estado para guardar.
  String encode() => jsonEncode(toJson());

  /// Reconstruye un [GameState] desde un mapa JSON.
  factory GameState.fromJson(Map<String, dynamic> json) {
    final state = GameState(
      schemaVersion: json['schemaVersion'] as int? ?? kGameStateSchemaVersion,
      stageId: json['stageId'] as String? ?? '',
      sceneId: json['sceneId'] as String? ?? '',
      progressIndex: json['progressIndex'] as int? ?? 0,
    );
    final rawStats = json['stats'] as Map<String, dynamic>? ?? {};
    rawStats.forEach((k, v) => state.stats[k] = (v as num).toDouble());
    final rawStrings = json['strings'] as Map<String, dynamic>? ?? {};
    rawStrings
        .forEach((k, v) => state.strings[k] = v as String);
    state.visitedScenes.addAll((json['visitedScenes'] as List? ?? []).cast<String>());
    state.decisionLog.addAll((json['decisionLog'] as List? ?? []).cast<String>());
    state.badges.addAll((json['badges'] as List? ?? []).cast<String>());
    state.isFinished = json['isFinished'] as bool? ?? false;
    return state;
  }

  /// Reconstruye un [GameState] desde una string JSON.
  factory GameState.decode(String source) =>
      GameState.fromJson(jsonDecode(source) as Map<String, dynamic>);
}