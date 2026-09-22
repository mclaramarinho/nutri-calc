import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/data/models/weight_loss_classification_model.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/repositories/weight_loss_classification_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: WeightLossClassificationRepository)
class WeightLossClassificationRepositoryImpl
    implements WeightLossClassificationRepository {
  const WeightLossClassificationRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<WeightLossClassificationCalculationEntity, String>>
  createWeightLossClassification(
    WeightLossClassificationCalculationEntity weightLossClassification,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = WeightLossClassificationModel.fromEntity(
        weightLossClassification,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(
        .weightLossClassifications,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Weight Loss Classification calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
