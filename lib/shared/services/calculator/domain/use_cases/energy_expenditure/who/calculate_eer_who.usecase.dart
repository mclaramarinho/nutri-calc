import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

// https://espen.org/documents/A174-02PaedPNGuidel_ESPGHANESPENPNGuidelines2Energy.pdf

class CalculateEerWho {
  Result<EER, String> call({
    required double weight,
    required int age,
    required Gender gender,
    required ActivityFactor activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
  }) {
    try {
      if (age < 0 || weight < 0) {
        return Error("INVALID_PARAMS");
      }

      if (age > 18) {
        return Error("INVALID_AGE");
      }

      double eer;

      switch (gender) {
        case .female:
          eer = _getFemale(weight, age);
          break;
        case .male:
          eer = _getMale(weight, age);
          break;
      }

      return Ok(
        EER(
          eer: eer,
          activityFactor: activityFactor,
          temperatureFactor: temperatureFactor,
          injuryFactor: injuryFactor,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }

  double _getFemale(double weight, int age) {
    if (age < 3) {
      return 61 * weight - 51;
    }

    if (age < 10) {
      return 22.4 * weight + 499;
    }

    return 17.5 * weight + 651;
  }

  double _getMale(double weight, int age) {
    if (age < 3) {
      return 60.9 * weight - 54;
    }

    if (age < 10) {
      return 22.7 * weight + 495;
    }

    return 12.2 * weight + 746;
  }
}
