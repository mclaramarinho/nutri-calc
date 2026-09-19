import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/data/models/bmi_model.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/repositories/bmi_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: BmiRepository)
class BmiRepositoryImpl implements BmiRepository {
  const BmiRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<BmiCalculationEntity, String>> createBmi(
    BmiCalculationEntity bmi,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors the fixed
      // `WeightRepositoryImpl.createWeight` pattern (see part C): the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = BmiModel.fromEntity(bmi, id: Uuid().v4());

      final res = await _databaseService.insert(.bmi, model.toJson());

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating BMI calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
