import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/protein_needs/data/models/protein_needs_model.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/entities/protein_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/repositories/protein_needs_repository.dart';
import 'package:uuid/uuid.dart';

@Injectable(as: ProteinNeedsRepository)
class ProteinNeedsRepositoryImpl implements ProteinNeedsRepository {
  const ProteinNeedsRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<ProteinNeedsCalculationEntity, String>> createProteinNeeds(
    ProteinNeedsCalculationEntity proteinNeeds,
  ) async {
    try {
      // Build the model locally (with a generated id) BEFORE inserting, and
      // return it directly on success — mirrors `BmiRepositoryImpl`: the DB
      // service's `insert` only returns the sqflite rowid (an int), not the
      // row's data, so round-tripping through `fromJson(rowid)` would throw.
      final model = ProteinNeedsModel.fromEntity(
        proteinNeeds,
        id: Uuid().v4(),
      );

      final res = await _databaseService.insert(.proteinNeeds, model.toJson());

      if (res.isOk) {
        return Ok(model.toEntity());
      }
      return Error("Error creating Protein Needs calculation.");
    } catch (ex) {
      return Error(ex.toString());
    }
  }
}
