import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/repositories/patient_details_repository.dart';

abstract class LoadPatientDetailsUseCase {
  Future<Result<EditPatientFormEntity, String>> call(String patientLocalId);
}

@Injectable(as: LoadPatientDetailsUseCase)
class LoadPatientDetailsUseCaseImpl implements LoadPatientDetailsUseCase {
  const LoadPatientDetailsUseCaseImpl({
    required this._patientDetailsRepository,
  });

  final PatientDetailsRepository _patientDetailsRepository;

  @override
  Future<Result<EditPatientFormEntity, String>> call(
    String patientLocalId,
  ) async {
    try {
      final patient = await _patientDetailsRepository.getPatientData(
        patientLocalId,
      );
      if (patient.isError) return Error((patient as Error).error);
      PatientModel pat = (patient as Ok).value;

      if(pat.id == null) {
        return Error("Patient does not exist on the database");
      }

      return Ok(
        EditPatientFormEntity(
          firstName: pat.firstName,
          lastName: pat.lastName,
          patientLocalId: pat.id!,
          patientId: pat.patientId,
          birthdate: pat.birthdate,
          age: pat.age,
          ageUnit: pat.ageUnit,
        ),
      );
    } catch (err) {
      return Error(err.toString());
    }
  }
}
