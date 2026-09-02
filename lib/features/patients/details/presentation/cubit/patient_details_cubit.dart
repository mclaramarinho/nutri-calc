part of 'patient_details_state.dart';

@injectable
class PatientDetailsCubit extends Cubit<PatientDetailsState> {
  PatientDetailsCubit({
    required this._loadPatientDetailsUseCase,
    required this._updatePatientUseCase,
    required this._createWeightUseCase,
    required this._getWeightsUseCase,
    required this._createHeightUseCase,
    required this._getHeightsUseCase,
    required this._createBodyMeasurementUseCase,
    required this._getBodyMeasurementUseCase,
  }) : super(PatientDetailsStateInitial());

  final LoadPatientDetailsUseCase _loadPatientDetailsUseCase;
  final UpdatePatientUseCase _updatePatientUseCase;

  final CreateWeightUseCase _createWeightUseCase;
  final GetWeightsUseCase _getWeightsUseCase;

  final CreateHeightUseCase _createHeightUseCase;
  final GetHeightsUseCase _getHeightsUseCase;

  final CreateBodyMeasurementUseCase _createBodyMeasurementUseCase;
  final GetBodyMeasurementUseCase _getBodyMeasurementUseCase;

  // INITIALIZER ===========================================================
  Future<void> init(String patientId) async {
    final result = await Future.wait([
      _loadPatientDetailsUseCase(patientId),
      _getWeightsUseCase(patientId),
      _getHeightsUseCase(patientId),
      _getBodyMeasurementUseCase(patientId),
    ]);
    if (result is Error) {
      emit(
        PatientDetailsStateError(
          message: "Erro ao carregar dados do paciente.",
        ),
      );
      return;
    }

    emit(
      PatientDetailsStateLoaded(
        form: (result[0] as Ok).value,
        weights: (result[1] as Ok).value,
        heights: (result[2] as Ok).value,
        measurements: (result[3] as Ok).value,
      ),
    );
  }

  // EDIT PATIENT DATA =====================================================
  void toggleEditing() {
    _executeOnStateLoaded((current) {
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
    _executeOnStateLoaded((current) async {
      final res = await _updatePatientUseCase(current.form);

      await _handleSaveResult(current, res.isOk);
    });
  }

  void updateId(String? value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(patientId: value)));
    });
  }

  void updateFirstName(String? value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(firstName: value)));
    });
  }

  void updateLastName(String? value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(lastName: value)));
    });
  }

  void updateAge(String? value) {
    _executeOnStateLoaded((current) async {
      emit(
        current.copyWith(
          form: current.form.copyWith(age: int.tryParse(value ?? '')),
        ),
      );
    });
  }

  void updateAgeUnit(TimeUnit? value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(ageUnit: value)));
    });
  }

  void updateBirthdate(DateTime? value) {
    _executeOnStateLoaded((current) async {
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

  // WEIGHT TAB ============================================================
  void updateWeightValue(String? value) {
    if (value == null) return;
    _executeOnStateLoaded((current) {
      emit(current.copyWith(newWeight: double.tryParse(value)));
    });
  }

  Future<void> saveWeight() async {
    _executeOnStateLoaded((current) {
      if (current.newWeight == null) return;
      _createWeightUseCase(
        weight: WeightEntity(
          createdAt: DateTime.now(),
          value: current.newWeight!,
          patientId: current.form.patientLocalId,
        ),
      );
    });
  }

  // HEIGHT TAB ============================================================
  void updateHeightValue(String? value) {
    if (value == null) return;
    _executeOnStateLoaded((current) {
      emit(current.copyWith(newHeight: double.tryParse(value)));
    });
  }

  Future<void> saveHeight() async {
    _executeOnStateLoaded((current) {
      if (current.newHeight == null) return;
      _createHeightUseCase(
        height: HeightEntity(
          createdAt: DateTime.now(),
          value: current.newHeight!,
          patientId: current.form.patientLocalId,
        ),
      );
    });
  }

  // BODY MEASUREMENTS TAB =================================================
  void updateBodyMeasurementForm(dynamic value) {
    assert(
      value is double || value is String,
      "Expected double or String, got ${value.runtimeType}",
    );

    _executeOnStateLoaded((current) {
      var bodyMeasurementForm = current.newBodyMeasurement ??
          BodyMeasurementEntity(
            createdAt: DateTime.now(), // placeholder
            patientId: current.form.patientLocalId ,
            value: -9999, // placeholder
            measurementType: .armCircumference, // placeholder
          );

      if (value is double) {
        // update the measurement value
        bodyMeasurementForm = bodyMeasurementForm.copyWith(
          value: value,
        );
      } else if (value is String) {
        // try to parse to double and update the measurement value
        final parsedDouble = double.tryParse(value);

        if (parsedDouble != null) {
          bodyMeasurementForm = bodyMeasurementForm.copyWith(
            value: parsedDouble,
          );
        } else {
          // if not parseable, update the measurement type
          try {
            bodyMeasurementForm = bodyMeasurementForm.copyWith(
              measurementType: BodyMeasurementTypeEnum.fromJson(value),
            );
          } on UnsupportedError catch (ue) {
            print("[PatientDetailsCubit] - $ue");
            return;
          }
        }
      }

      emit(current.copyWith(newBodyMeasurement: bodyMeasurementForm));
    });
  }

  // TODO - nao ta salvando ainda (erro)
  Future<void> saveNewBodyMeasurement() async {
    _executeOnStateLoaded((current) async {
      final measurementForm = current.newBodyMeasurement;
      if (measurementForm == null) return;

      if (measurementForm.value == -9999) return;

      final res = await _createBodyMeasurementUseCase(measurementForm);

      if (res is Ok) {
        emit(current.clearForm(.bodyMeasurements));
      } else {
        print("Error saving body measurement");
        return;
      }
    });
  }

  // PRIVATE METHODS =======================================================
  Future<void> _handleSaveResult(
    PatientDetailsStateLoaded current,
    bool isSuccess,
  ) async {
    emit(
      current.copyWith(isEditing: false, isSaved: isSuccess, isSaving: false),
    );
    await Future.delayed(Duration(seconds: 2));
    emit(current.copyWith(isEditing: false, isSaved: false, isSaving: false));
  }

  void _executeOnStateLoaded(
    void Function(PatientDetailsStateLoaded currentState) callback,
  ) {
    if (state is PatientDetailsStateLoaded) {
      callback(state as PatientDetailsStateLoaded);
    }
  }

  // TODO - register measurements
  // circumferences
}
