import 'card.dart';

const int slotCount = 5;

/// Cinco slots de carta fijos, indexados de 1 a 5. Porte directo de
/// `game/cards/hand.py`. Los slots mapean 1:1 a los slots de habilidad,
/// así que el round nunca roba cartas extra y un jugador siempre tiene
/// acceso, como máximo, a cinco habilidades normales.
class Hand {
  List<Card?> slots = List<Card?>.filled(slotCount, null);

  /// Llena los slots 1..5 con exactamente las cinco cartas dadas.
  void deal(List<Card> cards) {
    if (cards.length != slotCount) {
      throw ArgumentError(
          'una mano necesita exactamente $slotCount cartas, se dieron ${cards.length}');
    }
    slots = List<Card?>.from(cards);
  }

  /// Devuelve la carta en `slot` (base 1), o null si está vacío.
  Card? getCard(int slot) {
    if (slot < 1 || slot > slotCount) {
      throw ArgumentError('el slot debe estar entre 1 y $slotCount, se dio $slot');
    }
    return slots[slot - 1];
  }

  /// true cuando todos los slots tienen carta.
  bool isFull() => slots.every((c) => c != null);

  /// Cuántos slots están vacíos.
  int emptySlots() => slots.where((c) => c == null).length;

  /// Vacía todos los slots (se usa al empezar un round nuevo).
  void clear() => slots = List<Card?>.filled(slotCount, null);

  /// Las cartas presentes, en orden de slot.
  Iterable<Card> get cards => slots.whereType<Card>();

  int get length => cards.length;

  @override
  String toString() {
    final texto = slots.map((c) => c?.shortName ?? '-').join(', ');
    return 'Hand([$texto])';
  }
}
