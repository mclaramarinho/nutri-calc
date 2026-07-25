import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/new/data/models/patient.model.dart';
import 'package:nutri_calc/shared/services/database/app_database.service.dart';
import 'package:nutri_calc/shared/services/database/app_database_tables.enum.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

abstract class PatientRepository {}

@Injectable(as: PatientRepository)
class PatientRepositoryImpl implements PatientRepository {
  final AppDatabase _appDatabase;

  const PatientRepositoryImpl({required this._appDatabase});

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
