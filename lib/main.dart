import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/menu_principal/menu_principal_screen.dart';
import 'features/mapa_navegacion/screens/mapa_campus_screen.dart';
import 'registro_inicial.dart';

void main() {
  registrarContenidoDeEscenas();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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