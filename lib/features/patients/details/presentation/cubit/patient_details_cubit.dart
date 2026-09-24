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
    required this._saveNitrogenBalanceCalculationUseCase,
    required this._saveProteinNeedsCalculationUseCase,
    required this._saveWaterNeedsCalculationUseCase,
    required this._saveEnteralNutritionDrippingCalculationUseCase,
    required this._saveEnteralNutritionSpeedCalculationUseCase,
    required this._saveEnteralNutritionVolumeCalculationUseCase,
    required this._saveGlucoseInfusionRateCalculationUseCase,
    required this._saveWeightLossClassificationCalculationUseCase,
    required this._saveMustCalculationUseCase,
    required this._saveNrs2002CalculationUseCase,
    required this._saveStrongKidsCalculationUseCase,
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
  final SaveNitrogenBalanceCalculationUseCase
  _saveNitrogenBalanceCalculationUseCase;
  final SaveProteinNeedsCalculationUseCase _saveProteinNeedsCalculationUseCase;
  final SaveWaterNeedsCalculationUseCase _saveWaterNeedsCalculationUseCase;
  final SaveEnteralNutritionDrippingCalculationUseCase
  _saveEnteralNutritionDrippingCalculationUseCase;
  final SaveEnteralNutritionSpeedCalculationUseCase
  _saveEnteralNutritionSpeedCalculationUseCase;
  final SaveEnteralNutritionVolumeCalculationUseCase
  _saveEnteralNutritionVolumeCalculationUseCase;
  final SaveGlucoseInfusionRateCalculationUseCase
  _saveGlucoseInfusionRateCalculationUseCase;
  final SaveWeightLossClassificationCalculationUseCase
  _saveWeightLossClassificationCalculationUseCase;
  final SaveMustCalculationUseCase _saveMustCalculationUseCase;
  final SaveNrs2002CalculationUseCase _saveNrs2002CalculationUseCase;
  final SaveStrongKidsCalculationUseCase _saveStrongKidsCalculationUseCase;

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
      emit(current.copyWith(isSaveError: false, saveErrorMessage: null));
    });
  }

  void closedBmiErrorModal() {
    _executeOnStateLoaded((current) {
      emit(current.copyWith(isBmiSaveError: false, bmiSaveErrorMessage: null));
    });
  }

  void closedEnergyExpenditureErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isEnergyExpenditureSaveError: false,
          energyExpenditureSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedNitrogenBalanceErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isNitrogenBalanceSaveError: false,
          nitrogenBalanceSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedProteinNeedsErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isProteinNeedsSaveError: false,
          proteinNeedsSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedWaterNeedsErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isWaterNeedsSaveError: false,
          waterNeedsSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedEnteralNutritionDrippingErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isEnteralNutritionDrippingSaveError: false,
          enteralNutritionDrippingSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedEnteralNutritionSpeedErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isEnteralNutritionSpeedSaveError: false,
          enteralNutritionSpeedSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedEnteralNutritionVolumeErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isEnteralNutritionVolumeSaveError: false,
          enteralNutritionVolumeSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedGlucoseInfusionRateErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isGlucoseInfusionRateSaveError: false,
          glucoseInfusionRateSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedWeightLossClassificationErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isWeightLossClassificationSaveError: false,
          weightLossClassificationSaveErrorMessage: null,
        ),
      );
    });
  }

  void closedMustErrorModal() {
    _executeOnStateLoaded((current) {
      emit(current.copyWith(isMustSaveError: false, mustSaveErrorMessage: null));
    });
  }

  void closedNrs2002ErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(isNrs2002SaveError: false, nrs2002SaveErrorMessage: null),
      );
    });
  }

  void closedStrongKidsErrorModal() {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWith(
          isStrongKidsSaveError: false,
          strongKidsSaveErrorMessage: null,
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

  Future<void> saveNitrogenBalanceCalculation({
    required double ingestedProtein,
    required double urineNitrogen24h,
  }) async {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(isSavingNitrogenBalance: true));

      final res = await _saveNitrogenBalanceCalculationUseCase(
        patientId: current.form.patientLocalId,
        ingestedProtein: ingestedProtein,
        urineNitrogen24h: urineNitrogen24h,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingNitrogenBalance: false,
            isNitrogenBalanceSaveError: true,
            nitrogenBalanceSaveErrorMessage:
                "Não foi possível salvar o balanço nitrogenado. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingNitrogenBalance: false,
          isNitrogenBalanceSaveError: false,
          isNitrogenBalanceSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isNitrogenBalanceSaved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isNitrogenBalanceSaved: false));
      });
    });
  }

  Future<void> saveProteinNeedsCalculation({
    required PatientState patientState,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty) return;

      emit(current.copyWith(isSavingProteinNeeds: true));

      final latestWeight = current.weights.first; // newest, per §0's sort

      final res = await _saveProteinNeedsCalculationUseCase(
        patientId: current.form.patientLocalId,
        weightKg: latestWeight.value,
        patientState: patientState,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingProteinNeeds: false,
            isProteinNeedsSaveError: true,
            proteinNeedsSaveErrorMessage:
                "Não foi possível salvar o cálculo de necessidade proteica. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingProteinNeeds: false,
          isProteinNeedsSaveError: false,
          isProteinNeedsSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isProteinNeedsSaved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isProteinNeedsSaved: false));
      });
    });
  }

  Future<void> saveWaterNeedsCalculation() async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty || current.form.age == null) return;

      emit(current.copyWith(isSavingWaterNeeds: true));

      final latestWeight = current.weights.first; // newest, per §0's sort

      final res = await _saveWaterNeedsCalculationUseCase(
        patientId: current.form.patientLocalId,
        weightKg: latestWeight.value,
        age: current.form.age!,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingWaterNeeds: false,
            isWaterNeedsSaveError: true,
            waterNeedsSaveErrorMessage:
                "Não foi possível salvar o cálculo de necessidade hídrica. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingWaterNeeds: false,
          isWaterNeedsSaveError: false,
          isWaterNeedsSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isWaterNeedsSaved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isWaterNeedsSaved: false));
      });
    });
  }

  Future<void> saveEnteralNutritionDrippingCalculation({
    required double totalVolume,
    required double totalHoursForVolume,
  }) async {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(isSavingEnteralNutritionDripping: true));

      final res = await _saveEnteralNutritionDrippingCalculationUseCase(
        patientId: current.form.patientLocalId,
        totalVolume: totalVolume,
        totalHoursForVolume: totalHoursForVolume,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingEnteralNutritionDripping: false,
            isEnteralNutritionDrippingSaveError: true,
            enteralNutritionDrippingSaveErrorMessage:
                "Não foi possível salvar o cálculo de gotejamento. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingEnteralNutritionDripping: false,
          isEnteralNutritionDrippingSaveError: false,
          isEnteralNutritionDrippingSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isEnteralNutritionDrippingSaved` back to `false`, the page's
      // `listenWhen` previous-vs-current true-transition check would never
      // fire again for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isEnteralNutritionDrippingSaved: false));
      });
    });
  }

  Future<void> saveEnteralNutritionSpeedCalculation({
    required double totalDailyVolume,
  }) async {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(isSavingEnteralNutritionSpeed: true));

      final res = await _saveEnteralNutritionSpeedCalculationUseCase(
        patientId: current.form.patientLocalId,
        totalDailyVolume: totalDailyVolume,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingEnteralNutritionSpeed: false,
            isEnteralNutritionSpeedSaveError: true,
            enteralNutritionSpeedSaveErrorMessage:
                "Não foi possível salvar o cálculo de velocidade de infusão. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingEnteralNutritionSpeed: false,
          isEnteralNutritionSpeedSaveError: false,
          isEnteralNutritionSpeedSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isEnteralNutritionSpeedSaved` back to `false`, the page's
      // `listenWhen` previous-vs-current true-transition check would never
      // fire again for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isEnteralNutritionSpeedSaved: false));
      });
    });
  }

  Future<void> saveEnteralNutritionVolumeCalculation({
    required double totalDailyEnergy,
    required double caloricDensityOfDiet,
  }) async {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(isSavingEnteralNutritionVolume: true));

      final res = await _saveEnteralNutritionVolumeCalculationUseCase(
        patientId: current.form.patientLocalId,
        totalDailyEnergy: totalDailyEnergy,
        caloricDensityOfDiet: caloricDensityOfDiet,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingEnteralNutritionVolume: false,
            isEnteralNutritionVolumeSaveError: true,
            enteralNutritionVolumeSaveErrorMessage:
                "Não foi possível salvar o cálculo de volume total. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingEnteralNutritionVolume: false,
          isEnteralNutritionVolumeSaveError: false,
          isEnteralNutritionVolumeSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isEnteralNutritionVolumeSaved` back to `false`, the page's
      // `listenWhen` previous-vs-current true-transition check would never
      // fire again for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isEnteralNutritionVolumeSaved: false));
      });
    });
  }

  Future<void> saveGlucoseInfusionRateCalculation({
    required double totalGlucose,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty) return;

      emit(current.copyWith(isSavingGlucoseInfusionRate: true));

      final latestWeight = current.weights.first; // newest, per §0's sort

      final res = await _saveGlucoseInfusionRateCalculationUseCase(
        patientId: current.form.patientLocalId,
        weightKg: latestWeight.value,
        totalGlucose: totalGlucose,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingGlucoseInfusionRate: false,
            isGlucoseInfusionRateSaveError: true,
            glucoseInfusionRateSaveErrorMessage:
                "Não foi possível salvar o cálculo de TIG. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingGlucoseInfusionRate: false,
          isGlucoseInfusionRateSaveError: false,
          isGlucoseInfusionRateSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isGlucoseInfusionRateSaved` back to `false`, the page's
      // `listenWhen` previous-vs-current true-transition check would never
      // fire again for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isGlucoseInfusionRateSaved: false));
      });
    });
  }

  Future<void> saveWeightLossClassificationCalculation() async {
    _executeOnStateLoaded((current) async {
      if (current.weights.length < 2) return;

      emit(current.copyWith(isSavingWeightLossClassification: true));

      final currentWeight = current.weights[0]; // newest, per §0's sort
      final lastWeight = current.weights[1];

      final res = await _saveWeightLossClassificationCalculationUseCase(
        patientId: current.form.patientLocalId,
        currentWeight: currentWeight.value,
        currentWeightDate: currentWeight.createdAt,
        lastWeight: lastWeight.value,
        lastWeightDate: lastWeight.createdAt,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingWeightLossClassification: false,
            isWeightLossClassificationSaveError: true,
            weightLossClassificationSaveErrorMessage:
                "Não foi possível salvar a classificação de perda de peso. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingWeightLossClassification: false,
          isWeightLossClassificationSaveError: false,
          isWeightLossClassificationSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isWeightLossClassificationSaved` back to `false`, the page's
      // `listenWhen` previous-vs-current true-transition check would never
      // fire again for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isWeightLossClassificationSaved: false));
      });
    });
  }

  Future<void> saveMustCalculation({
    required double bmi,
    required double avgWeightLossIn3To6Months,
    required bool severeIllnessPresent,
    required bool reducedFoodIntakeForMoreThan5Days,
    required bool willReduceFoodIntakeForMoreThan5Days,
  }) async {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(isSavingMust: true));

      final res = await _saveMustCalculationUseCase(
        patientId: current.form.patientLocalId,
        bmi: bmi,
        avgWeightLossIn3To6Months: avgWeightLossIn3To6Months,
        severeIllnessPresent: severeIllnessPresent,
        reducedFoodIntakeForMoreThan5Days: reducedFoodIntakeForMoreThan5Days,
        willReduceFoodIntakeForMoreThan5Days:
            willReduceFoodIntakeForMoreThan5Days,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingMust: false,
            isMustSaveError: true,
            mustSaveErrorMessage:
                "Não foi possível salvar a triagem MUST. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(isSavingMust: false, isMustSaveError: false, isMustSaved: true),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isMustSaved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isMustSaved: false));
      });
    });
  }

  Future<void> saveNrs2002Calculation({
    required bool isSeverelyIll,
    required bool weightLossLast3Months,
    required bool reducedFoodIntakeLastWeek,
    required bool lowBmi,
    required Nrs2002Step2Classification nutritionalStatusClassification,
    required Nrs2002Step2Classification illnessSeverityClassification,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.form.age == null) return;

      emit(current.copyWith(isSavingNrs2002: true));

      final res = await _saveNrs2002CalculationUseCase(
        patientId: current.form.patientLocalId,
        age: current.form.age!,
        isSeverelyIll: isSeverelyIll,
        weightLossLast3Months: weightLossLast3Months,
        reducedFoodIntakeLastWeek: reducedFoodIntakeLastWeek,
        lowBmi: lowBmi,
        nutritionalStatusClassification: nutritionalStatusClassification,
        illnessSeverityClassification: illnessSeverityClassification,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingNrs2002: false,
            isNrs2002SaveError: true,
            nrs2002SaveErrorMessage:
                "Não foi possível salvar a triagem NRS-2002. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingNrs2002: false,
          isNrs2002SaveError: false,
          isNrs2002Saved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isNrs2002Saved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isNrs2002Saved: false));
      });
    });
  }

  Future<void> saveStrongKidsCalculation({
    required bool clinicalAppearanceOfMalnutrition,
    required bool highRiskDiseasePresent,
    required bool reducedIntakeOrLosses,
    required bool weightLossOrGrowthDeficit,
  }) async {
    _executeOnStateLoaded((current) async {
      emit(current.copyWith(isSavingStrongKids: true));

      final res = await _saveStrongKidsCalculationUseCase(
        patientId: current.form.patientLocalId,
        clinicalAppearanceOfMalnutrition: clinicalAppearanceOfMalnutrition,
        highRiskDiseasePresent: highRiskDiseasePresent,
        reducedIntakeOrLosses: reducedIntakeOrLosses,
        weightLossOrGrowthDeficit: weightLossOrGrowthDeficit,
      );

      if (res.isError) {
        emit(
          current.copyWith(
            isSavingStrongKids: false,
            isStrongKidsSaveError: true,
            strongKidsSaveErrorMessage:
                "Não foi possível salvar a triagem STRONG-Kids. Tente novamente.",
          ),
        );
        return;
      }

      emit(
        current.copyWith(
          isSavingStrongKids: false,
          isStrongKidsSaveError: false,
          isStrongKidsSaved: true,
        ),
      );
      // Mirrors `saveBmiCalculation`'s reset-after-delay: without resetting
      // `isStrongKidsSaved` back to `false`, the page's `listenWhen`
      // previous-vs-current true-transition check would never fire again
      // for a subsequent successful calculation.
      await Future.delayed(Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWith(isStrongKidsSaved: false));
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
