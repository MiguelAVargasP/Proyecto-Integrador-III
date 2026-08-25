/// Contenido data-driven de escenas (provisional).
///
/// Fuente de verdad de las escenas del mapa. Los textos son provisionales
/// hasta recibir el contenido oficial de la UPB (regla §36: no inventar
/// información institucional). Los fondos se marcan como `TODO: ASSET REQUIRED`
/// y no referencian archivos inexistentes (regla §35).
library;

const List<Map<String, dynamic>> kScenesData = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 'map',
    'displayName': 'Mapa del Campus',
    'description': 'Elige un espacio del campus para comenzar.',
  },
  <String, dynamic>{
    'id': 'cafeteria',
    'displayName': 'Cafetería',
    'description': 'Un espacio para pausar y compartir.',
    // TODO: ASSET REQUIRED (fondo estático de la cafetería)
  },
  <String, dynamic>{
    'id': 'biblioteca',
    'displayName': 'Biblioteca',
    'description': 'Un espacio para estudiar y consultar.',
    // TODO: ASSET REQUIRED (fondo estático de la biblioteca)
  },
  <String, dynamic>{
    'id': 'aulas',
    'displayName': 'Aulas',
    'description': 'El lugar de las primeras clases.',
    // TODO: ASSET REQUIRED (fondo estático de las aulas)
  },
];