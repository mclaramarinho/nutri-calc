import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';

abstract class PatientDetailsRepository {
  Future<Result<PatientModel, String>> getPatientData(String localId);
  Future<Result<void, String>> updatePatient(
    PatientModel patient,
  );
}
