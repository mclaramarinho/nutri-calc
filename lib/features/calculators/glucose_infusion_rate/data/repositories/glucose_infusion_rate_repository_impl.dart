import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/data/models/glucose_infusion_rate_model.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/entities/glucose_infusion_rate_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/repositories/glucose_infusion_rate_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: GlucoseInfusionRateRepository)
class GlucoseInfusionRateRepositoryImpl
    implements GlucoseInfusionRateRepository {
  const GlucoseInfusionRateRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<GlucoseInfusionRateCalculationEntity, String>>
  createGlucoseInfusionRate(
    GlucoseInfusionRateCalculationEntity glucoseInfusionRate,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = GlucoseInfusionRateModel.fromEntity(
        glucoseInfusionRate,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(
        .glucoseInfusionRates,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Glucose Infusion Rate calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
