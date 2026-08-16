part of 'patient_details_state.dart';

@injectable
class PatientDetailsCubit extends Cubit<PatientDetailsState> {
  PatientDetailsCubit({
    required this._loadPatientDetailsUseCase,
    required this._updatePatientUseCase,
  }) : super(PatientDetailsStateInitial());

  final LoadPatientDetailsUseCase _loadPatientDetailsUseCase;
  final UpdatePatientUseCase _updatePatientUseCase;

  Future<void> init(String patientId) async {
    final result = await _loadPatientDetailsUseCase(patientId);
    if (result is Error) {
      emit(
        PatientDetailsStateError(
          message: "Erro ao carregar dados do paciente.",
        ),
      );
      return;
    }

    emit(PatientDetailsStateLoaded(form: (result as Ok).value));
  }

  void toggleEditing() {
    executeOnStateLoaded((current) {
      final isEditing = current.isEditing;

      if (isEditing) {
        // save
        emit(
          current.copyWith(isEditing: false, isSaved: false, isSaving: true),
        );

        updatePatientData();
      } else {
        // start editing
        emit(
          current.copyWith(isEditing: true, isSaved: false, isSaving: false),
        );
      }
    });
  }

  Future<void> updatePatientData() async {
    executeOnStateLoaded((current) async {
      // TODO - Update Patient
      print({
        "age": current.form.age,
        "ageUnit": current.form.ageUnit,
        "birthdate": current.form.birthdate,
        "fName": current.form.firstName,
        "lName": current.form.lastName,
        "id": current.form.patientId,
      });
      final res = await _updatePatientUseCase(current.form);

      await handleSaveResult(current, res.isOk);
    });
  }

  void updateId(String? value) {
    executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(patientId: value)));
    });
  }

  void updateFirstName(String? value) {
    executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(firstName: value)));
    });
  }

  void updateLastName(String? value) {
    executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(lastName: value)));
    });
  }

  void updateAge(String? value) {
    executeOnStateLoaded((current) async {
      emit(
        current.copyWith(
          form: current.form.copyWith(age: int.tryParse(value ?? '')),
        ),
      );
    });
  }

  void updateAgeUnit(TimeUnit? value) {
    executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(ageUnit: value)));
    });
  }

  void updateBirthdate(DateTime? value) {
    executeOnStateLoaded((current) async {
      final AgeEntity age = (value as DateTime).getAge();
      emit(
        current.copyWith(
          form: current.form.copyWith(
            birthdate: value,
            age: age.value,
            ageUnit: age.unit,
          ),
        ),
      );
    });
  }

  Future<void> handleSaveResult(
    PatientDetailsStateLoaded current,
    bool isSuccess,
  ) async {
    emit(
      current.copyWith(isEditing: false, isSaved: isSuccess, isSaving: false),
    );
    await Future.delayed(Duration(seconds: 2));
    emit(current.copyWith(isEditing: false, isSaved: false, isSaving: false));
  }

  void executeOnStateLoaded(
    void Function(PatientDetailsStateLoaded currentState) callback,
  ) {
    if (state is PatientDetailsStateLoaded) {
      callback(state as PatientDetailsStateLoaded);
    }
  }

  // TODO - register measurements
  // weight, height, circumferences
}
