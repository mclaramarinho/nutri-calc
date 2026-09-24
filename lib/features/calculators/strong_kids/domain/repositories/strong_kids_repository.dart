import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/entities/strong_kids_calculation_entity.dart';

abstract class StrongKidsRepository {
  Future<Result<StrongKidsCalculationEntity, String>>
  createStrongKidsCalculation(StrongKidsCalculationEntity strongKids);
}
