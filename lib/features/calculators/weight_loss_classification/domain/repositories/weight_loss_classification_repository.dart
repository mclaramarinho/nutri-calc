import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';

abstract class WeightLossClassificationRepository {
  Future<Result<WeightLossClassificationCalculationEntity, String>>
  createWeightLossClassification(
    WeightLossClassificationCalculationEntity weightLossClassification,
  );
}
