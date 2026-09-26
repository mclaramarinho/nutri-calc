import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/entities/protein_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/protein_needs/data/models/protein_needs_model.dart';

abstract class ProteinNeedsRepository {
  Future<Result<ProteinNeedsCalculationEntity, String>> createProteinNeeds(
    ProteinNeedsCalculationEntity proteinNeeds,
  );

  Future<Result<List<ProteinNeedsModel>, String>> getProteinNeeds(String patientId);
  Future<Result<void, String>> deleteProteinNeeds(String id);
}
