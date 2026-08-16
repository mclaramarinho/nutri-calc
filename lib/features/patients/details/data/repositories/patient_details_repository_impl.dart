import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/details/domain/repositories/patient_details_repository.dart';

@Injectable(as: PatientDetailsRepository)
class PatientDetailsRepositoryImpl implements PatientDetailsRepository {
  const PatientDetailsRepositoryImpl({required this._databaseService});

  final AppDatabaseService _databaseService;

  @override
  Future<Result<PatientModel, String>> getPatientData(String localId) async {
    try {
      final data = await _databaseService.read(
        .patient,
        where: "id = ?",
        whereArgs: [localId],
        limit: 1,
      );

      if (data.isError) return Error((data as Error).error);

      late Map<String, Object?>? patient;
      if (data.isOk) {
        patient =
            ((data as Ok).value as List<Map<String, Object?>>).firstOrNull;
      }

      if (patient != null) {
        return Ok(PatientModel.fromJson(patient));
      }

      return Error("Patient not found");
    } catch (err) {
      return Error(err.toString());
    }
  }
}
