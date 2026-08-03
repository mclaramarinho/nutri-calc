import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

abstract class ListPatientRepository {
  Future<Result<List<PatientModel>, String>> getPatients();
}
