import 'core/registro_contenido_escenas.dart';
import 'features/_ejemplo_contenido/ejemplo_contenido_escena.dart';

/// Llama a esta función una sola vez, al arrancar la app (ver
/// `main_ejemplo.dart`), para llenar `registroContenidoEscenas` con la
/// jugabilidad real de cada historia ya implementada.
///
/// Este es el ÚNICO lugar del proyecto donde se debería "conectar" una
/// escena con su contenido — así, para saber qué historias de jugabilidad
/// ya están integradas, basta con leer este archivo.
void registrarContenidoDeEscenas() {
  // Ejemplo ilustrativo — reemplaza esta línea por tus historias reales,
  // p. ej.:
  // registroContenidoEscenas['D'] = GestionTiempoContenido(); // US-06
  registroContenidoEscenas['D'] = EjemploContenidoEscena();
}
