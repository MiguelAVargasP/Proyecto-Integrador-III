/// Contenido data-driven de actividades de tiempo (provisional).
///
/// Define las actividades académicas y no académicas entre las que el jugador
/// distribuye su tiempo (US-06). Los valores de costo y efectos son balanceo
/// inicial provisional: se ajustarán al validar el diseño de juego y el
/// contenido oficial de la UPB.
///
/// Convención de estadísticas:
/// - `stress`: nivel de estrés (0-100; a mayor valor, peor).
/// - `preparation`: preparación para las evaluaciones (0-100; mayor mejor).
/// - `performance`: desempeño académico (0-100; mayor mejor).
library;

const List<Map<String, dynamic>> kTimeActionsData = <Map<String, dynamic>>[
  // ------------------------------------------------------------ académicas
  <String, dynamic>{
    'id': 'clase',
    'displayName': 'Asistir a clase',
    'category': 'academic',
    'cost': 2.0,
    'effects': <Map<String, dynamic>>[
      <String, dynamic>{'stat': 'preparation', 'delta': 6.0},
      <String, dynamic>{'stat': 'performance', 'delta': 4.0},
      <String, dynamic>{'stat': 'stress', 'delta': 2.0},
    ],
  },
  <String, dynamic>{
    'id': 'estudio',
    'displayName': 'Estudiar solo',
    'category': 'academic',
    'cost': 2.0,
    'effects': <Map<String, dynamic>>[
      <String, dynamic>{'stat': 'preparation', 'delta': 10.0},
      <String, dynamic>{'stat': 'stress', 'delta': 3.0},
    ],
  },
  <String, dynamic>{
    'id': 'tutoria',
    'displayName': 'Ir a tutoría',
    'category': 'academic',
    'cost': 1.0,
    'effects': <Map<String, dynamic>>[
      <String, dynamic>{'stat': 'preparation', 'delta': 7.0},
      <String, dynamic>{'stat': 'performance', 'delta': 2.0},
      <String, dynamic>{'stat': 'stress', 'delta': -2.0},
    ],
  },
  // ----------------------------------------------------------- no académicas
  <String, dynamic>{
    'id': 'descanso',
    'displayName': 'Descansar',
    'category': 'nonAcademic',
    'cost': 1.0,
    'effects': <Map<String, dynamic>>[
      <String, dynamic>{'stat': 'stress', 'delta': -8.0},
    ],
  },
  <String, dynamic>{
    'id': 'social',
    'displayName': 'Compartir con amigos',
    'category': 'nonAcademic',
    'cost': 1.0,
    'effects': <Map<String, dynamic>>[
      <String, dynamic>{'stat': 'stress', 'delta': -4.0},
    ],
  },
  <String, dynamic>{
    'id': 'deporte',
    'displayName': 'Hacer ejercicio',
    'category': 'nonAcademic',
    'cost': 1.0,
    'effects': <Map<String, dynamic>>[
      <String, dynamic>{'stat': 'stress', 'delta': -6.0},
      <String, dynamic>{'stat': 'preparation', 'delta': 1.0},
    ],
  },
];