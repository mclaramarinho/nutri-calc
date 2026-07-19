import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';

class EER {
  final double eer;
  final ActivityFactor activityFactor;
  final TemperatureFactor? temperatureFactor;
  final InjuryFactor? injuryFactor;

  const EER({
    required this.eer,
    required this.activityFactor,
    this.injuryFactor,
    this.temperatureFactor,
  });

  double get minEer =>
      eer *
      activityFactor.val *
      (injuryFactor?.min ?? 1) *
      (temperatureFactor?.val ?? 1);

  double get maxEer =>
      eer *
      activityFactor.val *
      (injuryFactor?.max ?? 1) *
      (temperatureFactor?.val ?? 1);
}
