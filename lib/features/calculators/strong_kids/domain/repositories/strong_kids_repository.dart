import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/entities/strong_kids_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/strong_kids/data/models/strong_kids_model.dart';

abstract class StrongKidsRepository {
  Future<Result<StrongKidsCalculationEntity, String>>
  createStrongKidsCalculation(StrongKidsCalculationEntity strongKids);

  Future<Result<List<StrongKidsModel>, String>> getStrongKidsCalculations(String patientId);
  Future<Result<void, String>> deleteStrongKidsCalculation(String id);
}
