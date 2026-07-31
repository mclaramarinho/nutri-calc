import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/new/data/models/patient.model.dart';
import 'package:nutri_calc/shared/services/database/app_database.service.dart';
import 'package:nutri_calc/shared/services/database/app_database_tables.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

abstract class NewPatientRepository {
  Future<Result<Patient, String>> createPatient(Patient data);
}

@Injectable(as: NewPatientRepository)
class NewPatientRepositoryImpl implements NewPatientRepository {
  final AppDatabase _appDatabase;

  const NewPatientRepositoryImpl({required this._appDatabase});

  @override
  Future<Result<Patient, String>> createPatient(Patient data) async {
    try {
      final toAdd = data.copyWithId();
      await _appDatabase.insert(AppDatabaseTables.patient, toAdd.toJson());
      return Ok(toAdd);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
