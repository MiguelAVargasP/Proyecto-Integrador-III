import 'package:flutter/foundation.dart';

/// Estado del progreso de navegación por el mapa: qué escena es la actual
/// (RF-03) y cuáles ya fueron visitadas (RF-04, historia US-04 — se deja el
/// registro aquí ya armado para que esa historia solo tenga que persistirlo,
/// no crear el modelo desde cero).
///
/// NOTA DE ARQUITECTURA: esta clase usa [ChangeNotifier] "a mano", sin
/// paquete externo, para no comprometer una decisión de gestión de estado
/// (Provider/Riverpod/Bloc) antes de que se apruebe en Plan Mode. Es
/// trivial de envolver con `ChangeNotifierProvider` si se adopta Provider,
/// o de migrar a un `Notifier` de Riverpod más adelante — no depende de
/// ningún widget de este archivo.
class EstadoMapa extends ChangeNotifier {
  String? _escenaActualId;
  final Set<String> _escenasVisitadas = {};

  String? get escenaActualId => _escenaActualId;
  Set<String> get escenasVisitadas => Set.unmodifiable(_escenasVisitadas);

  bool fueVisitada(String escenaId) => _escenasVisitadas.contains(escenaId);
  bool esEscenaActual(String escenaId) => _escenaActualId == escenaId;

  /// Se llama al navegar hacia una escena (RF-03) y marca la escena como
  /// visitada (insumo directo para US-04).
  void seleccionarEscena(String escenaId) {
    _escenaActualId = escenaId;
    _escenasVisitadas.add(escenaId);
    notifyListeners();
  }
}

/// Instancia única compartida mientras no se decida un enfoque de
/// inyección de dependencias formal. Sustituir por `Provider.of` /
/// `ref.watch` según lo que se apruebe en el paso de arquitectura.
final EstadoMapa estadoMapa = EstadoMapa();
