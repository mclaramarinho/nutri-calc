part of './new_patient.state.dart';

enum PatientPropertiesToEdit<T> {
  firstName<String>(),
  lastName<String>(),
  patientId<String>(),
  birthdate<DateTime>(),
  age<int>();

  const PatientPropertiesToEdit();

  Type get type => T;
}

@injectable
class NewPatientCubit extends Cubit<NewPatientState> {
  NewPatientCubit({required this._createPatient})
    : super(NewPatientStateInitial());

  CreatePatient _createPatient;

  NewPatientForm? _cachedForm;

  void closedErrorModal() {
    emit(NewPatientStateInitial(form: _cachedForm));
  }

  Future<void> onSubmit() async {
    if (state is NewPatientStateInitial) {
      final currentState = state as NewPatientStateInitial;
      final form = currentState.form;

      emit(currentState.copyWith(isSaving: true));

      if (form == null) {
        // emit error
        emit(NewPatientStateError(message: "O form não foi preenchido."));
        return;
      }

      if (form.firstName.isEmpty || form.lastName.isEmpty) {
        // emit error
        emit(
          NewPatientStateError(
            message: "Você precisa preencher o primeiro e segundo nome.",
          ),
        );
        return;
      }

      if (form.age != null && form.age! < 0) {
        // emit error
        emit(NewPatientStateError(message: "Idade inválida."));
        return;
      }

      if (form.birthdate != null && form.birthdate!.isAfter(DateTime.now())) {
        // emit error
        emit(
          NewPatientStateError(
            message: "A data de nascimento precisa ser menor que a de agora.",
          ),
        );
        return;
      }

      final createRes = await _createPatient.call(formData: form);
      emit(currentState.copyWith(isSaving: false));

      if (createRes.isError) {
        // emit error
        emit(NewPatientStateError(message: "Erro na criação do paciente."));
      } else {
        // emit success
        emit(NewPatientStateSuccess());
      }
    }
  }

  void stopLoading() {
    emit(NewPatientStateInitial(form: _cachedForm, isSaving: false));
  }

  void setValue(PatientPropertiesToEdit prop, dynamic value) {
    if (state is! NewPatientStateInitial) {
      throw StateError("Expected current state to be $NewPatientStateInitial");
    }

    if (value == null) return;

    if (value.runtimeType != prop.type) {
      throw ArgumentError("Expected value to be of type ${prop.type}");
    }

    final currentState = state as NewPatientStateInitial;
    final currentForm =
        currentState.form ?? NewPatientForm(firstName: "", lastName: "");

    NewPatientForm newForm = currentForm;

    switch (prop) {
      case .age:
        newForm = newForm.copyWith(age: value);
        break;
      case .birthdate:
        newForm = newForm.copyWith(birthdate: value);
        break;
      case .firstName:
        newForm = newForm.copyWith(firstName: value);
        break;
      case .lastName:
        newForm = newForm.copyWith(lastName: value);
        break;
      case .patientId:
        newForm = newForm.copyWith(patientId: value);
        break;
    }
    emit(NewPatientStateInitial(form: newForm));
    _cachedForm = newForm;
  }
}
