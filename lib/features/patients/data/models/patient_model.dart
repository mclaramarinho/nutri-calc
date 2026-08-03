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

  const PatientModel({
    this.id,
    required this.firstName,
    required this.lastName,
    this.patientId,
    this.birthdate,
    this.age,
    this.ageUnit,
  });

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
    );
  }
}
