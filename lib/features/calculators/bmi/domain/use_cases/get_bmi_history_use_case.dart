import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/repositories/bmi_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

/// One of the 14 leaf history sources fanned out by
/// `GetPatientCalculatorHistoryUseCase` (ADR 0009). Formatting (the
/// `resultSummary`) is authored once, here, at the source.
abstract class GetBmiHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetBmiHistoryUseCase)
class GetBmiHistoryUseCaseImpl implements GetBmiHistoryUseCase {
  const GetBmiHistoryUseCaseImpl({required this._repository});

  final BmiRepository _repository;

  String _classificationLabel(BmiClassification classification) {
    return switch (classification) {
      .low => "Baixo peso",
      .eutrophy => "Eutrofia",
      .overweight => "Sobrepeso",
      .obesity => "Obesidade Grau I",
      .obesityGrade2 => "Obesidade Grau II",
      .obesityGrade3 => "Obesidade Grau III",
    };
  }

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    final res = await _repository.getBmis(patientId);
    return res.when(
      ok: (models) => Ok(
        models
            .map(
              (m) => HistoryEntryEntity(
                id: m.id,
                patientId: m.patientId,
                type: CalculatorType.bmi,
                sourceType: HistorySourceType.bmi,
                label: "IMC",
                resultSummary: "IMC: ${m.value.toStringAsFixed(2)} (${_classificationLabel(m.classification)})",
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
