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
  final bool enteralNutrition;
  final bool parenteralNutrition;
  final bool hospitalized;
  final bool confinedToBed;

  const NewPatientFormEntity({
    required this.firstName,
    required this.lastName,
    this.patientId,
    this.birthdate,
    this.age,
    this.ageUnit,
    this.enteralNutrition = false,
    this.parenteralNutrition = false,
    this.hospitalized = false,
    this.confinedToBed = false,
  });

  NewPatientFormEntity copyWith({
    String? patientId,
    String? firstName,
    String? lastName,
    DateTime? birthdate,
    int? age,
    TimeUnit? ageUnit,
    bool? enteralNutrition,
    bool? parenteralNutrition,
    bool? hospitalized,
    bool? confinedToBed,
  }) {
    return NewPatientFormEntity(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      patientId: patientId ?? this.patientId,
      birthdate: birthdate ?? this.birthdate,
      age: age ?? this.age,
      ageUnit: ageUnit ?? this.ageUnit,
      enteralNutrition: enteralNutrition ?? this.enteralNutrition,
      parenteralNutrition: parenteralNutrition ?? this.parenteralNutrition,
      hospitalized: hospitalized ?? this.hospitalized,
      confinedToBed: confinedToBed ?? this.confinedToBed,
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
      enteralNutrition: enteralNutrition,
      parenteralNutrition: parenteralNutrition,
      hospitalized: hospitalized,
      confinedToBed: confinedToBed,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    patientId,
    birthdate,
    age,
    ageUnit,
    enteralNutrition,
    parenteralNutrition,
    hospitalized,
    confinedToBed,
  ];
}
