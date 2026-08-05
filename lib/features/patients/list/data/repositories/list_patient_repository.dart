import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/list/domain/repositories/list_patient_repository.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

@Injectable(as: ListPatientRepository)
class ListPatientRepositoryImpl implements ListPatientRepository {
  final AppDatabaseService _appDatabaseService;

  const ListPatientRepositoryImpl({required this._appDatabaseService});

  @override
  Future<Result<List<PatientModel>, String>> getPatients() async {
    try {
      final res = await _appDatabaseService.read(AppDatabaseTables.patient);
      if (res.isError) {
        return Error((res as Error).error);
      }

      final value = ((res as Ok).value as List<Map<String, Object?>>);

      return Ok(value.map(PatientModel.fromJson).toList());
    } catch (err) {
      return Error(err.toString());
    }
  }
}
