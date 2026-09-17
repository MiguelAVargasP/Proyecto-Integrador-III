/// Controla si se dibujan las zonas de colisión (hitbox/hurtbox) y el
/// nombre del estado actual sobre cada fighter. Está en `true` por
/// defecto porque, mientras no haya sprites reales, ver la mecánica
/// (dónde está la hurtbox, cuándo se arma el hitbox, en qué estado está
/// cada fighter) es más útil que la sola silueta de color.
///
/// Cuando el juego tenga arte definitivo, cambia esto a `false` antes de
/// una entrega — es un interruptor, no hace falta borrar código.
bool debugCombateVisible = true;