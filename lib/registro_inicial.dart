import 'core/registro_contenido_escenas.dart';
import 'features/combate/juego/parcial_contenido.dart';
import 'features/dialogo/dialogo_contenido.dart';
import 'features/dialogo/modelo/dialogo_linea.dart';

/// Llama a esta función una sola vez, al arrancar la app (ver
/// `main.dart`), para llenar `registroContenidoEscenas` con la
/// jugabilidad real de cada historia ya implementada.
///
/// Este es el ÚNICO lugar del proyecto donde se debería "conectar" una
/// escena con su contenido — así, para saber qué historias de jugabilidad
/// ya están integradas, basta con leer este archivo.
///
/// IMPORTANTE: el texto y las imágenes previstas de las 12 escenas de
/// diálogo de abajo son PLACEHOLDER — genéricos, sin datos reales de la
/// UPB. Ya está lista la estructura completa por edificio (descripción +
/// una pregunta con dos opciones que ramifican el diálogo, más el nombre
/// de archivo de imagen previsto), así que cuando tengas el contenido
/// real solo hace falta reemplazar los textos y agregar los assets — no
/// hay que tocar la estructura ni el código de ningún otro archivo.
void registrarContenidoDeEscenas() {
  // 'D' -> el parcial simulado (RF-05/RF-08), motor de combate portado
  // de Fighting Deck. Ya con contenido real, no es placeholder.
  registroContenidoEscenas['D'] = ParcialContenido();

  registroContenidoEscenas['A'] = _escenaPlaceholder('A');
  registroContenidoEscenas['B'] = _escenaPlaceholder('B');
  registroContenidoEscenas['C'] = _escenaPlaceholder('C');
  registroContenidoEscenas['E'] = _escenaPlaceholder('E');
  registroContenidoEscenas['F'] = _escenaPlaceholder('F');
  registroContenidoEscenas['G'] = _escenaPlaceholder('G');
  registroContenidoEscenas['H'] = _escenaPlaceholder('H');
  registroContenidoEscenas['I'] = _escenaPlaceholder('I');
  registroContenidoEscenas['J'] = _escenaPlaceholder('J');
  registroContenidoEscenas['K'] = _escenaPlaceholder('K');
  registroContenidoEscenas['L'] = _escenaPlaceholder('L');
  registroContenidoEscenas['TEMPLO'] = _escenaPlaceholder('TEMPLO', esTemplo: true);
}

/// Genera la estructura de diálogo estándar para un edificio: una línea
/// descriptiva (con su espacio de imagen previsto) seguida de 3 temas de
/// conversación independientes, cada uno con su propia pregunta, dos
/// opciones y dos respuestas — el jugador pasa por 3 elecciones
/// distintas antes de que la escena termine. Todo el texto es
/// placeholder — reemplázalo por edificio cuando tengas el contenido
/// real; la forma (1 intro + 3 temas de pregunta/opciones/respuesta)
/// puede quedarse igual o ajustarse libremente por escena.
DialogoContenido _escenaPlaceholder(String id, {bool esTemplo = false}) {
  final nombre = esTemplo ? 'el Templo' : 'el Bloque $id';
  final archivoImagen = esTemplo ? 'templo_fachada.png' : 'bloque_${id.toLowerCase()}_fachada.png';

  final lineas = <DialogoLinea>[
    DialogoLinea(
      '[Descripción real de $nombre — reemplazar.]',
      imagen: archivoImagen,
    ),
  ];

  // 3 temas encadenados: los índices se calculan según cuántas líneas ya
  // lleva la lista en cada vuelta, para que los saltos (`saltarA` de las
  // opciones y `siguienteLinea` de las respuestas) siempre apunten al
  // lugar correcto sin tener que contarlos a mano.
  for (int tema = 1; tema <= 3; tema++) {
    final indicePregunta = lineas.length;
    final indiceResp1 = indicePregunta + 1;
    final indiceResp2 = indicePregunta + 2;
    final esUltimoTema = tema == 3;
    final indiceSiguienteTema = indiceResp2 + 1;

    lineas.add(DialogoLinea(
      '[Tema $tema en $nombre — pregunta real para el jugador — reemplazar.]',
      imagen: archivoImagen,
      opciones: [
        OpcionDialogo(
          '[Tema $tema, Opción 1 — reemplazar]',
          saltarA: indiceResp1,
          deltaEstres: -2,
          decisionRegistrada: '[En $nombre (tema $tema), eligió la Opción 1 — reemplazar.]',
        ),
        OpcionDialogo(
          '[Tema $tema, Opción 2 — reemplazar]',
          saltarA: indiceResp2,
          deltaEstres: 2,
          decisionRegistrada: '[En $nombre (tema $tema), eligió la Opción 2 — reemplazar.]',
        ),
      ],
    ));

    lineas.add(DialogoLinea(
      '[Tema $tema — respuesta a la Opción 1 — reemplazar.]',
      imagen: archivoImagen,
      esFinal: esUltimoTema,
      siguienteLinea: esUltimoTema ? null : indiceSiguienteTema,
    ));

    lineas.add(DialogoLinea(
      '[Tema $tema — respuesta a la Opción 2 — reemplazar.]',
      imagen: archivoImagen,
      esFinal: esUltimoTema,
      siguienteLinea: esUltimoTema ? null : indiceSiguienteTema,
    ));
  }

  return DialogoContenido(lineas);
}