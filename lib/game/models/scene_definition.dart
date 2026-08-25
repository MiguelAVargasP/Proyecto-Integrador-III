/// Definición data-driven de una escena de contenido.
///
/// La capa de juego (DATA) describe las escenas con identificadores opacos y
/// nombres legibles. El motor no conoce estas definiciones; el `GenericScene`
/// las resuelve en tiempo de carga desde el `SceneCatalog`.
library;

class SceneDefinition {
  const SceneDefinition({
    required this.id,
    required this.displayName,
    this.description = '',
    this.background = '',
  });

  /// Identificador opaco de la escena (ej. 'cafeteria').
  final String id;

  /// Nombre mostrable (ej. 'Cafetería').
  final String displayName;

  /// Texto breve de la escena.
  final String description;

  /// Ruta del fondo estático. Vacío cuando el asset aún no existe
  /// (`TODO: ASSET REQUIRED`) — regla §35: nunca referenciar assets
  /// inexistentes.
  final String background;

  /// Indica si la escena tiene un fondo asignado.
  bool get hasBackground => background.isNotEmpty;

  factory SceneDefinition.fromMap(Map<String, dynamic> map) {
    return SceneDefinition(
      id: map['id'] as String,
      displayName: map['displayName'] as String? ?? map['id'] as String,
      description: map['description'] as String? ?? '',
      background: map['background'] as String? ?? '',
    );
  }
}