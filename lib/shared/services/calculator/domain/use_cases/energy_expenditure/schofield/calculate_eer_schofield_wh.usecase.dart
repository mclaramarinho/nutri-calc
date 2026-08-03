// For children < 10yo
// https://espen.org/documents/A174-02PaedPNGuidel_ESPGHANESPENPNGuidelines2Energy.pdf

import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

class CalculateEerSchofield {
  Result<EER, String> call({
    required double weight,
    required double height,
    required int age,
    required Gender gender,
    required ActivityFactor activityFactor,
    TemperatureFactor? temperatureFactor,
    InjuryFactor? injuryFactor,
  }) {
    try {
      if (age < 0 || height < 0 || weight < 0) {
        return Error("INVALID_PARAMS");
      }

      // TODO - add formulas para ate 18 anos depois
      if (age > 10) {
        return Error("INVALID_AGE");
      }
      final formula = gender == .female
          ? _getFormulaFemale(age)
          : _getFormulaMale(age);

      return Ok(
        EER(
          eer: formula(weight, height),
          activityFactor: activityFactor,
          injuryFactor: injuryFactor,
          temperatureFactor: temperatureFactor,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }

  double Function(double w, double h) _getFormulaMale(int age) {
    if (age < 3) {
      return (w, h) => 0.167 * w + 1517.4 * h - 617.6;
    }

    return (w, h) => 19.6 * w + 130.3 * h + 414.9;
  }

  double Function(double w, double h) _getFormulaFemale(int age) {
    if (age < 3) {
      return (w, h) => 16.25 * w + 1023.2 * h - 413.5;
    }

    return (w, h) => 16.97 * w + 161.8 * h + 371.2;
  }
}
