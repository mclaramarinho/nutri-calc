import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/repositories/energy_expenditure_repository.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetEnergyExpenditureHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetEnergyExpenditureHistoryUseCase)
class GetEnergyExpenditureHistoryUseCaseImpl implements GetEnergyExpenditureHistoryUseCase {
  const GetEnergyExpenditureHistoryUseCaseImpl({required this._repository});

  final EnergyExpenditureRepository _repository;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getEnergyExpenditures(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.energyExpenditure,
                sourceType: HistorySourceType.energyExpenditure,
                label: "Gasto Energético",
                resultSummary: "Gasto Energético: ${m.minValue.toStringAsFixed(0)} – ${m.maxValue.toStringAsFixed(0)} kcal",
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
