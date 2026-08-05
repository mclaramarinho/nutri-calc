import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/new/domain/entities/new_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/new/domain/repositories/new_patient_repository.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

abstract class CreatePatientUseCase {
  Future<Result<PatientModel, String>> call({
    required NewPatientFormEntity formData,
  });
}

@Injectable(as: CreatePatientUseCase)
class CreatePatientUseCaseImpl implements CreatePatientUseCase {
  final NewPatientRepository _newPatientRepository;

  const CreatePatientUseCaseImpl({required this._newPatientRepository});

  @override
  Future<Result<PatientModel, String>> call({
    required NewPatientFormEntity formData,
  }) async {
    try {
      final patient = PatientModel(
        firstName: formData.firstName,
        lastName: formData.lastName,
        patientId: formData.patientId,
        age: formData.age,
        birthdate: formData.birthdate,
        ageUnit: formData.ageUnit,
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
