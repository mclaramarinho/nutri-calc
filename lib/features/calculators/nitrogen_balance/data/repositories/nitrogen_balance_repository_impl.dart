import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/data/models/nitrogen_balance_model.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/entities/nitrogen_balance_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/repositories/nitrogen_balance_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: NitrogenBalanceRepository)
class NitrogenBalanceRepositoryImpl implements NitrogenBalanceRepository {
  const NitrogenBalanceRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<NitrogenBalanceCalculationEntity, String>> createNitrogenBalance(
    NitrogenBalanceCalculationEntity nitrogenBalance,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = NitrogenBalanceModel.fromEntity(
        nitrogenBalance,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(
        .nitrogenBalances,
        model.toJson(),
      );

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Nitrogen Balance calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
