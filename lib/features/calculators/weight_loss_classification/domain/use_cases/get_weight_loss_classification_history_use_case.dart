import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/repositories/weight_loss_classification_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetWeightLossClassificationHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetWeightLossClassificationHistoryUseCase)
class GetWeightLossClassificationHistoryUseCaseImpl implements GetWeightLossClassificationHistoryUseCase {
  const GetWeightLossClassificationHistoryUseCaseImpl({required this._repository});

  final WeightLossClassificationRepository _repository;

  String _classificationLabel(WeightLossClassification classification) {
    return switch (classification) {
      .ok => "Adequada",
      .significant => "Significativa",
      .severe => "Grave",
    };
  }

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getWeightLossClassifications(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.weightLossClassification,
                sourceType: HistorySourceType.weightLossClassification,
                label: "Classificação de Perda de Peso",
                resultSummary: "Perda de Peso: ${m.percentage.toStringAsFixed(1)}% (${_classificationLabel(m.classification)})",
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
