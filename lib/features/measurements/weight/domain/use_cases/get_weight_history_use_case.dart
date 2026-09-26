import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/format_weight_value.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';

/// The 14th (Weight) leaf history source. Does NOT duplicate
/// `WeightRepository`/`GetWeightsUseCase` (ADR 0009) - it wraps the existing
/// `GetWeightsUseCase` and maps each `WeightEntity` to a `HistoryEntryEntity`
/// using `WeightTypeEnum.label` and `FormatWeightValue`, keeping the fan-out
/// uniform (14 `GetXHistoryUseCase`s, no special-cased branch anywhere else).
abstract class GetWeightHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetWeightHistoryUseCase)
class GetWeightHistoryUseCaseImpl implements GetWeightHistoryUseCase {
  const GetWeightHistoryUseCaseImpl({required this._getWeightsUseCase});

  final GetWeightsUseCase _getWeightsUseCase;
  static const _formatWeightValue = FormatWeightValue();

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(
    String patientId,
  ) async {
    final res = await _getWeightsUseCase(patientId);
    return res.when(
      ok: (weights) => Ok(
        weights
            .map(
              (w) => HistoryEntryEntity(
                id: w.id!,
                patientId: w.patientId,
                type: CalculatorType.weight,
                sourceType: HistorySourceType.weight,
                label: w.weightType.label,
                resultSummary: _formatWeightValue(w),
                inputParams: w.inputParams,
                createdAt: w.createdAt,
              ),
            )
            .toList(),
      ),
      error: (e) => Error(e),
    );
  }
}
