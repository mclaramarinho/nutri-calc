import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/must/domain/entities/must_calculation_entity.dart';

abstract class MustRepository {
  Future<Result<MustCalculationEntity, String>> createMustCalculation(
    MustCalculationEntity must,
  );
}
