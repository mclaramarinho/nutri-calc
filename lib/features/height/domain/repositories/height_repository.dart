import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/height/data/models/height_model.dart';

abstract class HeightRepository {
  Future<Result<HeightModel, String>> createHeight({
    required double value,
    required String patientId,
  });
  Future<Result<List<HeightModel>, String>> getHeights(String patientId);
}
