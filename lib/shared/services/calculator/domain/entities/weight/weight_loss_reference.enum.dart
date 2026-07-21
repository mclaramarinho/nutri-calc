enum WeightLossReference {
  none(severe: double.infinity, significative: double.infinity, timeInDays: 0),
  sevenDays(severe: 2, significative: 1, timeInDays: 7),
  oneMonth(severe: 5, significative: 5, timeInDays: 30),
  threeMonths(severe: 7.5, significative: 7.5, timeInDays: 90),
  sixMonths(severe: 10, significative: 10, timeInDays: 180);

  final double severe;
  final double significative;
  final int timeInDays;

  const WeightLossReference({
    required this.severe,
    required this.significative,
    required this.timeInDays,
  });

  static List<int> get allTimesInDays =>
      values.map((v) => v.timeInDays).where((v) => v != 0).toList();
  static WeightLossReference getByTimeInDays(int time) {
    switch (time) {
      case 7:
        return .sevenDays;
      case 30:
        return .oneMonth;
      case 90:
        return .threeMonths;
      case 180:
        return .sixMonths;
      default:
        return .none;
    }
  }
}
