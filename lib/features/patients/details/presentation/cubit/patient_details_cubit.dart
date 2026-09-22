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
    required this._saveBmiCalculationUseCase,
    required this._saveEnergyExpenditureCalculationUseCase,
  }) : super(PatientDetailsStateInitial());

  final LoadPatientDetailsUseCase _loadPatientDetailsUseCase;
  final UpdatePatientUseCase _updatePatientUseCase;

  final CreateWeightUseCase _createWeightUseCase;
  final GetWeightsUseCase _getWeightsUseCase;

  final CreateHeightUseCase _createHeightUseCase;
  final GetHeightsUseCase _getHeightsUseCase;

  final CreateBodyMeasurementUseCase _createBodyMeasurementUseCase;
  final GetBodyMeasurementUseCase _getBodyMeasurementUseCase;

  final SaveBmiCalculationUseCase _saveBmiCalculationUseCase;
  final SaveEnergyExpenditureCalculationUseCase
  _saveEnergyExpenditureCalculationUseCase;

  // INITIALIZER ===========================================================
  Future<void> init(String patientId) async {
    final result = await Future.wait([
      _loadPatientDetailsUseCase(patientId),
      _getWeightsUseCase(patientId),
      _getHeightsUseCase(patientId),
      _getBodyMeasurementUseCase(patientId),
    ]);
    if (result[0] is Error) {
      emit(
        PatientDetailsStateError(
          message: "Erro ao carregar dados do paciente.",
        ),
      );
      return;
    }

    final weights =
        result[1].getOrElse(() => <WeightEntity>[]) as List<WeightEntity>;
    final heights =
        result[2].getOrElse(() => <HeightEntity>[]) as List<HeightEntity>;
    final measurements =
        result[3].getOrElse(() => <BodyMeasurementEntity>[])
            as List<BodyMeasurementEntity>;

    final form = (result[0] as Ok<EditPatientFormEntity, String>).value;

    emit(
      PatientDetailsStateLoaded(
        form: form,
        weights: weights,
        heights: heights,
        measurements: measurements.reversed.toList(),
        bmi: _computeBmi(weights, heights, form.age),
      ),
    );
  }

  Bmi? _computeBmi(
    List<WeightEntity> weights,
    List<HeightEntity> heights,
    int? age,
  ) {
    if (weights.isEmpty || heights.isEmpty) return null;

    final latestWeight = weights.first; // first = newest, per §0's fixed sort
    final latestHeight = heights.first;

    final res = CalculateBmi().call(
      weight: latestWeight.value,
      height: latestHeight.value / 100, // cm -> m
      age: age ?? 0,
    );

    return res.isOk ? (res as Ok<Bmi, String>).value : null;
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
      final form = current.form;

      if (form.age != null && form.age! < 0) {
        emit(
          current.copyWith(
            isEditing: true,
            isSaving: false,
            isSaveError: true,
            saveErrorMessage: "Idade inválida.",
          ),
        );
        return;
      }

      if (form.birthdate != null && form.birthdate!.isAfter(DateTime.now())) {
        emit(
          current.copyWith(
            isEditing: true,
            isSaving: false,
            isSaveError: true,
            saveErrorMessage:
                "A data de nascimento precisa ser menor que a de agora.",
          ),
        );
        return;
      }

      final res = await _updatePatientUseCase(form);

      await _handleSaveResult(current, res);
    });
  }

  void closedErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        PatientDetailsStateLoaded(
          form: current.form,
          isEditing: current.isEditing,
          isSaving: current.isSaving,
          isSaved: current.isSaved,
          isSaveError: false,
          saveErrorMessage: null,
          bmi: current.bmi,
          isSavingWeight: current.isSavingWeight,
          weights: current.weights,
          newWeight: current.newWeight,
          isSavingHeight: current.isSavingHeight,
          heights: current.heights,
          newHeight: current.newHeight,
          newBodyMeasurementType: current.newBodyMeasurementType,
          newBodyMeasurementValue: current.newBodyMeasurementValue,
          isSavingNewBodyMeasurement: current.isSavingNewBodyMeasurement,
          measurements: current.measurements,
          isSavingBmi: current.isSavingBmi,
          isBmiSaveError: current.isBmiSaveError,
          bmiSaveErrorMessage: current.bmiSaveErrorMessage,
          isBmiSaved: current.isBmiSaved,
        ),
      );
    });
  }

  void closedBmiErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        PatientDetailsStateLoaded(
          form: current.form,
          isEditing: current.isEditing,
          isSaving: current.isSaving,
          isSaved: current.isSaved,
          isSaveError: current.isSaveError,
          saveErrorMessage: current.saveErrorMessage,
          bmi: current.bmi,
          isSavingWeight: current.isSavingWeight,
          weights: current.weights,
          newWeight: current.newWeight,
          isSavingHeight: current.isSavingHeight,
          heights: current.heights,
          newHeight: current.newHeight,
          newBodyMeasurementType: current.newBodyMeasurementType,
          newBodyMeasurementValue: current.newBodyMeasurementValue,
          isSavingNewBodyMeasurement: current.isSavingNewBodyMeasurement,
          measurements: current.measurements,
          isSavingBmi: current.isSavingBmi,
          isBmiSaveError: false,
          bmiSaveErrorMessage: null,
          isBmiSaved: current.isBmiSaved,
          isSavingEnergyExpenditure: current.isSavingEnergyExpenditure,
          isEnergyExpenditureSaveError: current.isEnergyExpenditureSaveError,
          energyExpenditureSaveErrorMessage:
              current.energyExpenditureSaveErrorMessage,
          isEnergyExpenditureSaved: current.isEnergyExpenditureSaved,
        ),
      );
    });
  }

  void closedEnergyExpenditureErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        PatientDetailsStateLoaded(
          form: current.form,
          isEditing: current.isEditing,
          isSaving: current.isSaving,
          isSaved: current.isSaved,
          isSaveError: current.isSaveError,
          saveErrorMessage: current.saveErrorMessage,
          bmi: current.bmi,
          isSavingWeight: current.isSavingWeight,
          weights: current.weights,
          newWeight: current.newWeight,
          isSavingHeight: current.isSavingHeight,
          heights: current.heights,
          newHeight: current.newHeight,
          newBodyMeasurementType: current.newBodyMeasurementType,
          newBodyMeasurementValue: current.newBodyMeasurementValue,
          isSavingNewBodyMeasurement: current.isSavingNewBodyMeasurement,
          measurements: current.measurements,
          isSavingBmi: current.isSavingBmi,
          isBmiSaveError: current.isBmiSaveError,
          bmiSaveErrorMessage: current.bmiSaveErrorMessage,
          isBmiSaved: current.isBmiSaved,
          isSavingEnergyExpenditure: current.isSavingEnergyExpenditure,
          isEnergyExpenditureSaveError: false,
          energyExpenditureSaveErrorMessage: null,
          isEnergyExpenditureSaved: current.isEnergyExpenditureSaved,
        ),
      );
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

  void updateEnteralNutrition(bool value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(enteralNutrition: value)));
    });
  }

  void updateParenteralNutrition(bool value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(parenteralNutrition: value)));
    });
  }

  void updateHospitalized(bool value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(hospitalized: value)));
    });
  }

  void updateConfinedToBed(bool value) {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(form: current.form.copyWith(confinedToBed: value)));
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
    _executeOnStateLoaded((current) async {
      if (current.newWeight == null) return;

      emit(current.copyWith(isSavingWeight: true));

      final res = await _createWeightUseCase(
        weight: WeightEntity(
          createdAt: DateTime.now(),
          value: current.newWeight!,
          patientId: current.form.patientLocalId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingWeight: false,
            isSaveError: true,
            saveErrorMessage: "Não foi possível salvar o peso. Tente novamente.",
          ),
        );
        return;
      }

      final weightsRes = await _getWeightsUseCase(
        current.form.patientLocalId,
      );
      final weights = weightsRes.getOrElse(() => current.weights);

      emit(
        current
            .copyWith(
              isSavingWeight: false,
              isSaveError: false,
              weights: weights,
              bmi: _computeBmi(weights, current.heights, current.form.age),
            )
            .clearForm(.weights),
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
    _executeOnStateLoaded((current) async {
      if (current.newHeight == null) return;

      emit(current.copyWith(isSavingHeight: true));

      final res = await _createHeightUseCase(
        height: HeightEntity(
          createdAt: DateTime.now(),
          value: current.newHeight!,
          patientId: current.form.patientLocalId,
        ),
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingHeight: false,
            isSaveError: true,
            saveErrorMessage:
                "Não foi possível salvar a altura. Tente novamente.",
          ),
        );
        return;
      }

      final heightsRes = await _getHeightsUseCase(
        current.form.patientLocalId,
      );
      final heights = heightsRes.getOrElse(() => current.heights);

      emit(
        current
            .copyWith(
              isSavingHeight: false,
              isSaveError: false,
              heights: heights,
              bmi: _computeBmi(current.weights, heights, current.form.age),
            )
            .clearForm(.heights),
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
      if (value is double) {
        // update the measurement value
        emit(current.copyWith(newBodyMeasurementValue: value));
      } else if (value is String) {
        // try to parse to double and update the measurement value
        final parsedDouble = double.tryParse(value);

        if (parsedDouble != null) {
          emit(current.copyWith(newBodyMeasurementValue: parsedDouble));
        } else {
          // if not parseable, update the measurement type
          try {
            emit(
              current.copyWith(
                newBodyMeasurementType: BodyMeasurementTypeEnum.fromJson(value),
              ),
            );
          } on UnsupportedError catch (ue) {
            print("[PatientDetailsCubit] - $ue");
            return;
          }
        }
      }
    });
  }

  Future<void> saveNewBodyMeasurement() async {
    _executeOnStateLoaded((current) async {
      if (current.newBodyMeasurementValue == null ||
          current.newBodyMeasurementType == null) {
        return;
      }

      if (current.newBodyMeasurementValue! <= 0) return;

      emit(current.copyWith(isSavingNewBodyMeasurement: true));

      final res = await _createBodyMeasurementUseCase(
        BodyMeasurementEntity(
          createdAt: DateTime.now(),
          patientId: current.form.patientLocalId,
          value: current.newBodyMeasurementValue!,
          measurementType: current.newBodyMeasurementType!,
        ),
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingNewBodyMeasurement: false,
            isSaveError: true,
            saveErrorMessage:
                "Não foi possível salvar a medida. Tente novamente.",
          ),
        );
        return;
      }

      final measurementsRes = await _getBodyMeasurementUseCase(
        current.form.patientLocalId,
      );
      final measurements = measurementsRes.isOk
          ? measurementsRes
                .getOrElse(() => <BodyMeasurementEntity>[])
                .reversed
                .toList()
          : current.measurements;

      emit(
        current
            .copyWith(
              isSavingNewBodyMeasurement: false,
              isSaveError: false,
              measurements: measurements,
            )
            .clearForm(.bodyMeasurements),
      );
    });
  }

  // CALCULATORS TAB ========================================================
  Future<void> saveBmiCalculation() async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty || current.heights.isEmpty) return;

      emit(current.copyWith(isSavingBmi: true));

      final latestWeight = current.weights.first; // newest, per §0's sort
      final latestHeight = current.heights.first;

      final res = await _saveBmiCalculationUseCase(
        patientId: current.form.patientLocalId,
        weightKg: latestWeight.value,
        heightM: latestHeight.value / 100, // cm -> m
        age: current.form.age ?? 0,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingBmi: false,
            isBmiSaveError: true,
            bmiSaveErrorMessage:
                "Não foi possível salvar o cálculo de IMC. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingBmi: false,
          isBmiSaveError: false,
          isBmiSaved: true,
        ),
      );
      // Mirrors `_handleSaveResult`'s reset-after-delay: without resetting
      // `isBmiSaved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isBmiSaved: false));
      });
    });
  }

  Future<void> saveEnergyExpenditureCalculation({
    required EnergyExpenditureFormulaEnum formula,
    Gender? gender,
    ActivityFactor? activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
    StressLevel stressLevel = StressLevel.noStress,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty) return;

      emit(current.copyWith(isSavingEnergyExpenditure: true));

      final latestWeight = current.weights.first; // newest, per §0's sort
      final latestHeight = current.heights.isNotEmpty
          ? current.heights.first
          : null;

      final res = await _saveEnergyExpenditureCalculationUseCase(
        patientId: current.form.patientLocalId,
        formula: formula,
        weightKg: latestWeight.value,
        heightCm: latestHeight?.value,
        age: current.form.age,
        gender: gender,
        activityFactor: activityFactor,
        injuryFactor: injuryFactor,
        temperatureFactor: temperatureFactor,
        stressLevel: stressLevel,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingEnergyExpenditure: false,
            isEnergyExpenditureSaveError: true,
            energyExpenditureSaveErrorMessage:
                "Não foi possível salvar o cálculo de gasto energético. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingEnergyExpenditure: false,
          isEnergyExpenditureSaveError: false,
          isEnergyExpenditureSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isEnergyExpenditureSaved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isEnergyExpenditureSaved: false));
      });
    });
  }

  // PRIVATE METHODS =======================================================
  Future<void> _handleSaveResult(
    PatientDetailsStateLoaded current,
    Result<void, String> result,
  ) async {
    if (result.isError) {
      emit(
        current.copyWith(
          isEditing: true,
          isSaving: false,
          isSaveError: true,
          saveErrorMessage:
              "Não foi possível salvar as alterações. Tente novamente.",
        ),
      );
      return;
    }

    emit(
      current.copyWith(
        isEditing: false,
        isSaved: true,
        isSaving: false,
        isSaveError: false,
      ),
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
