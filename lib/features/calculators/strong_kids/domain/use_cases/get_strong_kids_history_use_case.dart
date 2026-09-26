import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/repositories/strong_kids_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_score_classification.enum.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetStrongKidsHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetStrongKidsHistoryUseCase)
class GetStrongKidsHistoryUseCaseImpl implements GetStrongKidsHistoryUseCase {
  const GetStrongKidsHistoryUseCaseImpl({required this._repository});

  final StrongKidsRepository _repository;

  String _classificationLabel(StrongKidsScoreClassification classification) {
    return switch (classification) {
      .low => "Baixo risco",
      .medium => "Risco médio",
      .highRisk => "Alto risco",
    };
  }

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getStrongKidsCalculations(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.screening,
                sourceType: HistorySourceType.strongKids,
                label: "STRONG-Kids",
                resultSummary: "STRONG-Kids: ${m.score} pontos (${_classificationLabel(m.classification)})",
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
