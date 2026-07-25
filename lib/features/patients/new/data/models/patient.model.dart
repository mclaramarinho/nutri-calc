import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
part 'patient.model.g.dart';

@JsonSerializable()
class Patient {
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

  const Patient({
    this.id,
    required this.firstName,
    required this.lastName,
    this.patientId,
    this.birthdate,
    this.age,
  });

  // Wire up the generated `toJson` in `example.g.dart`.
  Map<String, dynamic> toJson() => _$PatientToJson(this);

  // Wire up the generated `fromJson` in `example.g.dart`.
  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  Patient copyWithId() {
    return Patient(
      id: Uuid().v4(),
      firstName: firstName,
      lastName: lastName,
      patientId: patientId,
      birthdate: birthdate,
      age: age,
    );
  }
}
