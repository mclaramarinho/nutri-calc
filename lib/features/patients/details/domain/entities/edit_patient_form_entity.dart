import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

class EditPatientFormEntity {
  final String? patientId;
  final String firstName;
  final String lastName;
  final DateTime? birthdate;
  final int? age;
  final TimeUnit? ageUnit;
  final String patientLocalId;
  final bool enteralNutrition;
  final bool parenteralNutrition;
  final bool hospitalized;
  final bool confinedToBed;

  const EditPatientFormEntity({
    required this.firstName,
    required this.lastName,
    required this.patientLocalId,
    this.patientId,
    this.birthdate,
    this.age,
    this.ageUnit,
    this.enteralNutrition = false,
    this.parenteralNutrition = false,
    this.hospitalized = false,
    this.confinedToBed = false,
  });

  EditPatientFormEntity copyWith({
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
  }) => EditPatientFormEntity(
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    patientLocalId: patientLocalId,
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
