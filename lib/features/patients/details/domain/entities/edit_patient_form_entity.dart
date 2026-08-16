import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

class EditPatientFormEntity {
  final String? patientId;
  final String firstName;
  final String lastName;
  final DateTime? birthdate;
  final int? age;
  final TimeUnit? ageUnit;
  final String patientLocalId;

  const EditPatientFormEntity({
    required this.firstName,
    required this.lastName,
    required this.patientLocalId,
    this.patientId,
    this.birthdate,
    this.age,
    this.ageUnit,
  });

  EditPatientFormEntity copyWith({
    String? patientId,
    String? firstName,
    String? lastName,
    DateTime? birthdate,
    int? age,
    TimeUnit? ageUnit,
  }) => EditPatientFormEntity(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    patientLocalId: this.patientLocalId,
    patientId: patientId ?? this.patientId,
    birthdate: birthdate ?? this.birthdate,
    age: age ?? this.age,
    ageUnit: ageUnit ?? this.ageUnit
  );
}
