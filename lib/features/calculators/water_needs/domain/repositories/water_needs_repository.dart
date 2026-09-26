import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/entities/water_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/water_needs/data/models/water_needs_model.dart';

abstract class WaterNeedsRepository {
  Future<Result<WaterNeedsCalculationEntity, String>> createWaterNeeds(
    WaterNeedsCalculationEntity waterNeeds,
  );

  Future<Result<List<WaterNeedsModel>, String>> getWaterNeeds(String patientId);
  Future<Result<void, String>> deleteWaterNeeds(String id);
}
