import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/repositories/enteral_nutrition_dripping_repository.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetEnteralNutritionDrippingHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetEnteralNutritionDrippingHistoryUseCase)
class GetEnteralNutritionDrippingHistoryUseCaseImpl implements GetEnteralNutritionDrippingHistoryUseCase {
  const GetEnteralNutritionDrippingHistoryUseCaseImpl({required this._repository});

  final EnteralNutritionDrippingRepository _repository;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getEnteralNutritionDrippings(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.enteralNutrition,
                sourceType: HistorySourceType.enteralNutritionDripping,
                label: "Gotejamento",
                resultSummary: "Gotejamento: ${m.value.toStringAsFixed(0)} gotas/min",
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
