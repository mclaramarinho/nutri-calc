import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/height/data/models/height_model.dart';
import 'package:nutri_calc/features/height/domain/repositories/height_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: HeightRepository)
class HeightRepositoryImpl implements HeightRepository {
  const HeightRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<List<HeightModel>, String>> getHeights(String patientId) async {
    try {
      final res = await _databaseService.read(.heights);
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => HeightModel.fromJson(json)).toList());
      }

      return Error("Error getting heights for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<HeightModel, String>> createHeight({
    required double value,
    required String patientId,
  }) async {
    try {
      final res = await _databaseService.insert(
        .heights,
        HeightModel(
          value: value,
          createdAt: DateTime.now(),
          patientId: patientId,
          id: Uuid().v4(),
        ).toJson(),
      );

      if (res.isOk) {
        final val = (res as Ok).value;
        return Ok(HeightModel.fromJson(val));
      }
      return Error("Error creating height.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}

