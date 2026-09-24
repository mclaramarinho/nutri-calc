import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/repositories/weight_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: WeightRepository)
class WeightRepositoryImpl implements WeightRepository {
  const WeightRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<List<WeightModel>, String>> getWeights(String patientId) async {
    try {
      final res = await _databaseService.read(
        .weights,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );
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
    required bool considerForCalculations,
    required WeightTypeEnum weightType,
    List<InputParamEntity> inputParams = const [],
  }) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting.
      // `AppDatabaseService.insert` returns the sqflite rowid (an int), not
      // the inserted row's data — calling `WeightModel.fromJson` on that raw
      // int used to throw here, get swallowed by this method's own
      // try/catch, and silently return `Error` on every real weight
      // creation. Returning the locally-built model on success avoids the
      // bogus round-trip through `fromJson(rowid)`.
      final model = WeightModel(
        value: value,
        createdAt: DateTime.now(),
        patientId: patientId,
        id: Uuid().v4(),
        considerForCalculations: considerForCalculations,
        weightType: weightType,
        inputParams: inputParams,
      );

      final res = await _databaseService.insert(.weights, model.toJson());

      if (res.isOk) {
        return Ok(model);
      }
      return Error("Error creating weight.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
