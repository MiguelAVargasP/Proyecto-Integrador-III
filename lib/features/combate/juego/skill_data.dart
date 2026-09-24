import 'card.dart';
import 'skill.dart';

/// Catálogo dirigido por datos que asigna cartas a habilidades
/// universales. Porte de `game/skills/skill_data.py`.
///
/// DIFERENCIA CON EL ORIGINAL: la versión Python carga
/// `data/skills/skills.json` y `data/skills/card_skill_map.json` desde
/// disco. Aquí, mientras no exista contenido real de las 52 habilidades
/// (ver la restricción "no implementar las 52 habilidades todavía" del
/// documento de diseño), el catálogo recibe sus definiciones directamente
/// como Maps en memoria — el mismo constructor que usa Python como ruta
/// alterna cuando no se cargan archivos. Cuando haya contenido real, se
/// puede agregar un `SkillCatalog.fromAssets()` que lea JSON empaquetado
/// en `assets/data/` sin cambiar el resto de la API.
class SkillCatalog {
  final Map<String, Map<String, dynamic>> definitions;
  final Map<String, String> cardMap;

  SkillCatalog({
    Map<String, Map<String, dynamic>>? definitions,
    Map<String, String>? cardMap,
  })  : definitions = definitions ?? {},
        cardMap = cardMap ?? {};

  /// Construye una Skill a partir de su id (null si el id es desconocido).
  Skill? get(String skillId) {
    final data = definitions[skillId];
    if (data == null) return null;
    return Skill(skillId, data);
  }

  /// true cuando el id dado existe en el catálogo.
  bool has(String skillId) => definitions.containsKey(skillId);

  /// Devuelve la Skill representada por `card` (null si no está mapeada).
  Skill? resolveCard(Card card) {
    final skillId = cardMap[card.shortName];
    if (skillId == null) return null;
    return get(skillId);
  }

  /// Recorre todas las habilidades del catálogo.
  Iterable<Skill> get skills sync* {
    for (final skillId in definitions.keys) {
      final skill = get(skillId);
      if (skill != null) yield skill;
    }
  }

  @override
  String toString() =>
      'SkillCatalog(skills: ${definitions.length}, cardsMapped: ${cardMap.length})';
}
