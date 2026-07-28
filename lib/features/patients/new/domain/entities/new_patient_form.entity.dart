class NewPatientForm {
  /// Identifier from healthcare provider
  final String? patientId;

  // General
  final String firstName;
  final String lastName;
  final DateTime? birthdate;
  final int? age;

  const NewPatientForm({
    required this.firstName,
    required this.lastName,
    this.patientId,
    this.birthdate,
    this.age,
  });
}