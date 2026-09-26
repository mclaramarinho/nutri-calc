import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/repositories/glucose_infusion_rate_repository.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetGlucoseInfusionRateHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetGlucoseInfusionRateHistoryUseCase)
class GetGlucoseInfusionRateHistoryUseCaseImpl implements GetGlucoseInfusionRateHistoryUseCase {
  const GetGlucoseInfusionRateHistoryUseCaseImpl({required this._repository});

  final GlucoseInfusionRateRepository _repository;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getGlucoseInfusionRates(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.parenteralNutrition,
                sourceType: HistorySourceType.glucoseInfusionRate,
                label: "TIG",
                resultSummary: "TIG: ${m.value.toStringAsFixed(2)} mg/kg/min",
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
