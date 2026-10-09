import 'dart:math';
import 'card.dart';

/// Construye las 52 cartas únicas de una baraja francesa.
List<Card> buildStandardDeck() => [
      for (final suit in suits)
        for (final rank in ranks) Card(suit, rank)
    ];

/// Un mazo de cartas que se puede barajar y del que se puede robar. Porte
/// directo de `game/cards/deck.py`.
class Deck {
  List<Card> _cards;
  final Random _rng;

  Deck({Random? rng})
      : _cards = buildStandardDeck(),
        _rng = rng ?? Random();

  /// Reordena aleatoriamente las cartas restantes (Fisher-Yates).
  void shuffle() {
    for (int i = _cards.length - 1; i > 0; i--) {
      final j = _rng.nextInt(i + 1);
      final tmp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = tmp;
    }
  }

  /// Quita y devuelve la carta de arriba (null si el mazo está vacío).
  Card? draw() {
    if (_cards.isEmpty) return null;
    return _cards.removeLast();
  }

  bool isEmpty() => _cards.isEmpty;

  /// Cuántas cartas quedan en el mazo.
  int remaining() => _cards.length;

  /// Reconstruye un mazo completo y ordenado.
  void reset() => _cards = buildStandardDeck();
}
