import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/data/models/energy_expenditure_model.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/repositories/energy_expenditure_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: EnergyExpenditureRepository)
class EnergyExpenditureRepositoryImpl implements EnergyExpenditureRepository {
  const EnergyExpenditureRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<EnergyExpenditureCalculationEntity, String>>
  createEnergyExpenditure(
    EnergyExpenditureCalculationEntity energyExpenditure,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = EnergyExpenditureModel.fromEntity(
        energyExpenditure,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(
        .energyExpenditures,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Energy Expenditure calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<List<EnergyExpenditureModel>, String>> getEnergyExpenditures(String patientId) async {
    try {
      final res = await _databaseService.read(
        .energyExpenditures,
        where: 'patientId = ?',
        whereArgs: [patientId],
      );
      if (res.isOk) {
        final val = res as Ok<List<Map<String, dynamic>>, String>;
        return Ok(val.value.map((json) => EnergyExpenditureModel.fromJson(json)).toList());
      }

      return Error("Error getting energy expenditure history for patient $patientId");
    } catch (ex) {
      return Error(ex.toString());
    }
  }

  @override
  Future<Result<void, String>> deleteEnergyExpenditure(String id) async {
    try {
      final res = await _databaseService.delete(
        .energyExpenditures,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (res.isOk) {
        return const Ok(null);
      }
      return Error("Error deleting energy expenditure calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
