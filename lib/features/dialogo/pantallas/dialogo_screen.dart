import 'package:flutter/material.dart';
import '../modelo/dialogo_linea.dart';
import '../widgets/caja_dialogo.dart';

/// Pantalla de diálogo a pantalla completa — a propósito, sin `AppBar`.
/// La franja blanca del `AppBar` de `EscenaScreen` le restaba espacio a
/// la ilustración de la escena; aquí el diálogo ocupa el 100% de la
/// pantalla, con solo una X pequeña arriba a la izquierda para volver
/// (mismo patrón que ya usa el combate del parcial).
class DialogoScreen extends StatelessWidget {
  final List<DialogoLinea> lineas;

  const DialogoScreen({super.key, required this.lineas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CajaDialogo(
              lineas: lineas,
              onFinalizado: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}