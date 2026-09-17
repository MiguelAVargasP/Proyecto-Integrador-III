import '../motor/state_machine.dart';

/// Nombres de estado del fighter. Porte directo de
/// `game/fighters/fighter_state.py`. La arquitectura es extensible: etapas
/// futuras pueden agregar DASH, AIR_ATTACK, COMBO, SPECIAL y THROW
/// simplemente registrando nuevos estados.
const String idle = 'IDLE';
const String walk = 'WALK';
const String crouch = 'CROUCH';
const String jump = 'JUMP';
const String fall = 'FALL';
const String attackHigh = 'ATTACK_HIGH';
const String attackLow = 'ATTACK_LOW';
const String block = 'BLOCK';
const String hit = 'HIT';
const String ko = 'KO';

const List<String> groundStates = [idle, walk, crouch, block];
const List<String> airStates = [jump, fall];
const List<String> lockedStates = [attackHigh, attackLow, hit, ko];

/// Estado con nombre, vinculado al fighter dueño de su máquina de estados.
/// Porte directo de `FighterState` en Python. El comportamiento específico
/// del fighter vive en `Fighter.stateUpdate`, así que agregar un estado
/// nuevo es sobre todo cuestión de registrar el nombre y manejarlo ahí.
class FighterState extends State {
  final String _name;
  FighterState(this._name);

  @override
  String name() => _name;

  @override
  void update(double delta) {
    (owner as dynamic).stateUpdate(delta);
  }
}

/// Instancia el conjunto estándar de estados del fighter.
List<FighterState> buildStandardStates() => [
      FighterState(idle),
      FighterState(walk),
      FighterState(crouch),
      FighterState(jump),
      FighterState(fall),
      FighterState(attackHigh),
      FighterState(attackLow),
      FighterState(block),
      FighterState(hit),
      FighterState(ko),
    ];
