import 'dart:ui';
import 'entity.dart';
import 'motor_render_context.dart';
import 'input_manager.dart';

/// Clase base para todas las escenas del motor de combate. Porte de
/// `engine/core/scene.py`. Una escena posee una lista de entidades y
/// dirige su ciclo de vida. El motor es agnóstico del juego: solo exige
/// que una escena exponga handleInput/update/render. Los hooks
/// opcionales onPhysicsStep/onCollisionStep corren después de las fases
/// correspondientes del loop principal.
///
/// Se llama `CombatScene` (no `Scene` a secas) para no chocar con
/// `EscenaCampus`/`MapaCampusScreen` del módulo de navegación — son
/// conceptos completamente distintos que conviven en el mismo proyecto.
class CombatScene {
  final List<Entity> entities = [];
  Color backgroundColor = const Color(0xFF14142A); // (20,20,40) del original

  /// Resolución de diseño en la que se posicionan las entidades (no la
  /// resolución real de pantalla). El `CombatLoop` escala este espacio
  /// lógico para llenar el tamaño real del dispositivo, preservando la
  /// proporción — sin esto, las coordenadas de las entidades (pensadas
  /// para esta resolución fija) solo ocupan una fracción diminuta de una
  /// pantalla real, que casi siempre es mucho más grande.
  Size logicalSize = const Size(320, 180);

  Entity addEntity(Entity entity) {
    entities.add(entity);
    return entity;
  }

  void removeEntity(Entity entity) => entities.remove(entity);

  void handleInput(InputManager inputManager) {
    for (final entity in entities) {
      entity.handleInput(inputManager);
    }
  }

  void update(double delta) {
    for (final entity in entities) {
      entity.update(delta);
    }
  }

  void render(MotorRenderContext renderer) {
    for (final entity in entities) {
      entity.render(renderer);
    }
  }

  /// Hook opcional ejecutado tras la fase de físicas de cada frame.
  void onPhysicsStep(double delta) {}

  /// Hook opcional ejecutado durante la fase de colisiones de cada frame.
  void onCollisionStep() {}
}