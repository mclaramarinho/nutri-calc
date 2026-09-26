import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/repositories/protein_needs_repository.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetProteinNeedsHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetProteinNeedsHistoryUseCase)
class GetProteinNeedsHistoryUseCaseImpl implements GetProteinNeedsHistoryUseCase {
  const GetProteinNeedsHistoryUseCaseImpl({required this._repository});

  final ProteinNeedsRepository _repository;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getProteinNeeds(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.proteinNeeds,
                sourceType: HistorySourceType.proteinNeeds,
                label: "Necessidade Proteica",
                resultSummary: "Necessidade Proteica: ${m.minValue.toStringAsFixed(1)} – ${m.maxValue.toStringAsFixed(1)} g/kg",
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
