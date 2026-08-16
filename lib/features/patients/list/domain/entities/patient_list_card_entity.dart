import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

class PatientListCardEntity {
  final String firstName;
  final String lastName;
  final int? age;
  final String? patientId;
  final TimeUnit? ageUnit;
  final String? localId;

  const PatientListCardEntity({
    required this.firstName,
    required this.localId,
    required this.lastName,
    this.age,
    this.patientId,
    this.ageUnit,
  });
}
