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

  NewPatientForm copyWith({
    String? patientId,
    String? firstName,
    String? lastName,
    DateTime? birthdate,
    int? age,
  }) {
    return NewPatientForm(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      patientId: patientId ?? this.patientId,
      birthdate: birthdate ?? this.birthdate,
      age: age ?? this.age,
    );
  }
}
