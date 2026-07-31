import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/new/data/models/patient.model.dart';
import 'package:nutri_calc/features/patients/new/data/repositories/patient.repository.dart';
import 'package:nutri_calc/features/patients/new/domain/entities/new_patient_form.entity.dart';
import 'package:nutri_calc/shared/utils/result/result.dart';

abstract class CreatePatient {
  Future<Result<Patient, String>> call({required NewPatientForm formData});
}

@Injectable(as: CreatePatient)
class CreatePatientImpl implements CreatePatient {
  final NewPatientRepository _newPatientRepository;

  const CreatePatientImpl({required this._newPatientRepository});

  @override
  Future<Result<Patient, String>> call({
    required NewPatientForm formData,
  }) async {
    try {
      final patient = Patient(
        firstName: formData.firstName,
        lastName: formData.lastName,
        patientId: formData.patientId,
        age: formData.age,
        birthdate: formData.birthdate,
      );
      final res = await _newPatientRepository.createPatient(patient);

      if (res.isError) {
        return Error((res as Error).error);
      }

      return Ok((res as Ok).value);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
