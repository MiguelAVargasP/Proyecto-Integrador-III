import 'package:flutter/material.dart';
import 'features/mapa_navegacion/screens/mapa_campus_screen.dart';
import 'registro_inicial.dart';

void main() {
  registrarContenidoDeEscenas();
  runApp(const OrientacionUpbApp());
}

class OrientacionUpbApp extends StatelessWidget {
  const OrientacionUpbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orientación UPB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MapaCampusScreen(),
    );
  }
}
