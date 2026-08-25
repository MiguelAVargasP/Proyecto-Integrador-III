/// Catálogo de actividades de tiempo, construido desde datos configurables.
///
/// Sigue el principio data-driven: las definiciones viven en
/// `time_actions_data.dart` y se convierten en [TimeActionDefinition]s del
/// motor aquí, de modo que el contenido se ajusta sin tocar el motor.
library;

import '../../engine/managers/time_manager.dart';
import 'time_actions_data.dart';

class TimeActionCatalog {
  TimeActionCatalog._(List<TimeActionDefinition> actions)
      : actions = List.unmodifiable(actions);

  /// Definiciones registradas.
  final List<TimeActionDefinition> actions;

  /// Construye el catálogo desde una lista de mapas data-driven.
  factory TimeActionCatalog.fromData(List<Map<String, dynamic>> data) {
    return TimeActionCatalog._(
      data.map(TimeActionDefinition.fromMap).toList(),
    );
  }

  static TimeActionCatalog? _defaultInstance;

  /// Catálogo por defecto del proyecto, cargado de forma diferida.
  static TimeActionCatalog defaultCatalog() {
    final instance = _defaultInstance;
    if (instance != null) return instance;
    final created = TimeActionCatalog.fromData(kTimeActionsData);
    _defaultInstance = created;
    return created;
  }

  /// Número de actividades.
  int get length => actions.length;
}