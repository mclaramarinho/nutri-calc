enum Nrs2002Step2Classification {
  absent(points: 0),
  low(points: 1),
  mild(points: 2),
  severe(points: 3);

  final int points;

  const Nrs2002Step2Classification({required this.points});
}
