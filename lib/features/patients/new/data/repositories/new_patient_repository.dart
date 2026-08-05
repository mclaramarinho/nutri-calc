import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/new/domain/repositories/new_patient_repository.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

@Injectable(as: NewPatientRepository)
class NewPatientRepositoryImpl implements NewPatientRepository {
  final AppDatabaseService _appDatabaseService;

  const NewPatientRepositoryImpl({required this._appDatabaseService});

  @override
  Future<Result<PatientModel, String>> createPatient(PatientModel data) async {
    try {
      final toAdd = data.copyWithId();
      await _appDatabaseService.insert(
        AppDatabaseTables.patient,
        toAdd.toJson(),
      );
      return Ok(toAdd);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
