import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

abstract class NewPatientRepository {
  Future<Result<PatientModel, String>> createPatient(PatientModel data);
}
