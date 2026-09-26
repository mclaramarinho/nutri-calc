import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/repositories/water_needs_repository.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetWaterNeedsHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetWaterNeedsHistoryUseCase)
class GetWaterNeedsHistoryUseCaseImpl implements GetWaterNeedsHistoryUseCase {
  const GetWaterNeedsHistoryUseCaseImpl({required this._repository});

  final WaterNeedsRepository _repository;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getWaterNeeds(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.waterNeeds,
                sourceType: HistorySourceType.waterNeeds,
                label: "Necessidade Hídrica",
                resultSummary: "Necessidade Hídrica: ${m.value.toStringAsFixed(0)} ml",
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
