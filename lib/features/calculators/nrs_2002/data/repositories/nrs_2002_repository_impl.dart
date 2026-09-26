import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/data/models/nrs_2002_model.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/entities/nrs_2002_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/repositories/nrs_2002_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: Nrs2002Repository)
class Nrs2002RepositoryImpl implements Nrs2002Repository {
  const Nrs2002RepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<Nrs2002CalculationEntity, String>> createNrs2002Calculation(
    Nrs2002CalculationEntity nrs2002,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors
      // `WeightLossClassificationRepositoryImpl`: the DB service's `insert`
      // only returns the sqflite rowid (an int), not the row's data, so
      // round-tripping through `fromJson(rowid)` would throw.
      final model = Nrs2002Model.fromEntity(nrs2002, id: Uuid().v4());

      final res = await _databaseService.insert(
        .screeningNrs2002,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating NRS-2002 calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<List<Nrs2002Model>, String>> getNrs2002Calculations(String patientId) async {
    try {
      final res = await _databaseService.read(
        .screeningNrs2002,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => Nrs2002Model.fromJson(json)).toList());
      }

      return Error("Error getting nrs 2002 history for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<void, String>> deleteNrs2002Calculation(String id) async {
    try {
      final res = await _databaseService.delete(
        .screeningNrs2002,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isOk) {
        return const Ok(null);
      }
      return Error("Error deleting nrs 2002 calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
