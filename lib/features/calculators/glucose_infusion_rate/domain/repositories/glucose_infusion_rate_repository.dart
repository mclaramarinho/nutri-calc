import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/entities/glucose_infusion_rate_calculation_entity.dart';

abstract class GlucoseInfusionRateRepository {
  Future<Result<GlucoseInfusionRateCalculationEntity, String>>
  createGlucoseInfusionRate(
    GlucoseInfusionRateCalculationEntity glucoseInfusionRate,
  );
}
