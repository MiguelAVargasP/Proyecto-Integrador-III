import 'core/registro_contenido_escenas.dart';
import 'features/combate/juego/parcial_contenido.dart';
import 'features/dialogo/dialogo_contenido.dart';
import 'features/dialogo/modelo/dialogo_linea.dart';
import 'features/gestion_tiempo/gestion_tiempo_screen.dart';
import 'features/etapas/etapa_primeras_clases_contenido.dart';
import 'features/etapas/etapa_estudio_independiente_contenido.dart';

void registrarContenidoDeEscenas() {
  // US-06: Gestión del tiempo — primera etapa del ciclo estudiantil.
  registroContenidoEscenas['GESTION'] = GestionTiempoContenido();

  // US-05 FASE 2: Primeras clases y adaptacion al nuevo horario.
  registroContenidoEscenas['FASE_2'] = PrimerasClasesContenido();

  // US-05 FASE 3: Estudio independiente y preparacion para el parcial.
  registroContenidoEscenas['FASE_3'] = EstudioIndependienteContenido();

  // 'D' -> el parcial simulado (RF-05/RF-08), motor de combate portado
  // de Fighting Deck. Ya con contenido real, no es placeholder.
  registroContenidoEscenas['D'] = ParcialContenido();

  registroContenidoEscenas['A'] = DialogoContenido(_lineasPlaceholder('A'));
  registroContenidoEscenas['B'] = DialogoContenido(_lineasPlaceholder('B'));
  registroContenidoEscenas['C'] = DialogoContenido(_lineasPlaceholder('C'));
  registroContenidoEscenas['E'] = DialogoContenido(_lineasPlaceholder('E'));
  registroContenidoEscenas['F'] = DialogoContenido(_lineasPlaceholder('F'));
  registroContenidoEscenas['G'] = DialogoContenido(_lineasPlaceholder('G'));
  registroContenidoEscenas['H'] = DialogoContenido(_lineasPlaceholder('H'));
  registroContenidoEscenas['I'] = DialogoContenido(_lineasPlaceholder('I'));
  registroContenidoEscenas['J'] = DialogoContenido(_lineasPlaceholder('J'));
  registroContenidoEscenas['K'] = DialogoContenido(_lineasPlaceholder('K'));
  registroContenidoEscenas['L'] = DialogoContenido(_lineasPlaceholder('L'));
  registroContenidoEscenas['TEMPLO'] = DialogoContenido(_lineasPlaceholder('TEMPLO', esTemplo: true));
}

List<DialogoLinea> _lineasPlaceholder(String id, {bool esTemplo = false}) {
  final nombre = esTemplo ? 'el Templo' : 'el Bloque $id';
  final archivoImagen = esTemplo ? 'templo_fachada.png' : 'bloque_${id.toLowerCase()}_fachada.png';

  final lineas = <DialogoLinea>[
    DialogoLinea(
      '[Descripción real de $nombre — reemplazar.]',
      imagen: archivoImagen,
    ),
  ];

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

  return lineas;
}
