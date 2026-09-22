import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/repositories/energy_expenditure_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/eer_pocket.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/harris_bennedict/calculate_eer_harris_benedict.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/mifflin/calculate_eer_mifflin.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/pocket/calculate_eer_pocket.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/schofield/calculate_eer_schofield_wh.usecase.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/energy_expenditure/who/calculate_eer_who.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

abstract class SaveEnergyExpenditureCalculationUseCase {
  Future<Result<EnergyExpenditureCalculationEntity, String>> call({
    required String patientId,
    required EnergyExpenditureFormulaEnum formula,
    required double weightKg,
    double? heightCm,
    int? age,
    Gender? gender,
    ActivityFactor? activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
    StressLevel stressLevel = StressLevel.noStress,
  });
}

@Injectable(as: SaveEnergyExpenditureCalculationUseCase)
class SaveEnergyExpenditureCalculationUseCaseImpl
    implements SaveEnergyExpenditureCalculationUseCase {
  const SaveEnergyExpenditureCalculationUseCaseImpl({
    required this._repository,
  });

  final EnergyExpenditureRepository _repository;

  @override
  Future<Result<EnergyExpenditureCalculationEntity, String>> call({
    required String patientId,
    required EnergyExpenditureFormulaEnum formula,
    required double weightKg,
    double? heightCm,
    int? age,
    Gender? gender,
    ActivityFactor? activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
    StressLevel stressLevel = StressLevel.noStress,
  }) async {
    try {
      switch (formula) {
        case .harrisBenedict:
        case .mifflin:
        case .schofield:
          if (gender == null ||
              heightCm == null ||
              age == null ||
              activityFactor == null) {
            return Error("INVALID_PARAMS");
          }
          break;
        case .who:
          if (gender == null || age == null || activityFactor == null) {
            return Error("INVALID_PARAMS");
          }
          break;
        case .pocket:
          break;
      }

      double minValue;
      double maxValue;
      List<InputParamEntity> inputParams;

      switch (formula) {
        case .harrisBenedict:
          final res = CalculateEerHarrisBenedict().call(
            gender: gender!,
            weight: weightKg,
            height: heightCm!,
            age: age!,
            activityFactor: activityFactor!,
            injuryFactor: injuryFactor,
            temperatureFactor: temperatureFactor,
          );
          if (res.isError) return Error((res as Error<EER, String>).error);
          final eer = (res as Ok<EER, String>).value;
          minValue = eer.minEer;
          maxValue = eer.maxEer;
          inputParams = _buildAdultParams(
            weightKg: weightKg,
            heightCm: heightCm,
            age: age,
            gender: gender,
            activityFactor: activityFactor,
            injuryFactor: injuryFactor,
            temperatureFactor: temperatureFactor,
          );
          break;

        case .mifflin:
          final res = CalculateEerMifflin().call(
            gender: gender!,
            weight: weightKg,
            height: heightCm!,
            age: age!,
            activityFactor: activityFactor!,
            injuryFactor: injuryFactor,
            temperatureFactor: temperatureFactor,
          );
          if (res.isError) return Error((res as Error<EER, String>).error);
          final eer = (res as Ok<EER, String>).value;
          minValue = eer.minEer;
          maxValue = eer.maxEer;
          inputParams = _buildAdultParams(
            weightKg: weightKg,
            heightCm: heightCm,
            age: age,
            gender: gender,
            activityFactor: activityFactor,
            injuryFactor: injuryFactor,
            temperatureFactor: temperatureFactor,
          );
          break;

        case .schofield:
          final res = CalculateEerSchofield().call(
            weight: weightKg,
            height: heightCm!,
            age: age!,
            gender: gender!,
            activityFactor: activityFactor!,
            injuryFactor: injuryFactor,
            temperatureFactor: temperatureFactor,
          );
          if (res.isError) return Error((res as Error<EER, String>).error);
          final eer = (res as Ok<EER, String>).value;
          minValue = eer.minEer;
          maxValue = eer.maxEer;
          inputParams = _buildAdultParams(
            weightKg: weightKg,
            heightCm: heightCm,
            age: age,
            gender: gender,
            activityFactor: activityFactor,
            injuryFactor: injuryFactor,
            temperatureFactor: temperatureFactor,
          );
          break;

        case .who:
          final res = CalculateEerWho().call(
            weight: weightKg,
            age: age!,
            gender: gender!,
            activityFactor: activityFactor!,
            injuryFactor: injuryFactor,
            temperatureFactor: temperatureFactor,
          );
          if (res.isError) return Error((res as Error<EER, String>).error);
          final eer = (res as Ok<EER, String>).value;
          minValue = eer.minEer;
          maxValue = eer.maxEer;
          inputParams = [
            InputParamEntity(
              key: "weight_kg",
              label: "Peso (kg)",
              value: weightKg,
            ),
            InputParamEntity(key: "age", label: "Idade", value: age),
            InputParamEntity(
              key: "gender",
              label: "Sexo",
              value: gender.name,
            ),
            InputParamEntity(
              key: "activity_factor",
              label: "Fator de Atividade",
              value: activityFactor.name,
            ),
            if (injuryFactor != null)
              InputParamEntity(
                key: "injury_factor",
                label: "Fator de Injúria",
                value: injuryFactor.name,
              ),
            if (temperatureFactor != null)
              InputParamEntity(
                key: "temperature_factor",
                label: "Fator de Temperatura",
                value: temperatureFactor.name,
              ),
          ];
          break;

        case .pocket:
          final res = CalculateEerPocket().call(
            weight: weightKg,
            stressLevel: stressLevel,
          );
          if (res.isError) {
            return Error((res as Error<EERPocket, String>).error);
          }
          final pocket = (res as Ok<EERPocket, String>).value;
          minValue = pocket.min;
          maxValue = pocket.max;
          inputParams = [
            InputParamEntity(
              key: "weight_kg",
              label: "Peso (kg)",
              value: weightKg,
            ),
            InputParamEntity(
              key: "stress_level",
              label: "Nível de Estresse",
              value: stressLevel.name,
            ),
          ];
          break;
      }

      final entity = EnergyExpenditureCalculationEntity(
        patientId: patientId,
        formula: formula,
        minValue: minValue,
        maxValue: maxValue,
        createdAt: DateTime.now(),
        inputParams: inputParams,
      );

      return _repository.createEnergyExpenditure(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  List<InputParamEntity> _buildAdultParams({
    required double weightKg,
    required double heightCm,
    required int age,
    required Gender gender,
    required ActivityFactor activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
  }) => [
    InputParamEntity(key: "weight_kg", label: "Peso (kg)", value: weightKg),
    InputParamEntity(key: "height_cm", label: "Altura (cm)", value: heightCm),
    InputParamEntity(key: "age", label: "Idade", value: age),
    InputParamEntity(key: "gender", label: "Sexo", value: gender.name),
    InputParamEntity(
      key: "activity_factor",
      label: "Fator de Atividade",
      value: activityFactor.name,
    ),
    if (injuryFactor != null)
      InputParamEntity(
        key: "injury_factor",
        label: "Fator de Injúria",
        value: injuryFactor.name,
      ),
    if (temperatureFactor != null)
      InputParamEntity(
        key: "temperature_factor",
        label: "Fator de Temperatura",
        value: temperatureFactor.name,
      ),
  ];
}
