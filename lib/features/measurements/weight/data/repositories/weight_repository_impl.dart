import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/repositories/weight_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: WeightRepository)
class WeightRepositoryImpl implements WeightRepository {
  const WeightRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<List<WeightModel>, String>> getWeights(String patientId) async {
    try {
      final res = await _databaseService.read(.weights);
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => WeightModel.fromJson(json)).toList());
      }

      return Error("Error getting weights for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<WeightModel, String>> createWeight({
    required double value,
    required String patientId,
  }) async {
    try {
      final res = await _databaseService.insert(
        .weights,
        WeightModel(
          value: value,
          createdAt: DateTime.now(),
          patientId: patientId,
          id: Uuid().v4(),
        ).toJson(),
      );

      if (res.isOk) {
        final val = (res as Ok).value;
        return Ok(WeightModel.fromJson(val));
      }
      return Error("Error creating weight.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}

