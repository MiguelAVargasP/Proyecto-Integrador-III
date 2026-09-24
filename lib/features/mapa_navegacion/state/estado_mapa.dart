import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _claveMapa = 'partida_mapa';

  String? _escenaActualId;
  final Set<String> _escenasVisitadas = {};
  final Set<String> _etapasCompletadas = {};

  String? get escenaActualId => _escenaActualId;
  Set<String> get escenasVisitadas => Set.unmodifiable(_escenasVisitadas);
  Set<String> get etapasCompletadas => Set.unmodifiable(_etapasCompletadas);

  bool fueVisitada(String escenaId) => _escenasVisitadas.contains(escenaId);
  bool esEscenaActual(String escenaId) => _escenaActualId == escenaId;
  bool etapaCompletada(String escenaId) => _etapasCompletadas.contains(escenaId);

  void seleccionarEscena(String escenaId) {
    _escenaActualId = escenaId;
    _escenasVisitadas.add(escenaId);
    notifyListeners();
  }

  /// Marca una etapa del ciclo estudiantil (FASE_2, FASE_3) como completada.
  /// Se llama desde la escena jugable al finalizarla con éxito.
  void completarEtapa(String escenaId) {
    _etapasCompletadas.add(escenaId);
    notifyListeners();
  }

  // --- US-20: persistencia del mapa ---

  Map<String, dynamic> toJson() => {
        'escenaActualId': _escenaActualId,
        'escenasVisitadas': _escenasVisitadas.toList(),
        'etapasCompletadas': _etapasCompletadas.toList(),
      };

  void fromJson(Map<String, dynamic> json) {
    _escenaActualId = json['escenaActualId'] as String?;
    final visJson = json['escenasVisitadas'] as List<dynamic>?;
    if (visJson != null) {
      _escenasVisitadas.clear();
      _escenasVisitadas.addAll(visJson.cast<String>());
    }
    final etaJson = json['etapasCompletadas'] as List<dynamic>?;
    if (etaJson != null) {
      _etapasCompletadas.clear();
      _etapasCompletadas.addAll(etaJson.cast<String>());
    }
    notifyListeners();
  }

  Future<bool> guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(toJson());
      return await prefs.setString(_claveMapa, json);
    } catch (_) {
      return false;
    }
  }

  Future<bool> cargar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_claveMapa);
      if (jsonStr == null) return false;
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      fromJson(json);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> borrarGuardado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_claveMapa);
    } catch (_) {
      return false;
    }
  }
}

/// Instancia única compartida mientras no se decida un enfoque de
/// inyección de dependencias formal. Sustituir por `Provider.of` /
/// `ref.watch` según lo que se apruebe en el paso de arquitectura.
final EstadoMapa estadoMapa = EstadoMapa();
