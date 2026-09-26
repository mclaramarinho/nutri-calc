import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';

abstract class WeightRepository {
  Future<Result<WeightModel, String>> createWeight({
    required double value,
    required String patientId,
    required bool considerForCalculations,
    required WeightTypeEnum weightType,
    List<InputParamEntity> inputParams = const [],
  });
  Future<Result<List<WeightModel>, String>> getWeights(String patientId);
  Future<Result<void, String>> deleteWeight(String id);
}
