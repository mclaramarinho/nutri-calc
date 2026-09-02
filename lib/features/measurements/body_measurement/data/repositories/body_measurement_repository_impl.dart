import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/body_measurement/data/models/body_measurement_model.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/repositories/body_measurement_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: BodyMeasurementRepository)
class BodyMeasurementRepositoryImpl implements BodyMeasurementRepository {
  const BodyMeasurementRepositoryImpl({required this._database});
  final AppDatabaseService _database;

  @override
  Future<Result<List<BodyMeasurementModel>, String>> getMeasurements(
    String patientId,
  ) async {
    try {
      final data = await _database.read(
        .bodyMeasurements,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );

      if (data.isError) {
        return Error("Error fetching body measurements.");
      }

      final typedData = data as Ok<List<Map<String, Object?>>, String>;

      final models = typedData.value
          .map((ms) => BodyMeasurementModel.fromJson(ms))
          .toList();

      return Ok(models);
    } catch (ex) {
      return Error("Error fetching body measurements: ${ex.toString()}");
    }
  }

  @override
  Future<Result<BodyMeasurementModel, String>> createMeasurement(
    BodyMeasurementModel model,
  ) async {
    try {
      final dataWithId = model.toJson();
      dataWithId.addEntries([MapEntry('id', Uuid().v4())]);

      final createResult = await _database.insert(
        .bodyMeasurements,
        model.toJson(),
      );

      if(createResult.isError || (createResult as Ok).value == 0) {
        return Error("Error creating measurement.");
      }

      return Ok(BodyMeasurementModel.fromJson(dataWithId));
    } catch (ex) {
      return Error("Error creating measurement: ${ex.toString()}");
    }
  }
}
