import 'card.dart';

/// Evaluador de manos de poker de cinco cartas.
///
/// El pipeline descrito en el documento de diseño es:
///
///     Hand -> PokerEvaluator -> PokerCombination -> SuperAbility
///
/// Este archivo porta los primeros tres eslabones: dado los cinco slots
/// fijos de una Hand, produce una PokerCombination que identifica la
/// jugada de poker (rango numérico + nombre legible) y los kickers
/// usados para desempatar entre dos manos del mismo rango. Los efectos
/// concretos de SuperAbility llegan en la Etapa 6; este evaluador solo
/// necesita ser determinista y exacto para que el super manager pueda
/// decidir según la combinación resultante.
///
/// Porte directo de `game/cards/poker_evaluator.py`.
const int highCard = 1;
const int pair = 2;
const int twoPair = 3;
const int threeOfAKind = 4;
const int straight = 5;
const int flush = 6;
const int fullHouse = 7;
const int fourOfAKind = 8;
const int straightFlush = 9;
const int royalFlush = 10;

const Map<int, String> combinationNames = {
  highCard: 'Carta Alta',
  pair: 'Par',
  twoPair: 'Doble Par',
  threeOfAKind: 'Trío',
  straight: 'Escalera',
  flush: 'Color',
  fullHouse: 'Full House',
  fourOfAKind: 'Póker',
  straightFlush: 'Escalera de Color',
  royalFlush: 'Escalera Real',
};

/// Una mano de poker evaluada: rango, nombre legible y kickers de
/// desempate. Dos combinaciones se comparan por (rango, kickers): un
/// rango más alto siempre gana, y cuando el rango coincide los kickers
/// deciden el ganador siguiendo las reglas estándar de poker (ej. un par
/// de Ases le gana a un par de Reyes).
class PokerCombination implements Comparable<PokerCombination> {
  final int rank;
  final String name;
  final List<int> kickers;
  final List<Card> cards;

  PokerCombination(this.rank, List<int> kickers, Iterable<Card> cards)
      : name = combinationNames[rank]!,
        kickers = List.unmodifiable(kickers),
        cards = List.unmodifiable(cards);

  @override
  bool operator ==(Object other) {
    if (other is! PokerCombination) return false;
    if (rank != other.rank) return false;
    if (kickers.length != other.kickers.length) return false;
    for (int i = 0; i < kickers.length; i++) {
      if (kickers[i] != other.kickers[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(rank, Object.hashAll(kickers));

  @override
  int compareTo(PokerCombination other) {
    if (rank != other.rank) return rank.compareTo(other.rank);
    final len = kickers.length < other.kickers.length
        ? kickers.length
        : other.kickers.length;
    for (int i = 0; i < len; i++) {
      if (kickers[i] != other.kickers[i]) {
        return kickers[i].compareTo(other.kickers[i]);
      }
    }
    return kickers.length.compareTo(other.kickers.length);
  }

  bool operator <(PokerCombination other) => compareTo(other) < 0;
  bool operator >(PokerCombination other) => compareTo(other) > 0;
  bool operator <=(PokerCombination other) => compareTo(other) <= 0;
  bool operator >=(PokerCombination other) => compareTo(other) >= 0;

  @override
  String toString() =>
      'PokerCombination(name: $name, rank: $rank, kickers: $kickers)';
}

Map<int, List<Card>> _groupByRank(List<Card> cards) {
  final groups = <int, List<Card>>{};
  for (final card in cards) {
    groups.putIfAbsent(card.value, () => []).add(card);
  }
  return groups;
}

List<int> _sortedDesc(List<int> v) => (List<int>.from(v)..sort((a, b) => b.compareTo(a)));

/// Devuelve el valor alto de una escalera de 5 cartas, o null si no lo es.
/// Reconoce tanto una corrida normal de cinco valores distintos como la
/// "rueda" (A-2-3-4-5, tratada como la escalera más baja, con alto 5).
int? _straightHigh(List<int> values) {
  final distinct = values.toSet();
  if (distinct.length != 5) return null;
  final ordered = _sortedDesc(distinct.toList());
  if (ordered[0] - ordered[4] == 4) return ordered[0];
  if (ordered[0] == 14 &&
      ordered[1] == 5 &&
      ordered[2] == 4 &&
      ordered[3] == 3 &&
      ordered[4] == 2) {
    return 5; // rueda: la escalera más baja posible
  }
  return null;
}

bool _sizesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Convierte exactamente cinco cartas en una PokerCombination.
class PokerEvaluator {
  PokerCombination evaluate(Iterable<Card> cardsIn) {
    final hand = cardsIn.toList();
    if (hand.length != 5) {
      throw ArgumentError(
          'la evaluación de poker necesita exactamente 5 cartas, se dieron ${hand.length}');
    }

    final groups = _groupByRank(hand);
    // Mayor cantidad primero, luego mayor valor (orden determinista).
    final grouped = groups.entries.toList()
      ..sort((a, b) {
        final lenCompare = a.value.length.compareTo(b.value.length);
        if (lenCompare != 0) return -lenCompare;
        return -a.key.compareTo(b.key);
      });
    final sizes = grouped.map((e) => e.value.length).toList();
    final values = hand.map((c) => c.value).toList();

    final isFlush = hand.map((c) => c.suit).toSet().length == 1;
    final straightHigh = _straightHigh(values);

    if (_sizesEqual(sizes, [4, 1])) {
      final fourValue = grouped[0].key, kicker = grouped[1].key;
      return PokerCombination(fourOfAKind, [fourValue, kicker], hand);
    }
    if (_sizesEqual(sizes, [3, 2])) {
      final threeValue = grouped[0].key, pairValue = grouped[1].key;
      return PokerCombination(fullHouse, [threeValue, pairValue], hand);
    }
    if (isFlush && straightHigh != null) {
      if (straightHigh == 14) {
        return PokerCombination(royalFlush, [14], hand);
      }
      return PokerCombination(straightFlush, [straightHigh], hand);
    }
    if (isFlush) {
      return PokerCombination(flush, _sortedDesc(values), hand);
    }
    if (straightHigh != null) {
      return PokerCombination(straight, [straightHigh], hand);
    }
    if (_sizesEqual(sizes, [3, 1, 1])) {
      final threeValue = grouped[0].key;
      final kickers = _sortedDesc(grouped.sublist(1).map((e) => e.key).toList());
      return PokerCombination(threeOfAKind, [threeValue, ...kickers], hand);
    }
    if (_sizesEqual(sizes, [2, 2, 1])) {
      final highPair = grouped[0].key, lowPair = grouped[1].key;
      final kicker = grouped[2].key;
      return PokerCombination(twoPair, [highPair, lowPair, kicker], hand);
    }
    if (_sizesEqual(sizes, [2, 1, 1, 1])) {
      final pairValue = grouped[0].key;
      final kickers = _sortedDesc(grouped.sublist(1).map((e) => e.key).toList());
      return PokerCombination(pair, [pairValue, ...kickers], hand);
    }
    // Carta alta: los cinco valores en orden descendente deciden.
    return PokerCombination(highCard, _sortedDesc(values), hand);
  }
}
