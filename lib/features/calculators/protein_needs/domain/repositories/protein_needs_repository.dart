import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/entities/protein_needs_calculation_entity.dart';

abstract class ProteinNeedsRepository {
  Future<Result<ProteinNeedsCalculationEntity, String>> createProteinNeeds(
    ProteinNeedsCalculationEntity proteinNeeds,
  );
}
