/// Fighting Deck usa la baraja francesa estándar de 52 cartas. Cada carta
/// representa una habilidad universal, compartida por todos los
/// personajes, así que la carta solo necesita un palo y un valor. Nunca
/// depende del motor. Porte directo de `game/cards/card.py`.
const List<String> suits = ['hearts', 'diamonds', 'clubs', 'spades'];
const List<String> ranks = [
  'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
];

const Map<String, String> suitSymbols = {
  'hearts': 'H',
  'diamonds': 'D',
  'clubs': 'C',
  'spades': 'S',
};

/// A es alto (14) para la mayoría de las combinaciones; la escalera
/// "rueda" A-2-3-4-5 se maneja dentro del evaluador de poker.
const Map<String, int> rankValues = {
  'A': 14, 'K': 13, 'Q': 12, 'J': 11, '10': 10,
  '9': 9, '8': 8, '7': 7, '6': 6, '5': 5, '4': 4, '3': 3, '2': 2,
};

/// Una sola carta definida por un palo y un valor.
class Card {
  final String suit;
  final String rank;

  Card(this.suit, this.rank) {
    if (!suits.contains(suit)) {
      throw ArgumentError('palo desconocido: $suit');
    }
    if (!ranks.contains(rank)) {
      throw ArgumentError('valor desconocido: $rank');
    }
  }

  /// Valor numérico usado para comparaciones (A es 14).
  int get value => rankValues[rank]!;

  /// Nombre corto legible, como 'AH' o '10D'.
  String get shortName => '$rank${suitSymbols[suit]}';

  @override
  bool operator ==(Object other) =>
      other is Card && suit == other.suit && rank == other.rank;

  @override
  int get hashCode => Object.hash(suit, rank);

  @override
  String toString() => 'Card($shortName)';
}
