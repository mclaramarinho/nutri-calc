import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/data/models/enteral_nutrition_volume_model.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/entities/enteral_nutrition_volume_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/repositories/enteral_nutrition_volume_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: EnteralNutritionVolumeRepository)
class EnteralNutritionVolumeRepositoryImpl
    implements EnteralNutritionVolumeRepository {
  const EnteralNutritionVolumeRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>>
  createEnteralNutritionVolume(
    EnteralNutritionVolumeCalculationEntity enteralNutritionVolume,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = EnteralNutritionVolumeModel.fromEntity(
        enteralNutritionVolume,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(
        .enteralNutritionVolume,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Enteral Nutrition Volume calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<List<EnteralNutritionVolumeModel>, String>> getEnteralNutritionVolumes(String patientId) async {
    try {
      final res = await _databaseService.read(
        .enteralNutritionVolume,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => EnteralNutritionVolumeModel.fromJson(json)).toList());
      }

      return Error("Error getting enteral nutrition volume history for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<void, String>> deleteEnteralNutritionVolume(String id) async {
    try {
      final res = await _databaseService.delete(
        .enteralNutritionVolume,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isOk) {
        return const Ok(null);
      }
      return Error("Error deleting enteral nutrition volume calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
