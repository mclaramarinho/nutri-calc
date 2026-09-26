import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/entities/glucose_infusion_rate_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/data/models/glucose_infusion_rate_model.dart';

abstract class GlucoseInfusionRateRepository {
  Future<Result<GlucoseInfusionRateCalculationEntity, String>>
  createGlucoseInfusionRate(
    GlucoseInfusionRateCalculationEntity glucoseInfusionRate,
  );

  Future<Result<List<GlucoseInfusionRateModel>, String>> getGlucoseInfusionRates(String patientId);
  Future<Result<void, String>> deleteGlucoseInfusionRate(String id);
}
