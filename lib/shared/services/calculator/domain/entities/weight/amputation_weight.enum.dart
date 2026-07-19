enum AmputationWeight {
  hand(percentage: 0.7),
  forearm(percentage: 2.3),
  arm(percentage: 6.5),
  foot(percentage: 1.5),
  leg(percentage: 5.9),
  thigh(percentage: 11.6);

  final double percentage;

  const AmputationWeight({required this.percentage});
}


// Peso Estimado= Peso Anterior / 1−% do segmento
// reduzir esse valor do peso ideal 
// Valores de referência para segmento: 
// Mão (0.7%),
// Antebraço (2.3%),
// Braço inteiro (6.5%),
// Pé (1.5%),
// Perna (5.9%),
// Coxa (11.6%).