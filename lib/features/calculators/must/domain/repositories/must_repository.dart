import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/must/domain/entities/must_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/must/data/models/must_model.dart';

abstract class MustRepository {
  Future<Result<MustCalculationEntity, String>> createMustCalculation(
    MustCalculationEntity must,
  );

  Future<Result<List<MustModel>, String>> getMustCalculations(String patientId);
  Future<Result<void, String>> deleteMustCalculation(String id);
}
