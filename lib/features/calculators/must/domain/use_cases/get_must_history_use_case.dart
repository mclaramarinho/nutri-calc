import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/must/domain/repositories/must_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_classification_result.enum.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetMustHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetMustHistoryUseCase)
class GetMustHistoryUseCaseImpl implements GetMustHistoryUseCase {
  const GetMustHistoryUseCaseImpl({required this._repository});

  final MustRepository _repository;

  String _classificationLabel(MustClassificationResult classification) {
    return switch (classification) {
      .lowRisk => "Baixo risco",
      .mediumRisk => "Risco médio",
      .highRisk => "Alto risco",
    };
  }

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getMustCalculations(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.screening,
                sourceType: HistorySourceType.must,
                label: "MUST",
                resultSummary: "MUST: ${m.score} pontos (${_classificationLabel(m.classification)})",
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
