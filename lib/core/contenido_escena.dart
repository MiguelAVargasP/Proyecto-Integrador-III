import 'package:flutter/widgets.dart';

/// Contrato que debe implementar el contenido jugable de cada escena.
///
/// Cada historia de usuario que agregue jugabilidad a una escena concreta
/// (US-05 etapas del ciclo estudiantil, US-06 gestión del tiempo, US-08
/// consecuencias, etc.) crea su propio módulo en `features/` con una clase
/// que implemente esta interfaz, y la registra en
/// `registroContenidoEscenas` (ver `registro_contenido_escenas.dart`).
///
/// `EscenaScreen` no conoce el contenido real de ninguna escena: solo le
/// pregunta al registro "¿hay contenido para esta escena?" y, si lo hay,
/// delega la construcción del widget aquí. Esto permite implementar cada
/// historia de forma aislada, sin tocar el módulo de navegación.
abstract class ContenidoEscena {
  /// Construye el widget de la escena.
  ///
  /// [onCompletada] debe llamarse cuando el jugador termina la interacción
  /// de esa escena (por ejemplo, al confirmar cómo distribuyó su tiempo, o
  /// al presentar el parcial simulado). Quien implemente esta interfaz
  /// decide qué hacer antes de llamarlo (actualizar `estadoJuego`, guardar
  /// una decisión, calcular una consecuencia, etc.) — `onCompletada` es
  /// solo la señal de "esta escena terminó, se puede volver o avanzar".
  Widget construir(BuildContext context, VoidCallback onCompletada);
}
