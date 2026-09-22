import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/entities/protein_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/repositories/protein_needs_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/protein/protein_needs.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/protein/calculate_protein_needs.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';

abstract class SaveProteinNeedsCalculationUseCase {
  Future<Result<ProteinNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required PatientState patientState,
  });
}

@Injectable(as: SaveProteinNeedsCalculationUseCase)
class SaveProteinNeedsCalculationUseCaseImpl
    implements SaveProteinNeedsCalculationUseCase {
  const SaveProteinNeedsCalculationUseCaseImpl({required this._repository});

  final ProteinNeedsRepository _repository;

  @override
  Future<Result<ProteinNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required PatientState patientState,
  }) async {
    try {
      final res = CalculateProteinNeeds().call(
        weight: weightKg,
        patientState: patientState,
      );

      if (res.isError) {
        return Error((res as Error<ProteinNeeds, String>).error);
      }

      final proteinNeeds = (res as Ok<ProteinNeeds, String>).value;

      final entity = ProteinNeedsCalculationEntity(
        patientId: patientId,
        minValue: proteinNeeds.min,
        maxValue: proteinNeeds.max,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "weight_kg",
            label: "Peso (kg)",
            value: weightKg,
          ),
          InputParamEntity(
            key: "patient_state",
            label: "Estado do paciente",
            value: patientState.name,
          ),
        ],
      );

      return _repository.createProteinNeeds(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
