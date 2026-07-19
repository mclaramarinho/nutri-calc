enum AmputationWeight {
  hand(percentage: 0.7),
  forearm(percentage: 2.3),
  arm(percentage: 4),
  foot(percentage: 1.5),
  belowTheKnee(percentage: 3.5),
  aboveTheKnee(percentage: 11),
  hipDisarticulation(percentage: 16),
  abdomenAndThorax(percentage: 50);

  final double percentage;

  const AmputationWeight({required this.percentage});

  double adjustWeightByAmputation(double weight) {
    return weight - ((weight * percentage) / 100);
  }
}

// https://clincalc.com/kinetics/ebwl.aspx
// http://www.hu.ufsc.br/documentos/pop/DND/POP_e_Manual_Avaliacao_Nutricional_Antropometria.pdf
