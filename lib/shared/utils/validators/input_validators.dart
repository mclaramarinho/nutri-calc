class InputValidators {
  static String? patientId(String? value) {
    print(value?.length);
    if (value == null || value.isEmpty) return null;
    if (value.length > 250) {
      return "O ID do paciente so pode ter até 250 caracteres.";
    }
    return null;
  }
}
