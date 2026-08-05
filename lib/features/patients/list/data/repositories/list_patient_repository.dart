import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/core/services/database/app_database_tables.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/list/domain/repositories/list_patient_repository.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

@Injectable(as: ListPatientRepository)
class ListPatientRepositoryImpl implements ListPatientRepository {
  final AppDatabaseService _appDatabaseService;

  const ListPatientRepositoryImpl({required this._appDatabaseService});

  @override
  Future<Result<List<PatientModel>, String>> getPatients() async {
    try {
      final res = await _appDatabaseService.read<PatientModel>(
        AppDatabaseTables.patient,
        mapper: PatientModel.fromJson,
      );
      if (res.isError) {
        return Error((res as Error).error);
      }

      return Ok((res as Ok).value);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
