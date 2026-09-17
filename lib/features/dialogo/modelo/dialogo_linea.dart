/// Una opción que el jugador puede elegir en una línea de diálogo.
///
/// `saltarA` es el índice (dentro de la misma lista de líneas) al que
/// salta el diálogo si se elige esta opción — déjalo en null para que la
/// opción simplemente continúe a la siguiente línea, como si fuera texto
/// normal. Esto permite ramificar la conversación sin necesitar una
/// estructura de datos más compleja que una lista plana de líneas.
///
/// Los tres campos siguientes conectan la elección con `EstadoJuego`
/// (ver `core/estado_juego.dart`) — todos opcionales, y se aplican en el
/// momento en que el jugador toca la opción, antes de navegar a la
/// siguiente línea:
/// - `deltaEstres`: cuánto sube o baja `nivelEstres` (negativo = calma,
///   positivo = más estrés).
/// - `decisionRegistrada`: texto que queda en `decisionesTomadas`, para
///   que la decisión sea trazable después (RF-16).
/// - `insignia`: id que se agrega a `insigniasObtenidas` (RF-10), si esa
///   elección debe otorgar un hito.
class OpcionDialogo {
  final String texto;
  final int? saltarA;
  final int? deltaEstres;
  final String? decisionRegistrada;
  final String? insignia;

  const OpcionDialogo(
    this.texto, {
    this.saltarA,
    this.deltaEstres,
    this.decisionRegistrada,
    this.insignia,
  });
}

/// Una sola línea de diálogo dentro de una escena de conversación.
///
/// `hablante` es opcional: déjalo vacío para texto narrativo/descriptivo
/// (sin nombre encima, como la voz del narrador describiendo el lugar) o
/// ponle un nombre para que se vea como si un personaje estuviera
/// hablando (ej. "Estudiante de bienestar universitario").
///
/// `imagen` reserva el espacio visual para una ilustración de fondo — el
/// nombre de archivo dentro de `assets/images/escenarios/` (ver
/// `CajaDialogo`, que ya lo carga como `Image.asset` real).
///
/// `retrato` es opcional: el nombre de archivo dentro de
/// `assets/images/personajes/` para el retrato de quien habla, mostrado
/// junto al nombre del hablante. Déjalo en null para diálogo sin retrato
/// (texto narrativo, o mientras no haya un retrato listo para ese
/// personaje).
///
/// `opciones`, si no está vacío, reemplaza el "toca para continuar" por
/// botones — cada uno puede saltar a otra línea (`saltarA`) o
/// simplemente avanzar como una línea normal.
///
/// `esFinal` marca que, al tocar para continuar desde esta línea, el
/// diálogo termina ahí (llama a `onCompletada`) en vez de seguir a la
/// siguiente línea de la lista — necesario para que una respuesta a la
/// que se llegó por una opción no siga cayendo en la respuesta de la
/// otra opción, que viene justo después en la lista.
///
/// `siguienteLinea` resuelve el caso intermedio: cuando esta línea NO es
/// la última del diálogo, pero tampoco debe continuar simplemente a
/// `índice + 1` (por ejemplo, dos respuestas de un mismo tema que deben
/// converger en la pregunta del siguiente tema, no una después de la
/// otra). Si se define, tocar para continuar salta ahí en vez de sumar
/// uno al índice. `esFinal` tiene prioridad sobre esto si ambos están
/// definidos.
class DialogoLinea {
  final String hablante;
  final String texto;
  final String? imagen;
  final String? retrato;
  final List<OpcionDialogo> opciones;
  final bool esFinal;
  final int? siguienteLinea;

  const DialogoLinea(
    this.texto, {
    this.hablante = '',
    this.imagen,
    this.retrato,
    this.opciones = const [],
    this.esFinal = false,
    this.siguienteLinea,
  });
}