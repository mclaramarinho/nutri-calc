import 'package:equatable/equatable.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

class NewPatientFormEntity extends Equatable {
  /// Identifier from healthcare provider
  final String? patientId;

  // General
  final String firstName;
  final String lastName;
  final DateTime? birthdate;
  final int? age;
  final TimeUnit? ageUnit;

  const NewPatientFormEntity({
    required this.firstName,
    required this.lastName,
    this.patientId,
    this.birthdate,
    this.age,
    this.ageUnit,
  });

  NewPatientFormEntity copyWith({
    String? patientId,
    String? firstName,
    String? lastName,
    DateTime? birthdate,
    int? age,
    TimeUnit? ageUnit,
  }) {
    return NewPatientFormEntity(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      patientId: patientId ?? this.patientId,
      birthdate: birthdate ?? this.birthdate,
      age: age ?? this.age,
      ageUnit: ageUnit ?? this.ageUnit,
    );
  }

  NewPatientFormEntity clearAge() {
    return NewPatientFormEntity(
      firstName: firstName,
      lastName: lastName,
      patientId: patientId,
      birthdate: null,
      age: null,
      ageUnit: null,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [firstName, lastName, patientId, birthdate, age, ageUnit];
}
