import 'package:json_annotation/json_annotation.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';
import 'package:uuid/uuid.dart';
part 'patient_model.g.dart';

@JsonSerializable()
class PatientModel {
  // Identifiers
  /// Database id
  final String? id;

  /// Identifier from healthcare provider
  final String? patientId;

  // General
  final String firstName;
  final String lastName;
  final DateTime? birthdate;
  final int? age;
  final TimeUnit? ageUnit;

  // Clinical flags
  @JsonKey(toJson: _boolToInt, fromJson: _intToBool)
  final bool enteralNutrition;
  @JsonKey(toJson: _boolToInt, fromJson: _intToBool)
  final bool parenteralNutrition;
  @JsonKey(toJson: _boolToInt, fromJson: _intToBool)
  final bool hospitalized;
  @JsonKey(toJson: _boolToInt, fromJson: _intToBool)
  final bool confinedToBed;

  const PatientModel({
    this.id,
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

  static int _boolToInt(bool value) => value ? 1 : 0;
  static bool _intToBool(dynamic value) => value == 1 || value == true;

  // Wire up the generated `toJson` in `example.g.dart`.
  Map<String, dynamic> toJson() => _$PatientModelToJson(this);

  // Wire up the generated `fromJson` in `example.g.dart`.
  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);

  PatientModel copyWithId() {
    return PatientModel(
      id: Uuid().v4(),
      firstName: firstName,
      lastName: lastName,
      patientId: patientId,
      birthdate: birthdate,
      age: age,
      ageUnit: ageUnit,
      enteralNutrition: enteralNutrition,
      parenteralNutrition: parenteralNutrition,
      hospitalized: hospitalized,
      confinedToBed: confinedToBed,
    );
  }
}
