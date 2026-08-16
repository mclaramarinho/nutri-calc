part of 'new_patient_state.dart';

enum PatientPropertiesToEdit<T> {
  firstName<String>(),
  lastName<String>(),
  patientId<String>(),
  birthdate<DateTime>(),
  age<int>(),
  ageUnit<TimeUnit>();

  const PatientPropertiesToEdit();

  Type get type => T;
}

@injectable
class NewPatientCubit extends Cubit<NewPatientState> {
  NewPatientCubit({required this._createPatientUseCase})
    : super(NewPatientStateInitial());

  final CreatePatientUseCase _createPatientUseCase;

  NewPatientFormEntity? _cachedForm;
  TextEditingController ageInputController = TextEditingController();

  void closedErrorModal() {
    emit(NewPatientStateInitial(form: _cachedForm));
  }

  Future<void> onSubmit() async {
    if (state is NewPatientStateInitial) {
      final currentState = state as NewPatientStateInitial;
      final form = currentState.form;

      emit(currentState.copyWith(isSaving: true));

      if (form == null) {
        emit(NewPatientStateError(message: "O form não foi preenchido."));
        return;
      }

      if (form.firstName.isEmpty || form.lastName.isEmpty) {
        emit(
          NewPatientStateError(
            message: "Você precisa preencher o primeiro e segundo nome.",
          ),
        );
        return;
      }

      if (form.age != null && form.age! < 0) {
        emit(NewPatientStateError(message: "Idade inválida."));
        return;
      }

      if (form.age != null && form.ageUnit == null) {
        emit(NewPatientStateError(message: "Selecione a unidade da idade."));
        return;
      }

      if (form.birthdate != null && form.birthdate!.isAfter(DateTime.now())) {
        emit(
          NewPatientStateError(
            message: "A data de nascimento precisa ser menor que a de agora.",
          ),
        );
        return;
      }

      final createRes = await _createPatientUseCase.call(formData: form);
      emit(currentState.copyWith(isSaving: false));

      if (createRes.isError) {
        emit(NewPatientStateError(message: "Erro na criação do paciente."));
      } else {
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
    final currentState = state as NewPatientStateInitial;
    final currentForm =
        currentState.form ?? NewPatientFormEntity(firstName: "", lastName: "");

    NewPatientFormEntity newForm = currentForm;

    if (value == null) {
      if (prop == .birthdate) {
        newForm = newForm.clearAge();
        ageInputController.text = "";
        emit(currentState.copyWith(disableAgeInput: false, form: newForm));
      }

      return;
    }

    if (value.runtimeType != prop.type) {
      throw ArgumentError("Expected value to be of type ${prop.type}");
    }

    bool disableAgeInput = currentState.disableAgeInput;

    switch (prop) {
      case .age:
        newForm = newForm.copyWith(age: value);
        ageInputController.text = newForm.age.toString();
        break;
      case .birthdate:
        final AgeEntity age = (value as DateTime).getAge();
        newForm = newForm.copyWith(age: age.value, ageUnit: age.unit);
        ageInputController.text = newForm.age.toString();
        disableAgeInput = true;
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
      case .ageUnit:
        newForm = newForm.copyWith(ageUnit: value);
        break;
    }
    emit(
      NewPatientStateInitial(form: newForm, disableAgeInput: disableAgeInput),
    );
    _cachedForm = newForm;
  }
}
