import 'card.dart';
import 'cooldown.dart';
import 'poker_evaluator.dart';

/// Representación estática de una superhabilidad elegida a partir de la
/// mano. Solo lleva datos (nombre, tipo, nivel de poder, tiempos) en esta
/// etapa. Contenido futuro conecta el efecto concreto en combate a
/// través de `effect`. Porte directo de `game/combat/super_manager.py`.
class SuperAbility {
  final int rank;
  final String name;
  final String kind;
  final String description;
  final double activeTime;
  final double cooldownTime;
  final int power;

  SuperAbility({
    required this.rank,
    required this.name,
    required this.kind,
    required this.description,
    required this.activeTime,
    required this.cooldownTime,
    required this.power,
  });

  /// Punto de extensión donde cae el efecto concreto del super (no hace
  /// nada todavía).
  dynamic effect(dynamic owner, [dynamic opponent]) => null;

  @override
  String toString() =>
      'SuperAbility(name: $name, rank: $rank, kind: $kind, power: $power)';
}

/// Evalúa la mano del fighter y administra su slot de superhabilidad.
///
/// El pipeline: Hand -> PokerEvaluator -> PokerCombination -> SuperAbility.
/// El super reutiliza el mismo ciclo READY -> ACTIVE -> COOLDOWN -> READY
/// que las cinco habilidades normales, así que una sexta acción (el botón
/// "super") se comporta igual que ellas, pero con un poder derivado de
/// la mano en vez de una sola carta.
///
/// DIFERENCIA CON EL ORIGINAL: la versión Python carga
/// `data/combat/supers.json` desde disco para personalizar nombre/tipo/
/// tiempos por rango de combinación. Aquí, mientras ese contenido no
/// exista, `definitions` por defecto es un mapa vacío — lo cual ya
/// produce un SuperManager completamente funcional, porque `_buildAbility`
/// cae en valores genéricos razonables (nombre de la combinación, tipo
/// "strike", 1s activo / 8s de cooldown) cuando no hay una entrada
/// específica para ese rango, exactamente igual que en Python.
class SuperManager {
  final Map<String, Map<String, dynamic>> definitions;
  final PokerEvaluator evaluator = PokerEvaluator();
  PokerCombination? combination;
  SuperAbility? ability;
  SkillCooldownTracker _cooldown = SkillCooldownTracker();

  SuperManager({Map<String, Map<String, dynamic>>? definitions})
      : definitions = definitions ?? {};

  /// Evalúa la mano y construye su superhabilidad a partir de la
  /// combinación resultante. Devuelve la PokerCombination (también
  /// queda guardada para inspección).
  PokerCombination loadHand(Iterable<Card> hand) {
    final combinacion = evaluator.evaluate(hand);
    combination = combinacion;
    ability = _buildAbility(combinacion);
    _cooldown = SkillCooldownTracker(
      activeTime: ability!.activeTime,
      cooldownTime: ability!.cooldownTime,
    );
    return combinacion;
  }

  /// Olvida la mano y habilidad actuales (se usa al empezar un round nuevo).
  void clear() {
    combination = null;
    ability = null;
    _cooldown = SkillCooldownTracker();
  }

  SuperAbility _buildAbility(PokerCombination combinacion) {
    final entry = definitions[combinacion.rank.toString()] ?? const {};
    return SuperAbility(
      rank: combinacion.rank,
      name: (entry['name'] as String?) ?? combinacion.name,
      kind: (entry['kind'] as String?) ?? 'strike',
      description: (entry['description'] as String?) ?? '',
      activeTime: (entry['active_time'] as num?)?.toDouble() ?? 1.0,
      cooldownTime: (entry['cooldown'] as num?)?.toDouble() ?? 8.0,
      power: combinacion.rank,
    );
  }

  /// Activa el super cuando hay uno cargado y está READY. true si conectó.
  bool tryActivate() {
    if (ability == null) return false;
    return _cooldown.tryActivate();
  }

  /// Avanza el cooldown del super en `delta` segundos.
  void update(double delta) => _cooldown.update(delta);

  /// true cuando hay un super cargado y se puede usar ahora mismo.
  bool get isReady => ability != null && _cooldown.isReady();

  /// Fase del slot de super: READY/ACTIVE/COOLDOWN/NONE.
  String state() {
    if (ability == null) return 'NONE';
    return _cooldown.state;
  }

  /// Segundos restantes de cooldown (0 si está listo o no hay super).
  double cooldownRemaining() {
    if (ability == null) return 0.0;
    return _cooldown.remaining();
  }

  /// Poder numérico del super cargado (0 si no hay mano cargada).
  int get power => ability?.power ?? 0;

  @override
  String toString() {
    final nombre = ability?.name ?? '-';
    return 'SuperManager(ability: $nombre, state: ${state()})';
  }
}