/// Un estado de una [StateMachine], vinculado a la entidad dueña de la
/// máquina. Porte directo de `engine/combat/state_machine.py`.
abstract class State {
  Object? owner;

  /// Vincula este estado a su dueño (usualmente la entidad de la
  /// máquina de estados).
  void attach(Object? newOwner) {
    owner = newOwner;
  }

  /// Nombre único de este estado.
  String name();

  /// Se llama cuando el estado se vuelve activo.
  void enter(String? previous) {}

  /// Se llama en cada frame mientras el estado está activo.
  void update(double delta) {}

  /// Se llama cuando el estado deja de estar activo.
  void exit(String? nextName) {}

  /// Hook de guardia: devuelve false para prohibir una transición.
  bool canEnter(String nextName) => true;
}

/// Mantiene los estados registrados y conduce las transiciones
/// enter/update/exit. Porte directo de `engine/combat/state_machine.py`.
class StateMachine {
  final Object owner;
  final Map<String, State> states = {};
  State? current;
  String? _currentName;

  StateMachine(this.owner);

  /// Registra un estado bajo su nombre y lo devuelve.
  State register(State state) {
    state.attach(owner);
    states[state.name()] = state;
    return state;
  }

  /// Empieza a correr desde un estado específico (sin hooks de salida).
  void start(String name) {
    current = null;
    _currentName = null;
    change(name);
  }

  /// Transiciona a otro estado, ejecutando los hooks exit/enter.
  void change(String name) {
    final nextState = states[name];
    if (nextState == null) {
      throw ArgumentError('estado desconocido: $name');
    }
    if (current != null && !current!.canEnter(name)) {
      return;
    }
    final previous = _currentName;
    current?.exit(name);
    nextState.enter(previous);
    current = nextState;
    _currentName = name;
  }

  /// Impulsa el update del estado activo.
  void update(double delta) {
    current?.update(delta);
  }

  /// Nombre del estado actualmente activo (null antes de start()).
  String? getName() => _currentName;

  /// true cuando el estado dado es el activo.
  bool isCurrent(String name) => _currentName == name;
}
