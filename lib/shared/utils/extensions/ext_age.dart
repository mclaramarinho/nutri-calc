import 'package:nutri_calc/shared/utils/entities/age_entity.dart';

extension AgeExtension on DateTime {
  AgeEntity getAge() {
    final ageDays = DateTime.now().difference(this).inDays;

    final ageMonths = (ageDays / 30.5).floor();

    if (ageDays < 30) {
      return AgeEntity(value: ageDays, unit: .day);
    } else if (ageMonths < 12) {
      return AgeEntity(value: ageMonths, unit: .month);
    } else {
      return AgeEntity(value: (ageMonths / 12).floor(), unit: .year);
    }
  }
}