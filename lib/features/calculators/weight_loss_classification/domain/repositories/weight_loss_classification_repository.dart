import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/data/models/weight_loss_classification_model.dart';

abstract class WeightLossClassificationRepository {
  Future<Result<WeightLossClassificationCalculationEntity, String>>
  createWeightLossClassification(
    WeightLossClassificationCalculationEntity weightLossClassification,
  );

  Future<Result<List<WeightLossClassificationModel>, String>> getWeightLossClassifications(String patientId);
  Future<Result<void, String>> deleteWeightLossClassification(String id);
}
