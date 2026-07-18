// Adaptado de Materese, 1997
// POP n. 01 - Hospital universitario Prof. Polydoro Ernani de Sao Thiago da Univ. Federal de Santa Catarina (2015)

enum OedemaLevel {
  low(min: 1, max: 1), // +
  moderate(min: 3, max: 4), // ++
  severe(min: 5, max: 6), // +++
  generalized(min: 10, max: 12), // ++++

  ascitisLow(min: 2, max: 2),
  ascitisModerate(min: 4, max: 6),
  ascitisSevere(min: 10, max: 14);

  final int min;
  final int max;

  const OedemaLevel({required this.min, required this.max});
}
