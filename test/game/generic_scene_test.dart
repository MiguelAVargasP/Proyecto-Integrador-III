/// Pruebas del [GenericScene]: resolución data-driven al cargar.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/game_engine.dart';
import 'package:juegoupb/game/data/scene_catalog.dart';
import 'package:juegoupb/game/scenes/generic_scene.dart';

void main() {
  group('GenericScene', () {
    test('resuelve su definición desde el catálogo al cargar', () {
      final engine = GameEngine();
      final scene = GenericScene(id: 'cafeteria');
      engine.registerScene(scene);
      expect(engine.changeScene('cafeteria'), isTrue);
      expect(scene.definition, isNotNull);
      expect(scene.hasDefinition, isTrue);
      expect(scene.displayName, 'Cafetería');
    });

    test('usa el id como nombre cuando no hay definición', () {
      final engine = GameEngine();
      final scene = GenericScene(id: 'desconocida');
      engine.registerScene(scene);
      expect(engine.changeScene('desconocida'), isTrue);
      expect(scene.definition, isNull);
      expect(scene.hasDefinition, isFalse);
      expect(scene.displayName, 'desconocida');
    });

    test('acepta un catálogo inyectado (pruebas aisladas)', () {
      final catalog = SceneCatalog.fromData([
        {'id': 'sala_x', 'displayName': 'Sala X'},
      ]);
      final engine = GameEngine();
      final scene = GenericScene(id: 'sala_x', catalog: catalog);
      engine.registerScene(scene);
      expect(engine.changeScene('sala_x'), isTrue);
      expect(scene.displayName, 'Sala X');
    });

    test('integración: navegación completa con escenas del catálogo', () {
      final engine = GameEngine();
      engine.registerScenes(
        SceneCatalog.defaultCatalog().all.map((d) => GenericScene(id: d.id)),
      );
      expect(engine.navigateTo('biblioteca'), isTrue);
      expect(engine.current, isA<GenericScene>());
      expect((engine.current! as GenericScene).displayName, 'Biblioteca');
      expect(engine.state.visitedScenes, ['biblioteca']);
    });
  });
}