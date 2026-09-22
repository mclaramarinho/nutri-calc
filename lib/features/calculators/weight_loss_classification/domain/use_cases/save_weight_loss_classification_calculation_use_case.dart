import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/repositories/weight_loss_classification_repository.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/loss/classify_weigh_loss.usecase.dart';

abstract class SaveWeightLossClassificationCalculationUseCase {
  Future<Result<WeightLossClassificationCalculationEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required DateTime currentWeightDate,
    required double lastWeight,
    required DateTime lastWeightDate,
  });
}

@Injectable(as: SaveWeightLossClassificationCalculationUseCase)
class SaveWeightLossClassificationCalculationUseCaseImpl
    implements SaveWeightLossClassificationCalculationUseCase {
  const SaveWeightLossClassificationCalculationUseCaseImpl({
    required this._repository,
  });

  final WeightLossClassificationRepository _repository;

  @override
  Future<Result<WeightLossClassificationCalculationEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required DateTime currentWeightDate,
    required double lastWeight,
    required DateTime lastWeightDate,
  }) async {
    try {
      final res = ClassifyWeighLoss().call(
        currentWeight: currentWeight,
        lastWeight: lastWeight,
        lastWeightDate: lastWeightDate,
        currentWeightDate: currentWeightDate,
      );

      if (res.isError) {
        return Error((res as Error<WeightLoss, String>).error);
      }

      final weightLoss = (res as Ok<WeightLoss, String>).value;

      final entity = WeightLossClassificationCalculationEntity(
        patientId: patientId,
        percentage: weightLoss.percentage,
        timeReference: weightLoss.timeReference,
        classification: weightLoss.classification,
        createdAt: DateTime.now(),
        inputParams: [
          InputParamEntity(
            key: "current_weight_kg",
            label: "Peso Atual (kg)",
            value: currentWeight,
          ),
          InputParamEntity(
            key: "current_weight_date",
            label: "Data do Peso Atual",
            value: currentWeightDate.toIso8601String(),
          ),
          InputParamEntity(
            key: "last_weight_kg",
            label: "Peso Anterior (kg)",
            value: lastWeight,
          ),
          InputParamEntity(
            key: "last_weight_date",
            label: "Data do Peso Anterior",
            value: lastWeightDate.toIso8601String(),
          ),
        ],
      );

      return _repository.createWeightLossClassification(entity);
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
