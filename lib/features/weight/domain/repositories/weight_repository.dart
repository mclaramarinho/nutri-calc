import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/weight/data/models/weight_model.dart';

abstract class WeightRepository {
  Future<Result<WeightModel, String>> createWeight({
    required double value,
    required String patientId,
  });
  Future<Result<List<WeightModel>, String>> getWeights(String patientId);
}
