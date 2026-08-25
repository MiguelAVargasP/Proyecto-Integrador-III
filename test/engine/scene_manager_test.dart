/// Pruebas del [SceneManager]: registro, consulta y escena activa.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/core/scene.dart';
import 'package:juegoupb/engine/core/scene_manager.dart';

class _Scene extends GameScene {
  _Scene({required super.id});
}

void main() {
  group('SceneManager', () {
    test('empieza vacío y sin escena activa', () {
      final manager = SceneManager();
      expect(manager.current, isNull);
      expect(manager.length, 0);
    });

    test('registra escenas y las reconoce', () {
      final manager = SceneManager();
      manager.register(_Scene(id: 'map'));
      manager.registerAll([_Scene(id: 'cafeteria'), _Scene(id: 'biblioteca')]);
      expect(manager.length, 3);
      expect(manager.knows('map'), isTrue);
      expect(manager.knows('gimnasio'), isFalse);
    });

    test('enter marca la escena activa y la devuelve', () {
      final manager = SceneManager();
      final scene = _Scene(id: 'map');
      manager.register(scene);
      expect(manager.enter('map'), same(scene));
      expect(manager.current, same(scene));
    });

    test('enter con id desconocido devuelve null', () {
      final manager = SceneManager();
      expect(manager.enter('nope'), isNull);
      expect(manager.current, isNull);
    });

    test('get devuelve la escena registrada', () {
      final manager = SceneManager();
      final scene = _Scene(id: 'map');
      manager.register(scene);
      expect(manager.get('map'), same(scene));
      expect(manager.get('nope'), isNull);
    });

    test('unregister elimina y limpia la escena activa si coincide', () {
      final manager = SceneManager();
      manager.register(_Scene(id: 'map'));
      manager.enter('map');
      expect(manager.unregister('map'), isTrue);
      expect(manager.current, isNull);
      expect(manager.unregister('map'), isFalse);
    });

    test('unregister de una escena inactiva no toca la activa', () {
      final manager = SceneManager();
      manager.registerAll([_Scene(id: 'map'), _Scene(id: 'cafeteria')]);
      manager.enter('map');
      expect(manager.unregister('cafeteria'), isTrue);
      expect(manager.current?.id, 'map');
    });
  });
}