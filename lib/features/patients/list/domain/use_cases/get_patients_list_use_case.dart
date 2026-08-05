import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/list/domain/entities/patient_list_card_entity.dart';
import 'package:nutri_calc/features/patients/list/domain/repositories/list_patient_repository.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

abstract class GetPatientsListUseCase {
  Future<Result<List<PatientListCardEntity>, String>> call();
}

@Injectable(as: GetPatientsListUseCase)
class GetPatientsListUseCaseImpl implements GetPatientsListUseCase {
  const GetPatientsListUseCaseImpl({required this._listPatientRepository});

  final ListPatientRepository _listPatientRepository;

  @override
  Future<Result<List<PatientListCardEntity>, String>> call() async {
    try {
      final res = await _listPatientRepository.getPatients();

      if (res.isError) return Error((res as Error).error);

      final entities = (res as Ok<List<PatientModel>, String>).value.map(
        (pt) => PatientListCardEntity(
          firstName: pt.firstName,
          lastName: pt.lastName,
          patientId: pt.patientId,
          age: pt.age,
          ageUnit: pt.ageUnit
        ),
      );
      return Ok(entities.toList());
    } catch (err) {
      return Error(err.toString());
    }
  }
}
