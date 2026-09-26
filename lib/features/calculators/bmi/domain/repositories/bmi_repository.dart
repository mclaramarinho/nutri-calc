import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/data/models/bmi_model.dart';

abstract class BmiRepository {
  Future<Result<BmiCalculationEntity, String>> createBmi(
    BmiCalculationEntity bmi,
  );

  Future<Result<List<BmiModel>, String>> getBmis(String patientId);
  Future<Result<void, String>> deleteBmi(String id);
}
