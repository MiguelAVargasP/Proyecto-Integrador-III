/// Pruebas del catálogo de actividades de tiempo (data-driven).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:juegoupb/engine/managers/time_manager.dart';
import 'package:juegoupb/game/data/time_action_catalog.dart';
import 'package:juegoupb/game/data/time_actions_data.dart';

void main() {
  group('TimeActionCatalog', () {
    test('el catálogo por defecto cubre los datos definidos', () {
      final catalog = TimeActionCatalog.defaultCatalog();
      expect(catalog.length, kTimeActionsData.length);
      expect(catalog.length, greaterThan(3));
    });

    test('contiene actividades académicas y no académicas', () {
      final catalog = TimeActionCatalog.defaultCatalog();
      final academic = catalog.actions
          .where((a) => a.category == TimeCategory.academic)
          .toList();
      final nonAcademic = catalog.actions
          .where((a) => a.category == TimeCategory.nonAcademic)
          .toList();
      expect(academic, isNotEmpty);
      expect(nonAcademic, isNotEmpty);
    });

    test('todas las actividades tienen costo positivo y efectos', () {
      final catalog = TimeActionCatalog.defaultCatalog();
      for (final action in catalog.actions) {
        expect(action.cost, greaterThan(0));
        expect(action.effects, isNotEmpty,
            reason: 'cada actividad debería tener efectos');
      }
    });
  });
}