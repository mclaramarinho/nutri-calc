import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';

abstract class BmiRepository {
  Future<Result<BmiCalculationEntity, String>> createBmi(
    BmiCalculationEntity bmi,
  );
}
