import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/repositories/bmi_repository.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/bmi/calculate_bmi.usecase.dart';

abstract class SaveBmiCalculationUseCase {
  Future<Result<BmiCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double heightM,
    required int age,
  });
}

@Injectable(as: SaveBmiCalculationUseCase)
class SaveBmiCalculationUseCaseImpl implements SaveBmiCalculationUseCase {
  const SaveBmiCalculationUseCaseImpl({required this._repository});

  final BmiRepository _repository;

  @override
  Future<Result<BmiCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double heightM,
    required int age,
  }) async {
    try {
      final bmiRes = CalculateBmi().call(
        weight: weightKg,
        height: heightM,
        age: age,
      );

      if (bmiRes.isError) {
        return Error((bmiRes as Error<Bmi, String>).error);
      }

      final bmi = (bmiRes as Ok<Bmi, String>).value;

      final entity = BmiCalculationEntity(
        patientId: patientId,
        value: bmi.value,
        classification: bmi.classification,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "weight_kg",
            label: "Peso (kg)",
            value: weightKg,
          ),
          InputParamEntity(
            key: "height_m",
            label: "Altura (m)",
            value: heightM,
          ),
          InputParamEntity(key: "age", label: "Idade", value: age),
        ],
      );

      return _repository.createBmi(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
