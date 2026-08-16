import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/repositories/patient_details_repository.dart';

abstract class UpdatePatientUseCase {
  Future<Result<void, String>> call(EditPatientFormEntity form);
}

@Injectable(as: UpdatePatientUseCase)
class UpdatePatientUseCaseImpl implements UpdatePatientUseCase {
  const UpdatePatientUseCaseImpl({required this._detailsRepository});

  final PatientDetailsRepository _detailsRepository;

  @override
  Future<Result<void, String>> call(EditPatientFormEntity form) async {
    try {
      return await _detailsRepository.updatePatient(
        PatientModel(
          firstName: form.firstName,
          lastName: form.lastName,
          patientId: form.patientId,
          birthdate: form.birthdate,
          age: form.age,
          ageUnit: form.ageUnit,
        ),
        form.patientLocalId,
      );
    } catch (err) {
      return Error(err.toString());
    }
  }
}
