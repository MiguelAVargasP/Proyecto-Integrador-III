/// Pruebas del catálogo de escenas data-driven.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/game/data/scene_catalog.dart';
import 'package:juegoupb/game/data/scenes_data.dart';

void main() {
  group('SceneCatalog', () {
    test('el catálogo por defecto cubre los datos definidos', () {
      final catalog = SceneCatalog.defaultCatalog();
      expect(catalog.length, kScenesData.length);
      expect(catalog.knows('map'), isTrue);
      expect(catalog.get('map'), isNotNull);
    });

    test('construye desde datos arbitrarios (principio data-driven)', () {
      final catalog = SceneCatalog.fromData([
        {'id': 'cafeteria', 'displayName': 'Cafetería', 'description': '...'},
        {'id': 'aulas'},
      ]);
      expect(catalog.length, 2);
      expect(catalog.get('cafeteria')?.displayName, 'Cafetería');
      // Sin displayName, cae al id.
      expect(catalog.get('aulas')?.displayName, 'aulas');
    });

    test('escena desconocida devuelve null', () {
      final catalog = SceneCatalog.fromData([]);
      expect(catalog.get('nope'), isNull);
      expect(catalog.knows('nope'), isFalse);
    });

    test('las definiciones incluyen descripción y background opcionales', () {
      final catalog = SceneCatalog.defaultCatalog();
      final cafe = catalog.get('cafeteria')!;
      expect(cafe.description, isNotEmpty);
      // Sin asset todavía: TODO: ASSET REQUIRED.
      expect(cafe.hasBackground, isFalse);
    });
  });
}