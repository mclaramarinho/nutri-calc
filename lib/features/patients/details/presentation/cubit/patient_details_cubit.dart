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
    required this._saveIdealWeightCalculationUseCase,
    required this._saveAdequationCalculationUseCase,
    required this._saveAdjustedObesityCalculationUseCase,
    required this._saveAdjustedDryWeightCalculationUseCase,
    required this._saveEstimatedWeightCalculationUseCase,
    required this._getPatientCalculatorHistoryUseCase,
    required this._deleteCalculatorHistoryEntryUseCase,
    required this._deleteWeightUseCase,
    required this._deleteHeightUseCase,
    required this._deleteBodyMeasurementUseCase,
  }) : super(PatientDetailsStateInitial());

  final LoadPatientDetailsUseCase _loadPatientDetailsUseCase;
  final UpdatePatientUseCase _updatePatientUseCase;

  final GetPatientCalculatorHistoryUseCase _getPatientCalculatorHistoryUseCase;
  final DeleteCalculatorHistoryEntryUseCase _deleteCalculatorHistoryEntryUseCase;
  final DeleteWeightUseCase _deleteWeightUseCase;
  final DeleteHeightUseCase _deleteHeightUseCase;
  final DeleteBodyMeasurementUseCase _deleteBodyMeasurementUseCase;

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
  final SaveIdealWeightCalculationUseCase _saveIdealWeightCalculationUseCase;
  final SaveAdequationCalculationUseCase _saveAdequationCalculationUseCase;
  final SaveAdjustedObesityCalculationUseCase
  _saveAdjustedObesityCalculationUseCase;
  final SaveAdjustedDryWeightCalculationUseCase
  _saveAdjustedDryWeightCalculationUseCase;
  final SaveEstimatedWeightCalculationUseCase
  _saveEstimatedWeightCalculationUseCase;

  // INITIALIZER ===========================================================
  Future<void> init(String patientId) async {
    final result = await Future.wait([
      _loadPatientDetailsUseCase(patientId),
      _getWeightsUseCase(patientId),
      _getHeightsUseCase(patientId),
      _getBodyMeasurementUseCase(patientId),
      _getPatientCalculatorHistoryUseCase(patientId),
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
    final historyEntries =
        result[4].getOrElse(() => <HistoryEntryEntity>[])
            as List<HistoryEntryEntity>;

    final form = (result[0] as Ok<EditPatientFormEntity, String>).value;

    emit(
      PatientDetailsStateLoaded(
        form: form,
        weights: weights,
        heights: heights,
        measurements: measurements.reversed.toList(),
        historyEntries: historyEntries,
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

  void closedCalculatorErrorModal(String id) {
    _executeOnStateLoaded((current) {
      emit(
        current.copyWithCalculatorStatus(id, const CalculatorSaveStatusIdle()),
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

      final latestWeight = current.weights.first; // newest, per §0's sort
      final latestHeight = current.heights.first;

      await _saveCalculation(
        id: CalculatorIds.bmi,
        action: () => _saveBmiCalculationUseCase(
          patientId: current.form.patientLocalId,
          weightKg: latestWeight.value,
          heightM: latestHeight.value / 100, // cm -> m
          age: current.form.age ?? 0,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de IMC. Tente novamente.",
        successMessage: "Cálculo de IMC salvo com sucesso.",
      );
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

      final latestWeight = current.weights.first; // newest, per §0's sort
      final latestHeight = current.heights.isNotEmpty
          ? current.heights.first
          : null;

      await _saveCalculation(
        id: CalculatorIds.energyExpenditure,
        action: () => _saveEnergyExpenditureCalculationUseCase(
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
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de gasto energético. Tente novamente.",
        successMessage: "Cálculo de gasto energético salvo com sucesso.",
      );
    });
  }

  Future<void> saveNitrogenBalanceCalculation({
    required double ingestedProtein,
    required double urineNitrogen24h,
  }) async {
    _executeOnStateLoaded((current) async {
      await _saveCalculation(
        id: CalculatorIds.nitrogenBalance,
        action: () => _saveNitrogenBalanceCalculationUseCase(
          patientId: current.form.patientLocalId,
          ingestedProtein: ingestedProtein,
          urineNitrogen24h: urineNitrogen24h,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o balanço nitrogenado. Tente novamente.",
        successMessage: "Cálculo de balanço nitrogenado salvo com sucesso.",
      );
    });
  }

  Future<void> saveProteinNeedsCalculation({
    required PatientState patientState,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty) return;

      final latestWeight = current.weights.first; // newest, per §0's sort

      await _saveCalculation(
        id: CalculatorIds.proteinNeeds,
        action: () => _saveProteinNeedsCalculationUseCase(
          patientId: current.form.patientLocalId,
          weightKg: latestWeight.value,
          patientState: patientState,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de necessidade proteica. Tente novamente.",
        successMessage: "Cálculo de necessidade proteica salvo com sucesso.",
      );
    });
  }

  Future<void> saveWaterNeedsCalculation() async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty || current.form.age == null) return;

      final latestWeight = current.weights.first; // newest, per §0's sort

      await _saveCalculation(
        id: CalculatorIds.waterNeeds,
        action: () => _saveWaterNeedsCalculationUseCase(
          patientId: current.form.patientLocalId,
          weightKg: latestWeight.value,
          age: current.form.age!,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de necessidade hídrica. Tente novamente.",
        successMessage: "Cálculo de necessidade hídrica salvo com sucesso.",
      );
    });
  }

  Future<void> saveEnteralNutritionDrippingCalculation({
    required double totalVolume,
    required double totalHoursForVolume,
  }) async {
    _executeOnStateLoaded((current) async {
      await _saveCalculation(
        id: CalculatorIds.enteralNutritionDripping,
        action: () => _saveEnteralNutritionDrippingCalculationUseCase(
          patientId: current.form.patientLocalId,
          totalVolume: totalVolume,
          totalHoursForVolume: totalHoursForVolume,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de gotejamento. Tente novamente.",
        successMessage: "Cálculo de gotejamento salvo com sucesso.",
      );
    });
  }

  Future<void> saveEnteralNutritionSpeedCalculation({
    required double totalDailyVolume,
  }) async {
    _executeOnStateLoaded((current) async {
      await _saveCalculation(
        id: CalculatorIds.enteralNutritionSpeed,
        action: () => _saveEnteralNutritionSpeedCalculationUseCase(
          patientId: current.form.patientLocalId,
          totalDailyVolume: totalDailyVolume,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de velocidade de infusão. Tente novamente.",
        successMessage: "Cálculo de velocidade de infusão salvo com sucesso.",
      );
    });
  }

  Future<void> saveEnteralNutritionVolumeCalculation({
    required double totalDailyEnergy,
    required double caloricDensityOfDiet,
  }) async {
    _executeOnStateLoaded((current) async {
      await _saveCalculation(
        id: CalculatorIds.enteralNutritionVolume,
        action: () => _saveEnteralNutritionVolumeCalculationUseCase(
          patientId: current.form.patientLocalId,
          totalDailyEnergy: totalDailyEnergy,
          caloricDensityOfDiet: caloricDensityOfDiet,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de volume total. Tente novamente.",
        successMessage: "Cálculo de volume total salvo com sucesso.",
      );
    });
  }

  Future<void> saveGlucoseInfusionRateCalculation({
    required double totalGlucose,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty) return;

      final latestWeight = current.weights.first; // newest, per §0's sort

      await _saveCalculation(
        id: CalculatorIds.glucoseInfusionRate,
        action: () => _saveGlucoseInfusionRateCalculationUseCase(
          patientId: current.form.patientLocalId,
          weightKg: latestWeight.value,
          totalGlucose: totalGlucose,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de TIG. Tente novamente.",
        successMessage: "Cálculo de TIG salvo com sucesso.",
      );
    });
  }

  Future<void> saveWeightLossClassificationCalculation() async {
    _executeOnStateLoaded((current) async {
      if (current.weights.length < 2) return;

      final currentWeight = current.weights[0]; // newest, per §0's sort
      final lastWeight = current.weights[1];

      await _saveCalculation(
        id: CalculatorIds.weightLossClassification,
        action: () => _saveWeightLossClassificationCalculationUseCase(
          patientId: current.form.patientLocalId,
          currentWeight: currentWeight.value,
          currentWeightDate: currentWeight.createdAt,
          lastWeight: lastWeight.value,
          lastWeightDate: lastWeight.createdAt,
        ),
        errorFallbackMessage:
            "Não foi possível salvar a classificação de perda de peso. Tente novamente.",
        successMessage:
            "Cálculo de Classificação de Perda de Peso salvo com sucesso.",
      );
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
      await _saveCalculation(
        id: CalculatorIds.must,
        action: () => _saveMustCalculationUseCase(
          patientId: current.form.patientLocalId,
          bmi: bmi,
          avgWeightLossIn3To6Months: avgWeightLossIn3To6Months,
          severeIllnessPresent: severeIllnessPresent,
          reducedFoodIntakeForMoreThan5Days: reducedFoodIntakeForMoreThan5Days,
          willReduceFoodIntakeForMoreThan5Days:
              willReduceFoodIntakeForMoreThan5Days,
        ),
        errorFallbackMessage:
            "Não foi possível salvar a triagem MUST. Tente novamente.",
        successMessage: "Triagem MUST salva com sucesso.",
      );
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

      await _saveCalculation(
        id: CalculatorIds.nrs2002,
        action: () => _saveNrs2002CalculationUseCase(
          patientId: current.form.patientLocalId,
          age: current.form.age!,
          isSeverelyIll: isSeverelyIll,
          weightLossLast3Months: weightLossLast3Months,
          reducedFoodIntakeLastWeek: reducedFoodIntakeLastWeek,
          lowBmi: lowBmi,
          nutritionalStatusClassification: nutritionalStatusClassification,
          illnessSeverityClassification: illnessSeverityClassification,
        ),
        errorFallbackMessage:
            "Não foi possível salvar a triagem NRS-2002. Tente novamente.",
        successMessage: "Triagem NRS-2002 salva com sucesso.",
      );
    });
  }

  Future<void> saveStrongKidsCalculation({
    required bool clinicalAppearanceOfMalnutrition,
    required bool highRiskDiseasePresent,
    required bool reducedIntakeOrLosses,
    required bool weightLossOrGrowthDeficit,
  }) async {
    _executeOnStateLoaded((current) async {
      await _saveCalculation(
        id: CalculatorIds.strongKids,
        action: () => _saveStrongKidsCalculationUseCase(
          patientId: current.form.patientLocalId,
          clinicalAppearanceOfMalnutrition: clinicalAppearanceOfMalnutrition,
          highRiskDiseasePresent: highRiskDiseasePresent,
          reducedIntakeOrLosses: reducedIntakeOrLosses,
          weightLossOrGrowthDeficit: weightLossOrGrowthDeficit,
        ),
        errorFallbackMessage:
            "Não foi possível salvar a triagem STRONG-Kids. Tente novamente.",
        successMessage: "Triagem STRONG-Kids salva com sucesso.",
      );
    });
  }

  Future<void> saveIdealWeightCalculation({
    required Gender gender,
    required bool considerForCalculations,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.heights.isEmpty || current.weights.isEmpty) return;

      final latestHeight = current.heights.first; // newest, per §0's sort
      // This is a new call site (not one of ADR 0007's ~14 deferred
      // "latest weight" sites), so it's free to resolve the override chain
      // directly rather than always grabbing the newest weight.
      final resolvedWeight =
          const ResolveWeightForCalculations()(current.weights) ??
          current.weights.first;

      await _saveCalculation(
        id: CalculatorIds.idealWeight,
        action: () => _saveIdealWeightCalculationUseCase(
          patientId: current.form.patientLocalId,
          heightCm: latestHeight.value,
          gender: gender,
          weightKg: resolvedWeight.value,
          considerForCalculations: considerForCalculations,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de Peso Ideal. Tente novamente.",
        successMessage: "Cálculo de Peso Ideal salvo com sucesso.",
        onSuccess: (_) async {
          // This write went into WEIGHTS (ADR 0007), so `state.weights`/
          // `state.bmi` would otherwise go stale - refetch and recompute,
          // exactly like `saveWeight`'s success branch. Re-read `state`
          // (rather than relying on a possibly-stale captured `current`)
          // to avoid clobbering a status set concurrently by something else.
          final latest = state as PatientDetailsStateLoaded;
          final weightsRes = await _getWeightsUseCase(
            latest.form.patientLocalId,
          );
          final weights = weightsRes.getOrElse(() => latest.weights);

          _executeOnStateLoaded((latest2) {
            emit(
              latest2.copyWith(
                weights: weights,
                bmi: _computeBmi(weights, latest2.heights, latest2.form.age),
              ),
            );
          });
        },
      );
    });
  }

  Future<void> saveAdequationCalculation({
    required bool considerForCalculations,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty) return;

      // Most recent WEIGHTS row of type `.ideal` (Slice 10 po decision,
      // 2026-09-26) - `current.weights` is already newest-first (§0's
      // sort), so `firstWhere` is enough.
      WeightEntity? idealWeightRow;
      for (final w in current.weights) {
        if (w.weightType == WeightTypeEnum.ideal) {
          idealWeightRow = w;
          break;
        }
      }
      if (idealWeightRow == null) return;

      final resolvedWeight =
          const ResolveWeightForCalculations()(current.weights) ??
          current.weights.first;

      await _saveCalculation(
        id: CalculatorIds.adequation,
        action: () => _saveAdequationCalculationUseCase(
          patientId: current.form.patientLocalId,
          currentWeight: resolvedWeight.value,
          idealWeight: idealWeightRow!.value,
          considerForCalculations: considerForCalculations,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de Adequação de Peso. Tente novamente.",
        successMessage: "Cálculo de Adequação de Peso salvo com sucesso.",
        onSuccess: (_) async {
          final latest = state as PatientDetailsStateLoaded;
          final weightsRes = await _getWeightsUseCase(
            latest.form.patientLocalId,
          );
          final weights = weightsRes.getOrElse(() => latest.weights);

          _executeOnStateLoaded((latest2) {
            emit(
              latest2.copyWith(
                weights: weights,
                bmi: _computeBmi(weights, latest2.heights, latest2.form.age),
              ),
            );
          });
        },
      );
    });
  }

  Future<void> saveAdjustedObesityCalculation({
    required bool considerForCalculations,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty) return;

      WeightEntity? idealWeightRow;
      for (final w in current.weights) {
        if (w.weightType == WeightTypeEnum.ideal) {
          idealWeightRow = w;
          break;
        }
      }
      if (idealWeightRow == null) return;

      final resolvedWeight =
          const ResolveWeightForCalculations()(current.weights) ??
          current.weights.first;

      await _saveCalculation(
        id: CalculatorIds.adjustedObesity,
        action: () => _saveAdjustedObesityCalculationUseCase(
          patientId: current.form.patientLocalId,
          currentWeight: resolvedWeight.value,
          idealWeight: idealWeightRow!.value,
          considerForCalculations: considerForCalculations,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de Peso Ajustado. Tente novamente.",
        successMessage: "Cálculo de Peso Ajustado salvo com sucesso.",
        onSuccess: (_) async {
          final latest = state as PatientDetailsStateLoaded;
          final weightsRes = await _getWeightsUseCase(
            latest.form.patientLocalId,
          );
          final weights = weightsRes.getOrElse(() => latest.weights);

          _executeOnStateLoaded((latest2) {
            emit(
              latest2.copyWith(
                weights: weights,
                bmi: _computeBmi(weights, latest2.heights, latest2.form.age),
              ),
            );
          });
        },
      );
    });
  }

  Future<void> saveAdjustedDryWeightCalculation({
    AscitisLevel? ascitis,
    OedemaLevel? oedema,
    required bool considerForCalculations,
  }) async {
    _executeOnStateLoaded((current) async {
      if (current.weights.isEmpty || current.bmi == null) return;

      final resolvedWeight =
          const ResolveWeightForCalculations()(current.weights) ??
          current.weights.first;

      await _saveCalculation(
        id: CalculatorIds.adjustedDryWeight,
        action: () => _saveAdjustedDryWeightCalculationUseCase(
          patientId: current.form.patientLocalId,
          currentWeight: resolvedWeight.value,
          imc: current.bmi!,
          ascitis: ascitis,
          oedema: oedema,
          considerForCalculations: considerForCalculations,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de Peso Seco Ajustado. Tente novamente.",
        successMessage: "Cálculo de Peso Seco Ajustado salvo com sucesso.",
        onSuccess: (_) async {
          final latest = state as PatientDetailsStateLoaded;
          final weightsRes = await _getWeightsUseCase(
            latest.form.patientLocalId,
          );
          final weights = weightsRes.getOrElse(() => latest.weights);

          _executeOnStateLoaded((latest2) {
            emit(
              latest2.copyWith(
                weights: weights,
                bmi: _computeBmi(weights, latest2.heights, latest2.form.age),
              ),
            );
          });
        },
      );
    });
  }

  Future<void> saveEstimatedWeightCalculation({
    required double kneeHeight,
    required double armCircumference,
    required Gender gender,
    required Ethnicity ethnicity,
    required bool considerForCalculations,
  }) async {
    _executeOnStateLoaded((current) async {
      final age = current.form.age;
      if (age == null) return;

      await _saveCalculation(
        id: CalculatorIds.estimatedWeight,
        action: () => _saveEstimatedWeightCalculationUseCase(
          patientId: current.form.patientLocalId,
          kneeHeight: kneeHeight,
          armCircumference: armCircumference,
          gender: gender,
          age: age,
          ethnicity: ethnicity,
          considerForCalculations: considerForCalculations,
        ),
        errorFallbackMessage:
            "Não foi possível salvar o cálculo de Peso Estimado. Tente novamente.",
        successMessage: "Cálculo de Peso Estimado salvo com sucesso.",
        onSuccess: (_) async {
          final latest = state as PatientDetailsStateLoaded;
          final weightsRes = await _getWeightsUseCase(
            latest.form.patientLocalId,
          );
          final weights = weightsRes.getOrElse(() => latest.weights);

          _executeOnStateLoaded((latest2) {
            emit(
              latest2.copyWith(
                weights: weights,
                bmi: _computeBmi(weights, latest2.heights, latest2.form.age),
              ),
            );
          });
        },
      );
    });
  }

  // DELETE (Weights/Heights/Body Measurements/History) ====================
  // ADR 0010: one canonical delete-and-refresh path per data owner.
  // `MeasurementsList`'s Weights tab instance and `PatientHistoryTab` both
  // call this exact method for a Weight-type row - never two independent
  // call sites - so the two tabs never disagree about which weights exist.
  Future<Result<void, String>> deleteWeight(String id) async {
    final res = await _deleteWeightUseCase(id);
    if (res.isOk) await _refreshWeightsAndHistory();
    return res;
  }

  Future<Result<void, String>> deleteHeight(String id) async {
    final res = await _deleteHeightUseCase(id);
    if (res.isOk) await _refreshHeightsAndHistory();
    return res;
  }

  Future<Result<void, String>> deleteBodyMeasurement(String id) async {
    final res = await _deleteBodyMeasurementUseCase(id);
    if (res.isOk) await _refreshBodyMeasurementsAndHistory();
    return res;
  }

  Future<Result<void, String>> deleteHistoryEntry(
    HistoryEntryEntity entry,
  ) async {
    final res = await _deleteCalculatorHistoryEntryUseCase(entry);
    if (res.isOk) {
      if (entry.sourceType == HistorySourceType.weight) {
        await _refreshWeightsAndHistory();
      } else {
        await _refreshHistoryOnly();
      }
    }
    return res;
  }

  // These four helpers used to wrap their whole body in
  // `_executeOnStateLoaded`, which only accepts a synchronous callback -
  // so the `async` callback's returned Future was never awaited and the
  // outer `Future<void> _refreshXAndHistory()` resolved before the actual
  // refetch+emit happened (ADR 0010 violation: callers like `deleteWeight`
  // awaiting these need the real refresh to be done by the time they
  // resolve). Fixed by doing the genuine `await`s directly in the outer
  // async method body - mirroring the pattern already used successfully in
  // e.g. `saveIdealWeightCalculation`'s `onSuccess` callback - and only
  // using `_executeOnStateLoaded` for the final synchronous emit.
  Future<void> _refreshWeightsAndHistory() async {
    if (state is! PatientDetailsStateLoaded) return;
    final current = state as PatientDetailsStateLoaded;

    final weightsRes = await _getWeightsUseCase(current.form.patientLocalId);
    final weights = weightsRes.getOrElse(() => current.weights);
    final historyRes = await _getPatientCalculatorHistoryUseCase(
      current.form.patientLocalId,
    );

    _executeOnStateLoaded((latest) {
      emit(
        latest.copyWith(
          weights: weights,
          bmi: _computeBmi(weights, latest.heights, latest.form.age),
          historyEntries: historyRes.getOrElse(() => latest.historyEntries),
        ),
      );
    });
  }

  Future<void> _refreshHeightsAndHistory() async {
    if (state is! PatientDetailsStateLoaded) return;
    final current = state as PatientDetailsStateLoaded;

    final heightsRes = await _getHeightsUseCase(current.form.patientLocalId);
    final heights = heightsRes.getOrElse(() => current.heights);
    final historyRes = await _getPatientCalculatorHistoryUseCase(
      current.form.patientLocalId,
    );

    _executeOnStateLoaded((latest) {
      emit(
        latest.copyWith(
          heights: heights,
          bmi: _computeBmi(latest.weights, heights, latest.form.age),
          historyEntries: historyRes.getOrElse(() => latest.historyEntries),
        ),
      );
    });
  }

  Future<void> _refreshBodyMeasurementsAndHistory() async {
    if (state is! PatientDetailsStateLoaded) return;
    final current = state as PatientDetailsStateLoaded;

    final measurementsRes = await _getBodyMeasurementUseCase(
      current.form.patientLocalId,
    );
    final measurements = measurementsRes.isOk
        ? measurementsRes
              .getOrElse(() => <BodyMeasurementEntity>[])
              .reversed
              .toList()
        : current.measurements;
    final historyRes = await _getPatientCalculatorHistoryUseCase(
      current.form.patientLocalId,
    );

    _executeOnStateLoaded((latest) {
      emit(
        latest.copyWith(
          measurements: measurements,
          historyEntries: historyRes.getOrElse(() => latest.historyEntries),
        ),
      );
    });
  }

  Future<void> _refreshHistoryOnly() async {
    if (state is! PatientDetailsStateLoaded) return;
    final current = state as PatientDetailsStateLoaded;

    final historyRes = await _getPatientCalculatorHistoryUseCase(
      current.form.patientLocalId,
    );

    _executeOnStateLoaded((latest) {
      emit(
        latest.copyWith(
          historyEntries: historyRes.getOrElse(() => latest.historyEntries),
        ),
      );
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

  // Shared emit-dance for the 14 calculator "save" flows: emit Saving ->
  // call the use case -> emit Error-or-Saved -> auto-reset back to Idle
  // after 2s. See ADR 0008.
  Future<void> _saveCalculation({
    required String id,
    required Future<Result<void, String>> Function() action,
    required String errorFallbackMessage,
    required String successMessage,
    Future<void> Function(PatientDetailsStateLoaded current)? onSuccess,
  }) async {
    _executeOnStateLoaded((current) async {
      emit(
        current.copyWithCalculatorStatus(id, const CalculatorSaveStatusSaving()),
      );

      final res = await action();

      if (res.isError) {
        _executeOnStateLoaded((latest) {
          emit(
            latest.copyWithCalculatorStatus(
              id,
              CalculatorSaveStatusError(errorFallbackMessage),
            ),
          );
        });
        return;
      }

      if (onSuccess != null) {
        await onSuccess(state as PatientDetailsStateLoaded);
      }

      // Recommended shortcut (ADR 0009): refresh `historyEntries` here, once,
      // so every calculator's freshly-saved result shows up in History
      // immediately without per-calculator wiring at each of the 18 call
      // sites above. Deliberately NOT awaited - the existing `isSaved`
      // true-transition timing (relied on by every calculator's save tests)
      // must not shift by an extra microtask hop; this refresh races
      // harmlessly in the background and only touches `historyEntries`.
      if (state is PatientDetailsStateLoaded) {
        final loaded = state as PatientDetailsStateLoaded;
        // ignore: discarded_futures
        _getPatientCalculatorHistoryUseCase(loaded.form.patientLocalId).then((
          historyRes,
        ) {
          if (isClosed) return;
          _executeOnStateLoaded((latest) {
            emit(
              latest.copyWith(
                historyEntries: historyRes.getOrElse(
                  () => latest.historyEntries,
                ),
              ),
            );
          });
        });
      }

      _executeOnStateLoaded((latest) {
        emit(
          latest.copyWithCalculatorStatus(
            id,
            CalculatorSaveStatusSaved(successMessage),
          ),
        );
      });

      // Mirrors `_handleSaveResult`'s reset-after-delay: without resetting
      // back to idle, the page's `listenWhen` previous-vs-current
      // true-transition check would never fire again for a subsequent
      // successful calculation.
      await Future.delayed(const Duration(seconds: 2));
      _executeOnStateLoaded((latest) {
        emit(latest.copyWithCalculatorStatus(id, const CalculatorSaveStatusIdle()));
      });
    });
  }

  // TODO - register measurements
  // circumferences
}
