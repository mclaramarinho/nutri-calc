// adaptado de James, 1989
// POP n. 01 - Hospital universitario Prof. Polydoro Ernani de Sao Thiago da Univ. Federal de Santa Catarina (2015)

enum AscitisLevel {
  low(value: 2.2),
  moderate(value: 6),
  severe(value: 14);

  final double value;

  const AscitisLevel({required this.value});
}
