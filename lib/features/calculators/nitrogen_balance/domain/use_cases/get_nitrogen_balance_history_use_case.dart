import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/repositories/nitrogen_balance_repository.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetNitrogenBalanceHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetNitrogenBalanceHistoryUseCase)
class GetNitrogenBalanceHistoryUseCaseImpl implements GetNitrogenBalanceHistoryUseCase {
  const GetNitrogenBalanceHistoryUseCaseImpl({required this._repository});

  final NitrogenBalanceRepository _repository;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getNitrogenBalances(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.nitrogenBalance,
                sourceType: HistorySourceType.nitrogenBalance,
                label: "Balanço Nitrogenado",
                resultSummary: "Balanço Nitrogenado: ${m.value.toStringAsFixed(2)}",
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
