import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/entities/water_needs_calculation_entity.dart';

abstract class WaterNeedsRepository {
  Future<Result<WaterNeedsCalculationEntity, String>> createWaterNeeds(
    WaterNeedsCalculationEntity waterNeeds,
  );
}
