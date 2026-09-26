import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/repositories/enteral_nutrition_speed_repository.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetEnteralNutritionSpeedHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetEnteralNutritionSpeedHistoryUseCase)
class GetEnteralNutritionSpeedHistoryUseCaseImpl implements GetEnteralNutritionSpeedHistoryUseCase {
  const GetEnteralNutritionSpeedHistoryUseCaseImpl({required this._repository});

  final EnteralNutritionSpeedRepository _repository;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getEnteralNutritionSpeeds(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.enteralNutrition,
                sourceType: HistorySourceType.enteralNutritionSpeed,
                label: "Velocidade de Infusão",
                resultSummary: "Velocidade de Infusão: ${m.value.toStringAsFixed(1)} ml/h",
                inputParams: m.inputParams,
                createdAt: m.createdAt,
              ),
            )
            .toList(),
      ),
      error: (e) => Error(e),
    );
  }
}
