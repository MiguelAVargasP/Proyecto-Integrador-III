import 'contenido_escena.dart';

/// Registro central: asocia el id de una escena (la letra del mapa, p. ej.
/// `'D'`) con su contenido jugable.
///
/// Se llena en la inicialización de la app (ver `registro_inicial.dart`) a
/// medida que se van implementando historias:
///
/// ```dart
/// registroContenidoEscenas['D'] = EstudioIndependienteContenido();
/// ```
///
/// Si una escena no tiene entrada aquí, `EscenaScreen` muestra un
/// placeholder — así el mapa completo siempre es navegable aunque todavía
/// falte contenido jugable para algunas escenas (coherente con RF-02: el
/// conjunto de escenas activas puede crecer historia a historia).
final Map<String, ContenidoEscena> registroContenidoEscenas = {};
