import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_type_enum.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/create_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/get_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/create_height_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_ids.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/save_bmi_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/save_energy_expenditure_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/entities/enteral_nutrition_dripping_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/save_enteral_nutrition_dripping_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/entities/enteral_nutrition_speed_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/save_enteral_nutrition_speed_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/entities/enteral_nutrition_volume_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/save_enteral_nutrition_volume_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/entities/glucose_infusion_rate_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/save_glucose_infusion_rate_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/ideal_weight/domain/use_cases/save_ideal_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/must/domain/entities/must_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/must/domain/use_cases/save_must_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/entities/nitrogen_balance_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/save_nitrogen_balance_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/entities/nrs_2002_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/use_cases/save_nrs_2002_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/entities/protein_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/save_protein_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/entities/strong_kids_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/use_cases/save_strong_kids_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/entities/water_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/save_water_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/save_weight_loss_classification_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_step_2_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_classification_result.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_score_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/update_patient_use_case.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';

/// Fakes implementing the abstract use-case interfaces directly - no mocking
/// package is set up in this project, matching new_patient_cubit_test.dart's
/// convention.
class _FakeLoadPatientDetailsUseCase implements LoadPatientDetailsUseCase {
  EditPatientFormEntity? formToReturn;
  bool shouldError = false;

  @override
  Future<Result<EditPatientFormEntity, String>> call(
    String patientLocalId,
  ) async {
    if (shouldError) return Error("Erro ao carregar dados do paciente.");
    return Ok(
      formToReturn ??
          EditPatientFormEntity(
            firstName: "Ana",
            lastName: "Silva",
            patientLocalId: patientLocalId,
          ),
    );
  }
}

class _FakeUpdatePatientUseCase implements UpdatePatientUseCase {
  EditPatientFormEntity? lastCall;
  Result<void, String> resultToReturn = Ok(null);

  @override
  Future<Result<void, String>> call(EditPatientFormEntity form) async {
    lastCall = form;
    return resultToReturn;
  }
}

class _FakeGetWeightsUseCase implements GetWeightsUseCase {
  List<WeightEntity> weightsToReturn = [];

  @override
  Future<Result<List<WeightEntity>, String>> call(String patientId) async {
    return Ok(weightsToReturn);
  }
}

class _FakeGetHeightsUseCase implements GetHeightsUseCase {
  List<HeightEntity> heightsToReturn = [];

  @override
  Future<Result<List<HeightEntity>, String>> call(String patientId) async {
    return Ok(heightsToReturn);
  }
}

class _FakeGetBodyMeasurementUseCase implements GetBodyMeasurementUseCase {
  List<BodyMeasurementEntity> measurementsToReturn = [];

  @override
  Future<Result<List<BodyMeasurementEntity>, String>> call(
    String patientId,
  ) async {
    return Ok(measurementsToReturn);
  }
}

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  Result<WeightEntity, String>? resultToReturn;
  WeightEntity? lastCall;

  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async {
    lastCall = weight;
    return resultToReturn ?? Ok(weight);
  }
}

class _FakeCreateHeightUseCase implements CreateHeightUseCase {
  Result<HeightEntity, String>? resultToReturn;
  HeightEntity? lastCall;

  @override
  Future<Result<HeightEntity, String>> call({
    required HeightEntity height,
  }) async {
    lastCall = height;
    return resultToReturn ?? Ok(height);
  }
}

class _FakeSaveBmiCalculationUseCase implements SaveBmiCalculationUseCase {
  Result<BmiCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<BmiCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double heightM,
    required int age,
  }) async {
    return resultToReturn ??
        Ok(
          BmiCalculationEntity(
            id: 'bmi-1',
            patientId: patientId,
            value: weightKg / (heightM * heightM),
            classification: BmiClassification.eutrophy,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveEnergyExpenditureCalculationUseCase
    implements SaveEnergyExpenditureCalculationUseCase {
  Result<EnergyExpenditureCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<EnergyExpenditureCalculationEntity, String>> call({
    required String patientId,
    required EnergyExpenditureFormulaEnum formula,
    required double weightKg,
    double? heightCm,
    int? age,
    Gender? gender,
    ActivityFactor? activityFactor,
    InjuryFactor? injuryFactor,
    TemperatureFactor? temperatureFactor,
    StressLevel stressLevel = StressLevel.noStress,
  }) async {
    return resultToReturn ??
        Ok(
          EnergyExpenditureCalculationEntity(
            id: 'ee-1',
            patientId: patientId,
            formula: formula,
            minValue: 1000,
            maxValue: 1200,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveNitrogenBalanceCalculationUseCase
    implements SaveNitrogenBalanceCalculationUseCase {
  Result<NitrogenBalanceCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<NitrogenBalanceCalculationEntity, String>> call({
    required String patientId,
    required double ingestedProtein,
    required double urineNitrogen24h,
  }) async {
    return resultToReturn ??
        Ok(
          NitrogenBalanceCalculationEntity(
            id: 'nb-1',
            patientId: patientId,
            value: (ingestedProtein / 6.25) / (urineNitrogen24h / 4),
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveProteinNeedsCalculationUseCase
    implements SaveProteinNeedsCalculationUseCase {
  Result<ProteinNeedsCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<ProteinNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required PatientState patientState,
  }) async {
    return resultToReturn ??
        Ok(
          ProteinNeedsCalculationEntity(
            id: 'pn-1',
            patientId: patientId,
            minValue: weightKg * 0.8,
            maxValue: weightKg * 1.0,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveWaterNeedsCalculationUseCase
    implements SaveWaterNeedsCalculationUseCase {
  Result<WaterNeedsCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<WaterNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required int age,
  }) async {
    return resultToReturn ??
        Ok(
          WaterNeedsCalculationEntity(
            id: 'wn-1',
            patientId: patientId,
            value: age >= 60 ? 25 * weightKg : 30 * weightKg,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveEnteralNutritionDrippingCalculationUseCase
    implements SaveEnteralNutritionDrippingCalculationUseCase {
  Result<EnteralNutritionDrippingCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>> call({
    required String patientId,
    required double totalVolume,
    required double totalHoursForVolume,
  }) async {
    return resultToReturn ??
        Ok(
          EnteralNutritionDrippingCalculationEntity(
            id: 'end-1',
            patientId: patientId,
            value: totalVolume / (3 * totalHoursForVolume),
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveEnteralNutritionSpeedCalculationUseCase
    implements SaveEnteralNutritionSpeedCalculationUseCase {
  Result<EnteralNutritionSpeedCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<EnteralNutritionSpeedCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyVolume,
  }) async {
    return resultToReturn ??
        Ok(
          EnteralNutritionSpeedCalculationEntity(
            id: 'ens-1',
            patientId: patientId,
            value: totalDailyVolume / 24,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveEnteralNutritionVolumeCalculationUseCase
    implements SaveEnteralNutritionVolumeCalculationUseCase {
  Result<EnteralNutritionVolumeCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyEnergy,
    required double caloricDensityOfDiet,
  }) async {
    return resultToReturn ??
        Ok(
          EnteralNutritionVolumeCalculationEntity(
            id: 'env-1',
            patientId: patientId,
            value: totalDailyEnergy / caloricDensityOfDiet,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveGlucoseInfusionRateCalculationUseCase
    implements SaveGlucoseInfusionRateCalculationUseCase {
  Result<GlucoseInfusionRateCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<GlucoseInfusionRateCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double totalGlucose,
  }) async {
    return resultToReturn ??
        Ok(
          GlucoseInfusionRateCalculationEntity(
            id: 'gir-1',
            patientId: patientId,
            value: (totalGlucose * 1000) / (1400 * weightKg),
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveWeightLossClassificationCalculationUseCase
    implements SaveWeightLossClassificationCalculationUseCase {
  Result<WeightLossClassificationCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<WeightLossClassificationCalculationEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required DateTime currentWeightDate,
    required double lastWeight,
    required DateTime lastWeightDate,
  }) async {
    return resultToReturn ??
        Ok(
          WeightLossClassificationCalculationEntity(
            id: 'wlc-1',
            patientId: patientId,
            percentage: ((lastWeight - currentWeight) * 100) / lastWeight,
            timeReference: 7,
            classification: WeightLossClassification.ok,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveMustCalculationUseCase implements SaveMustCalculationUseCase {
  Result<MustCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<MustCalculationEntity, String>> call({
    required String patientId,
    required double bmi,
    required double avgWeightLossIn3To6Months,
    required bool severeIllnessPresent,
    required bool reducedFoodIntakeForMoreThan5Days,
    required bool willReduceFoodIntakeForMoreThan5Days,
  }) async {
    return resultToReturn ??
        Ok(
          MustCalculationEntity(
            id: 'must-1',
            patientId: patientId,
            score: 0,
            scoreStep1: 0,
            scoreStep2: 0,
            scoreStep3: 0,
            classification: MustClassificationResult.lowRisk,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveNrs2002CalculationUseCase
    implements SaveNrs2002CalculationUseCase {
  Result<Nrs2002CalculationEntity, String>? resultToReturn;

  @override
  Future<Result<Nrs2002CalculationEntity, String>> call({
    required String patientId,
    required int age,
    required bool isSeverelyIll,
    required bool weightLossLast3Months,
    required bool reducedFoodIntakeLastWeek,
    required bool lowBmi,
    required Nrs2002Step2Classification nutritionalStatusClassification,
    required Nrs2002Step2Classification illnessSeverityClassification,
  }) async {
    return resultToReturn ??
        Ok(
          Nrs2002CalculationEntity(
            id: 'nrs-1',
            patientId: patientId,
            score: 0,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveStrongKidsCalculationUseCase
    implements SaveStrongKidsCalculationUseCase {
  Result<StrongKidsCalculationEntity, String>? resultToReturn;

  @override
  Future<Result<StrongKidsCalculationEntity, String>> call({
    required String patientId,
    required bool clinicalAppearanceOfMalnutrition,
    required bool highRiskDiseasePresent,
    required bool reducedIntakeOrLosses,
    required bool weightLossOrGrowthDeficit,
  }) async {
    return resultToReturn ??
        Ok(
          StrongKidsCalculationEntity(
            id: 'sk-1',
            patientId: patientId,
            score: 0,
            classification: StrongKidsScoreClassification.low,
            createdAt: DateTime.now(),
            inputParams: const [],
          ),
        );
  }
}

class _FakeSaveIdealWeightCalculationUseCase
    implements SaveIdealWeightCalculationUseCase {
  Result<WeightEntity, String>? resultToReturn;
  double? lastWeightKg;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double heightCm,
    required Gender gender,
    required double weightKg,
    required bool considerForCalculations,
  }) async {
    lastWeightKg = weightKg;
    return resultToReturn ??
        Ok(
          WeightEntity(
            id: 'iw-1',
            createdAt: DateTime.now(),
            value: 65.0,
            patientId: patientId,
            considerForCalculations: considerForCalculations,
            weightType: WeightTypeEnum.ideal,
          ),
        );
  }
}

class _FakeCreateBodyMeasurementUseCase implements CreateBodyMeasurementUseCase {
  Result<BodyMeasurementEntity, String>? resultToReturn;
  BodyMeasurementEntity? lastCall;

  @override
  Future<Result<BodyMeasurementEntity, String>> call(
    BodyMeasurementEntity entity,
  ) async {
    lastCall = entity;
    return resultToReturn ?? Ok(entity);
  }
}

void main() {
  const patientId = "local-id-1";

  late _FakeLoadPatientDetailsUseCase fakeLoad;
  late _FakeUpdatePatientUseCase fakeUpdate;
  late _FakeGetWeightsUseCase fakeGetWeights;
  late _FakeGetHeightsUseCase fakeGetHeights;
  late _FakeGetBodyMeasurementUseCase fakeGetMeasurements;
  late _FakeCreateWeightUseCase fakeCreateWeight;
  late _FakeCreateHeightUseCase fakeCreateHeight;
  late _FakeCreateBodyMeasurementUseCase fakeCreateMeasurement;
  late _FakeSaveBmiCalculationUseCase fakeSaveBmiCalculation;
  late _FakeSaveEnergyExpenditureCalculationUseCase
  fakeSaveEnergyExpenditureCalculation;
  late _FakeSaveNitrogenBalanceCalculationUseCase
  fakeSaveNitrogenBalanceCalculation;
  late _FakeSaveProteinNeedsCalculationUseCase fakeSaveProteinNeedsCalculation;
  late _FakeSaveWaterNeedsCalculationUseCase fakeSaveWaterNeedsCalculation;
  late _FakeSaveEnteralNutritionDrippingCalculationUseCase
  fakeSaveEnteralNutritionDrippingCalculation;
  late _FakeSaveEnteralNutritionSpeedCalculationUseCase
  fakeSaveEnteralNutritionSpeedCalculation;
  late _FakeSaveEnteralNutritionVolumeCalculationUseCase
  fakeSaveEnteralNutritionVolumeCalculation;
  late _FakeSaveGlucoseInfusionRateCalculationUseCase
  fakeSaveGlucoseInfusionRateCalculation;
  late _FakeSaveWeightLossClassificationCalculationUseCase
  fakeSaveWeightLossClassificationCalculation;
  late _FakeSaveMustCalculationUseCase fakeSaveMustCalculation;
  late _FakeSaveNrs2002CalculationUseCase fakeSaveNrs2002Calculation;
  late _FakeSaveStrongKidsCalculationUseCase fakeSaveStrongKidsCalculation;
  late _FakeSaveIdealWeightCalculationUseCase fakeSaveIdealWeightCalculation;
  late PatientDetailsCubit cubit;

  setUp(() {
    fakeLoad = _FakeLoadPatientDetailsUseCase();
    fakeUpdate = _FakeUpdatePatientUseCase();
    fakeGetWeights = _FakeGetWeightsUseCase();
    fakeGetHeights = _FakeGetHeightsUseCase();
    fakeGetMeasurements = _FakeGetBodyMeasurementUseCase();
    fakeCreateWeight = _FakeCreateWeightUseCase();
    fakeCreateHeight = _FakeCreateHeightUseCase();
    fakeCreateMeasurement = _FakeCreateBodyMeasurementUseCase();
    fakeSaveBmiCalculation = _FakeSaveBmiCalculationUseCase();
    fakeSaveEnergyExpenditureCalculation =
        _FakeSaveEnergyExpenditureCalculationUseCase();
    fakeSaveNitrogenBalanceCalculation =
        _FakeSaveNitrogenBalanceCalculationUseCase();
    fakeSaveProteinNeedsCalculation = _FakeSaveProteinNeedsCalculationUseCase();
    fakeSaveWaterNeedsCalculation = _FakeSaveWaterNeedsCalculationUseCase();
    fakeSaveEnteralNutritionDrippingCalculation =
        _FakeSaveEnteralNutritionDrippingCalculationUseCase();
    fakeSaveEnteralNutritionSpeedCalculation =
        _FakeSaveEnteralNutritionSpeedCalculationUseCase();
    fakeSaveEnteralNutritionVolumeCalculation =
        _FakeSaveEnteralNutritionVolumeCalculationUseCase();
    fakeSaveGlucoseInfusionRateCalculation =
        _FakeSaveGlucoseInfusionRateCalculationUseCase();
    fakeSaveWeightLossClassificationCalculation =
        _FakeSaveWeightLossClassificationCalculationUseCase();
    fakeSaveMustCalculation = _FakeSaveMustCalculationUseCase();
    fakeSaveNrs2002Calculation = _FakeSaveNrs2002CalculationUseCase();
    fakeSaveStrongKidsCalculation = _FakeSaveStrongKidsCalculationUseCase();
    fakeSaveIdealWeightCalculation = _FakeSaveIdealWeightCalculationUseCase();

    cubit = PatientDetailsCubit(
      loadPatientDetailsUseCase: fakeLoad,
      updatePatientUseCase: fakeUpdate,
      createWeightUseCase: fakeCreateWeight,
      getWeightsUseCase: fakeGetWeights,
      createHeightUseCase: fakeCreateHeight,
      getHeightsUseCase: fakeGetHeights,
      createBodyMeasurementUseCase: fakeCreateMeasurement,
      getBodyMeasurementUseCase: fakeGetMeasurements,
      saveBmiCalculationUseCase: fakeSaveBmiCalculation,
      saveEnergyExpenditureCalculationUseCase:
          fakeSaveEnergyExpenditureCalculation,
      saveNitrogenBalanceCalculationUseCase: fakeSaveNitrogenBalanceCalculation,
      saveProteinNeedsCalculationUseCase: fakeSaveProteinNeedsCalculation,
      saveWaterNeedsCalculationUseCase: fakeSaveWaterNeedsCalculation,
      saveEnteralNutritionDrippingCalculationUseCase:
          fakeSaveEnteralNutritionDrippingCalculation,
      saveEnteralNutritionSpeedCalculationUseCase:
          fakeSaveEnteralNutritionSpeedCalculation,
      saveEnteralNutritionVolumeCalculationUseCase:
          fakeSaveEnteralNutritionVolumeCalculation,
      saveGlucoseInfusionRateCalculationUseCase:
          fakeSaveGlucoseInfusionRateCalculation,
      saveWeightLossClassificationCalculationUseCase:
          fakeSaveWeightLossClassificationCalculation,
      saveMustCalculationUseCase: fakeSaveMustCalculation,
      saveNrs2002CalculationUseCase: fakeSaveNrs2002Calculation,
      saveStrongKidsCalculationUseCase: fakeSaveStrongKidsCalculation,
      saveIdealWeightCalculationUseCase: fakeSaveIdealWeightCalculation,
    );
  });

  group('BMI', () {
    test('weight and height both present computes correct BMI', () async {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId, considerForCalculations: true, weightType: WeightTypeEnum.measuredByScale),
      ];
      fakeGetHeights.heightsToReturn = [
        HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
      ];

      await cubit.init(patientId);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.bmi, isNotNull);
      expect(state.bmi!.value, closeTo(70 / (1.75 * 1.75), 0.001));
    });

    test('weight list empty -> bmi is null', () async {
      fakeGetWeights.weightsToReturn = [];
      fakeGetHeights.heightsToReturn = [
        HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
      ];

      await cubit.init(patientId);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.bmi, isNull);
    });

    test('height list empty -> bmi is null', () async {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId, considerForCalculations: true, weightType: WeightTypeEnum.measuredByScale),
      ];
      fakeGetHeights.heightsToReturn = [];

      await cubit.init(patientId);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.bmi, isNull);
    });

    test('both empty -> bmi is null', () async {
      fakeGetWeights.weightsToReturn = [];
      fakeGetHeights.heightsToReturn = [];

      await cubit.init(patientId);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.bmi, isNull);
    });

    test('height fed in cm produces a plausible BMI (cm->m conversion)', () async {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId, considerForCalculations: true, weightType: WeightTypeEnum.measuredByScale),
      ];
      fakeGetHeights.heightsToReturn = [
        HeightEntity(createdAt: DateTime.now(), value: 170, patientId: patientId),
      ];

      await cubit.init(patientId);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.bmi, isNotNull);
      expect(state.bmi!.value, inInclusiveRange(10, 60));
    });
  });

  group('Save error / edit-mode (Gap 2)', () {
    test(
      'updatePatientData() when update use case errors keeps isEditing true and sets saveErrorMessage',
      () async {
        await cubit.init(patientId);
        fakeUpdate.resultToReturn = Error("db failure");

        await cubit.updatePatientData();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isEditing, isTrue);
        expect(state.isSaveError, isTrue);
        expect(
          state.saveErrorMessage,
          "Não foi possível salvar as alterações. Tente novamente.",
        );
        expect(state.isSaving, isFalse);
      },
    );

    test(
      'updatePatientData() success flips isEditing false, isSaved true, then reverts after delay',
      () async {
        await cubit.init(patientId);
        fakeUpdate.resultToReturn = Ok(null);

        await cubit.updatePatientData();

        var state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isEditing, isFalse);
        expect(state.isSaved, isTrue);

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isSaved, isFalse);
        expect(state.isEditing, isFalse);
      },
    );

    test(
      'closedErrorModal() after an error resets isSaveError/saveErrorMessage without touching form/isEditing',
      () async {
        await cubit.init(patientId);
        fakeUpdate.resultToReturn = Error("db failure");
        await cubit.updatePatientData();

        final beforeForm = (cubit.state as PatientDetailsStateLoaded).form;
        final beforeIsEditing =
            (cubit.state as PatientDetailsStateLoaded).isEditing;

        cubit.closedErrorModal();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isSaveError, isFalse);
        expect(state.saveErrorMessage, isNull);
        expect(state.form, beforeForm);
        expect(state.isEditing, beforeIsEditing);
      },
    );
  });

  group('Validation (Gap 3)', () {
    test(
      'negative age short-circuits with "Idade inválida." and does not call update use case',
      () async {
        await cubit.init(patientId);
        cubit.updateAge("-5");

        await cubit.updatePatientData();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.saveErrorMessage, "Idade inválida.");
        expect(state.isEditing, isTrue);
        expect(fakeUpdate.lastCall, isNull);
      },
    );

    test(
      'future birthdate short-circuits with the birthdate message and does not call update use case',
      () async {
        await cubit.init(patientId);
        cubit.updateBirthdate(DateTime.now().add(Duration(days: 1)));

        await cubit.updatePatientData();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(
          state.saveErrorMessage,
          "A data de nascimento precisa ser menor que a de agora.",
        );
        expect(state.isEditing, isTrue);
        expect(fakeUpdate.lastCall, isNull);
      },
    );

    test('valid age/birthdate calls the update use case', () async {
      await cubit.init(patientId);
      cubit.updateAge("30");

      await cubit.updatePatientData();

      expect(fakeUpdate.lastCall, isNotNull);
    });
  });

  group('saveWeight (Bug 2)', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId, considerForCalculations: true, weightType: WeightTypeEnum.measuredByScale),
      ];
      fakeGetHeights.heightsToReturn = [
        HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
      ];
    });

    test('on error: sets isSaveError, keeps newWeight for retry, clears isSavingWeight', () async {
      await cubit.init(patientId);
      cubit.updateWeightValue("80.5");
      fakeCreateWeight.resultToReturn = Error("db failure");

      await cubit.saveWeight();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isTrue);
      expect(
        state.saveErrorMessage,
        "Não foi possível salvar o peso. Tente novamente.",
      );
      expect(state.newWeight, 80.5, reason: 'form input must be preserved for retry');
      expect(state.isSavingWeight, isFalse);
    });

    test('on success: refetches weights, clears form, recomputes bmi', () async {
      await cubit.init(patientId);
      cubit.updateWeightValue("80.5");

      // simulate the refetch returning the newly-created weight too
      fakeGetWeights.weightsToReturn = [
        WeightEntity(createdAt: DateTime.now(), value: 80.5, patientId: patientId, considerForCalculations: true, weightType: WeightTypeEnum.measuredByScale),
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId, considerForCalculations: true, weightType: WeightTypeEnum.measuredByScale),
      ];

      await cubit.saveWeight();
      // saveWeight's outer Future resolves before the inner async callback's
      // second await (the weights refetch) settles - see
      // _executeOnStateLoaded, which invokes the async callback without
      // awaiting it. Pump the microtask queue so the refetch/emit completes.
      await Future.delayed(Duration.zero);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isFalse);
      expect(state.isSavingWeight, isFalse);
      expect(state.newWeight, isNull, reason: 'form must be cleared on success');
      expect(state.weights.length, 2);
      expect(state.bmi, isNotNull);
      expect(
        state.bmi!.value,
        closeTo(80.5 / (1.75 * 1.75), 0.001),
        reason: 'bmi must be recomputed from the refetched (latest) weight',
      );
    });

    test('after a failed save, a subsequent successful save resets isSaveError to false', () async {
      await cubit.init(patientId);
      cubit.updateWeightValue("80.5");
      fakeCreateWeight.resultToReturn = Error("db failure");

      await cubit.saveWeight();

      expect((cubit.state as PatientDetailsStateLoaded).isSaveError, isTrue);

      cubit.updateWeightValue("81.0");
      fakeCreateWeight.resultToReturn = null;

      await cubit.saveWeight();
      // see saveWeight's success test for why this pump is needed.
      await Future.delayed(Duration.zero);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isFalse);
    });
  });

  group('saveHeight (Bug 2)', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId, considerForCalculations: true, weightType: WeightTypeEnum.measuredByScale),
      ];
      fakeGetHeights.heightsToReturn = [
        HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
      ];
    });

    test('on error: sets isSaveError, keeps newHeight for retry, clears isSavingHeight', () async {
      await cubit.init(patientId);
      cubit.updateHeightValue("180");
      fakeCreateHeight.resultToReturn = Error("db failure");

      await cubit.saveHeight();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isTrue);
      expect(
        state.saveErrorMessage,
        "Não foi possível salvar a altura. Tente novamente.",
      );
      expect(state.newHeight, 180.0, reason: 'form input must be preserved for retry');
      expect(state.isSavingHeight, isFalse);
    });

    test('on success: refetches heights, clears form, recomputes bmi', () async {
      await cubit.init(patientId);
      cubit.updateHeightValue("180");

      fakeGetHeights.heightsToReturn = [
        HeightEntity(createdAt: DateTime.now(), value: 180, patientId: patientId),
        HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
      ];

      await cubit.saveHeight();
      // see saveWeight's success test for why this pump is needed.
      await Future.delayed(Duration.zero);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isFalse);
      expect(state.isSavingHeight, isFalse);
      expect(state.newHeight, isNull, reason: 'form must be cleared on success');
      expect(state.heights.length, 2);
      expect(state.bmi, isNotNull);
      expect(
        state.bmi!.value,
        closeTo(70 / (1.8 * 1.8), 0.001),
        reason: 'bmi must be recomputed from the refetched (latest) height',
      );
    });

    test('after a failed save, a subsequent successful save resets isSaveError to false', () async {
      await cubit.init(patientId);
      cubit.updateHeightValue("180");
      fakeCreateHeight.resultToReturn = Error("db failure");

      await cubit.saveHeight();

      expect((cubit.state as PatientDetailsStateLoaded).isSaveError, isTrue);

      cubit.updateHeightValue("182");
      fakeCreateHeight.resultToReturn = null;

      await cubit.saveHeight();
      // see saveWeight's success test for why this pump is needed.
      await Future.delayed(Duration.zero);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isFalse);
    });
  });

  group('saveNewBodyMeasurement (Bug 2)', () {
    test('on error: sets isSaveError, keeps form for retry, clears isSavingNewBodyMeasurement', () async {
      await cubit.init(patientId);
      cubit.updateBodyMeasurementForm("armCircumference");
      cubit.updateBodyMeasurementForm(30.0);
      fakeCreateMeasurement.resultToReturn = Error("db failure");

      await cubit.saveNewBodyMeasurement();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isTrue);
      expect(
        state.saveErrorMessage,
        "Não foi possível salvar a medida. Tente novamente.",
      );
      expect(
        state.newBodyMeasurementValue,
        30.0,
        reason: 'form input must be preserved for retry',
      );
      expect(state.newBodyMeasurementType, BodyMeasurementTypeEnum.armCircumference);
      expect(state.isSavingNewBodyMeasurement, isFalse);
    });

    test('on success: refetches measurements (reversed), clears form', () async {
      await cubit.init(patientId);
      cubit.updateBodyMeasurementForm("armCircumference");
      cubit.updateBodyMeasurementForm(30.0);

      final saved = BodyMeasurementEntity(
        createdAt: DateTime.now(),
        patientId: patientId,
        value: 30.0,
        measurementType: BodyMeasurementTypeEnum.armCircumference,
      );
      fakeGetMeasurements.measurementsToReturn = [saved];

      await cubit.saveNewBodyMeasurement();
      // see saveWeight's success test for why this pump is needed.
      await Future.delayed(Duration.zero);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isFalse);
      expect(state.isSavingNewBodyMeasurement, isFalse);
      expect(state.newBodyMeasurementValue, isNull);
      expect(state.newBodyMeasurementType, isNull);
      expect(state.measurements, [saved]);
    });

    test('after a failed save, a subsequent successful save resets isSaveError to false', () async {
      await cubit.init(patientId);
      cubit.updateBodyMeasurementForm("armCircumference");
      cubit.updateBodyMeasurementForm(30.0);
      fakeCreateMeasurement.resultToReturn = Error("db failure");

      await cubit.saveNewBodyMeasurement();

      expect((cubit.state as PatientDetailsStateLoaded).isSaveError, isTrue);

      cubit.updateBodyMeasurementForm("armCircumference");
      cubit.updateBodyMeasurementForm(32.0);
      fakeCreateMeasurement.resultToReturn = null;

      await cubit.saveNewBodyMeasurement();
      // see saveWeight's success test for why this pump is needed.
      await Future.delayed(Duration.zero);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSaveError, isFalse);
    });
  });

  group('saveBmiCalculation', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime.now(),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
      fakeGetHeights.heightsToReturn = [
        HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
      ];
    });

    test('on success: sets calculatorStatus(CalculatorIds.bmi).isSaved true and clears calculatorStatus(CalculatorIds.bmi).isSaving', () async {
      await cubit.init(patientId);

      await cubit.saveBmiCalculation();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.bmi).isSaved, isTrue);
      expect(state.calculatorStatus(CalculatorIds.bmi).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.bmi).isError, isFalse);
    });

    test(
      'on error: sets calculatorStatus(CalculatorIds.bmi).isError/calculatorStatus(CalculatorIds.bmi).errorMessage and clears calculatorStatus(CalculatorIds.bmi).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveBmiCalculation.resultToReturn = Error("db failure");

        await cubit.saveBmiCalculation();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.bmi).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.bmi).errorMessage,
          "Não foi possível salvar o cálculo de IMC. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.bmi).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.bmi) resets calculatorStatus(CalculatorIds.bmi).isError/calculatorStatus(CalculatorIds.bmi).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveBmiCalculation.resultToReturn = Error("db failure");
        await cubit.saveBmiCalculation();

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.bmi).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.bmi);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.bmi).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.bmi).errorMessage, isNull);
      },
    );

    test(
      // Regression test for the bug where closedCalculatorErrorModal(CalculatorIds.bmi) used a full
      // PatientDetailsStateLoaded(...) reconstruction that omitted the
      // newer calculator save flags, silently resetting them to their
      // constructor defaults (see roadmap tech-lead review, 2026-09-22).
      'closedCalculatorErrorModal(CalculatorIds.bmi) preserves unrelated in-flight calculator save '
      'state (e.g. calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved)',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved,
          isTrue,
        );

        fakeSaveBmiCalculation.resultToReturn = Error("db failure");
        await cubit.saveBmiCalculation();
        cubit.closedCalculatorErrorModal(CalculatorIds.bmi);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved, isTrue);
      },
    );

    test('no weight/height data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveBmiCalculation();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.bmi).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.bmi).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.bmi).isError, isFalse);
    });

    test(
      // Regression test for the same "stuck true forever" bug class fixed
      // for isSaveError (roadmap 2.1.4 general notes, 2026-09-19): calculatorStatus(CalculatorIds.bmi).isSaved
      // must revert to false ~2s after a successful save so the page's
      // listenWhen previous-vs-current true-transition check can fire again
      // for a later successful calculation.
      'on success: calculatorStatus(CalculatorIds.bmi).isSaved reverts to false after the auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveBmiCalculation();
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.bmi).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.bmi).isSaved, isFalse);
      },
    );
  });

  group('saveEnergyExpenditureCalculation', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime.now(),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
    });

    test(
      'on success: sets calculatorStatus(CalculatorIds.energyExpenditure).isSaved true and clears '
      'calculatorStatus(CalculatorIds.energyExpenditure).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.energyExpenditure).isError/'
      'calculatorStatus(CalculatorIds.energyExpenditure).errorMessage and clears calculatorStatus(CalculatorIds.energyExpenditure).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveEnergyExpenditureCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.energyExpenditure).errorMessage,
          "Não foi possível salvar o cálculo de gasto energético. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.energyExpenditure) resets '
      'calculatorStatus(CalculatorIds.energyExpenditure).isError/calculatorStatus(CalculatorIds.energyExpenditure).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveEnergyExpenditureCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.energyExpenditure).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.energyExpenditure);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).errorMessage, isNull);
      },
    );

    test(
      // Regression test: see closedCalculatorErrorModal(CalculatorIds.bmi) equivalent above.
      'closedCalculatorErrorModal(CalculatorIds.energyExpenditure) preserves unrelated in-flight '
      'calculator save state (e.g. calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved)',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved,
          isTrue,
        );

        fakeSaveEnergyExpenditureCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );
        cubit.closedCalculatorErrorModal(CalculatorIds.energyExpenditure);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved, isTrue);
      },
    );

    test('no weight data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveEnergyExpenditureCalculation(
        formula: EnergyExpenditureFormulaEnum.pocket,
      );

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isError, isFalse);
    });

    test(
      // Regression test for the same "stuck true forever" bug class fixed
      // for calculatorStatus(CalculatorIds.bmi).isSaved/isSaveError: calculatorStatus(CalculatorIds.energyExpenditure).isSaved must revert to
      // false ~2s after a successful save so the page's listenWhen
      // previous-vs-current true-transition check can fire again for a
      // later successful calculation.
      'on success: calculatorStatus(CalculatorIds.energyExpenditure).isSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.energyExpenditure).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.energyExpenditure).isSaved, isFalse);
      },
    );
  });

  group('saveNitrogenBalanceCalculation', () {
    test(
      'on success: sets calculatorStatus(CalculatorIds.nitrogenBalance).isSaved true and clears '
      'calculatorStatus(CalculatorIds.nitrogenBalance).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveNitrogenBalanceCalculation(
          ingestedProtein: 90,
          urineNitrogen24h: 10,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.nitrogenBalance).isError/'
      'calculatorStatus(CalculatorIds.nitrogenBalance).errorMessage and clears calculatorStatus(CalculatorIds.nitrogenBalance).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveNitrogenBalanceCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveNitrogenBalanceCalculation(
          ingestedProtein: 90,
          urineNitrogen24h: 10,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.nitrogenBalance).errorMessage,
          "Não foi possível salvar o balanço nitrogenado. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.nitrogenBalance) resets '
      'calculatorStatus(CalculatorIds.nitrogenBalance).isError/calculatorStatus(CalculatorIds.nitrogenBalance).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveNitrogenBalanceCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveNitrogenBalanceCalculation(
          ingestedProtein: 90,
          urineNitrogen24h: 10,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.nitrogenBalance).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.nitrogenBalance);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).errorMessage, isNull);
      },
    );

    test(
      // Regression test: see closedCalculatorErrorModal(CalculatorIds.bmi) equivalent above.
      'closedCalculatorErrorModal(CalculatorIds.nitrogenBalance) preserves unrelated in-flight '
      'calculator save state (e.g. calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved)',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved,
          isTrue,
        );

        fakeSaveNitrogenBalanceCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveNitrogenBalanceCalculation(
          ingestedProtein: 90,
          urineNitrogen24h: 10,
        );
        cubit.closedCalculatorErrorModal(CalculatorIds.nitrogenBalance);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved, isTrue);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.nitrogenBalance).isSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveNitrogenBalanceCalculation(
          ingestedProtein: 90,
          urineNitrogen24h: 10,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.nitrogenBalance).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nitrogenBalance).isSaved, isFalse);
      },
    );
  });

  group('saveProteinNeedsCalculation', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime.now(),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
    });

    test(
      'on success: sets calculatorStatus(CalculatorIds.proteinNeeds).isSaved true and clears '
      'calculatorStatus(CalculatorIds.proteinNeeds).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveProteinNeedsCalculation(
          patientState: PatientState.healthy,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.proteinNeeds).isError/calculatorStatus(CalculatorIds.proteinNeeds).errorMessage '
      'and clears calculatorStatus(CalculatorIds.proteinNeeds).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveProteinNeedsCalculation.resultToReturn = Error("db failure");

        await cubit.saveProteinNeedsCalculation(
          patientState: PatientState.healthy,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.proteinNeeds).errorMessage,
          "Não foi possível salvar o cálculo de necessidade proteica. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.proteinNeeds) resets '
      'calculatorStatus(CalculatorIds.proteinNeeds).isError/calculatorStatus(CalculatorIds.proteinNeeds).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveProteinNeedsCalculation.resultToReturn = Error("db failure");
        await cubit.saveProteinNeedsCalculation(
          patientState: PatientState.healthy,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.proteinNeeds).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.proteinNeeds);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).errorMessage, isNull);
      },
    );

    test(
      // Regression test: see closedCalculatorErrorModal(CalculatorIds.bmi) equivalent above.
      'closedCalculatorErrorModal(CalculatorIds.proteinNeeds) preserves unrelated in-flight '
      'calculator save state (e.g. calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved)',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved,
          isTrue,
        );

        fakeSaveProteinNeedsCalculation.resultToReturn = Error("db failure");
        await cubit.saveProteinNeedsCalculation(
          patientState: PatientState.healthy,
        );
        cubit.closedCalculatorErrorModal(CalculatorIds.proteinNeeds);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved, isTrue);
      },
    );

    test('no weight data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveProteinNeedsCalculation(
        patientState: PatientState.healthy,
      );

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isError, isFalse);
    });

    test(
      'on success: calculatorStatus(CalculatorIds.proteinNeeds).isSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveProteinNeedsCalculation(
          patientState: PatientState.healthy,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.proteinNeeds).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.proteinNeeds).isSaved, isFalse);
      },
    );
  });

  group('saveWaterNeedsCalculation', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime.now(),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
    });

    test(
      'on success: sets calculatorStatus(CalculatorIds.waterNeeds).isSaved true and clears calculatorStatus(CalculatorIds.waterNeeds).isSaving',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 30,
        );
        await cubit.init(patientId);

        await cubit.saveWaterNeedsCalculation();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.waterNeeds).isError/calculatorStatus(CalculatorIds.waterNeeds).errorMessage and '
      'clears calculatorStatus(CalculatorIds.waterNeeds).isSaving',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 30,
        );
        await cubit.init(patientId);
        fakeSaveWaterNeedsCalculation.resultToReturn = Error("db failure");

        await cubit.saveWaterNeedsCalculation();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.waterNeeds).errorMessage,
          "Não foi possível salvar o cálculo de necessidade hídrica. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.waterNeeds) resets calculatorStatus(CalculatorIds.waterNeeds).isError/'
      'calculatorStatus(CalculatorIds.waterNeeds).errorMessage',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 30,
        );
        await cubit.init(patientId);
        fakeSaveWaterNeedsCalculation.resultToReturn = Error("db failure");
        await cubit.saveWaterNeedsCalculation();

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.waterNeeds).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.waterNeeds);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).errorMessage, isNull);
      },
    );

    test('no weight data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      fakeLoad.formToReturn = EditPatientFormEntity(
        firstName: "Ana",
        lastName: "Silva",
        patientLocalId: patientId,
        age: 30,
      );
      await cubit.init(patientId);

      await cubit.saveWaterNeedsCalculation();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.waterNeeds).isError, isFalse);
    });

    test('no age: does nothing', () async {
      fakeLoad.formToReturn = EditPatientFormEntity(
        firstName: "Ana",
        lastName: "Silva",
        patientLocalId: patientId,
      );
      await cubit.init(patientId);

      await cubit.saveWaterNeedsCalculation();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.waterNeeds).isError, isFalse);
    });

    test(
      'on success: calculatorStatus(CalculatorIds.waterNeeds).isSaved reverts to false after the auto-close '
      'delay',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 30,
        );
        await cubit.init(patientId);

        await cubit.saveWaterNeedsCalculation();
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.waterNeeds).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.waterNeeds).isSaved, isFalse);
      },
    );
  });

  group('saveEnteralNutritionDrippingCalculation', () {
    test(
      'on success: sets calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved true and clears '
      'calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.enteralNutritionDripping).isError/'
      'calculatorStatus(CalculatorIds.enteralNutritionDripping).errorMessage and clears '
      'calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveEnteralNutritionDrippingCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.enteralNutritionDripping).errorMessage,
          "Não foi possível salvar o cálculo de gotejamento. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.enteralNutritionDripping) resets '
      'calculatorStatus(CalculatorIds.enteralNutritionDripping).isError/'
      'calculatorStatus(CalculatorIds.enteralNutritionDripping).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveEnteralNutritionDrippingCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionDripping).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.enteralNutritionDripping);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).errorMessage, isNull);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved reverts to false after '
      'the auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionDrippingCalculation(
          totalVolume: 1000,
          totalHoursForVolume: 8,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionDripping).isSaved, isFalse);
      },
    );
  });

  group('saveEnteralNutritionSpeedCalculation', () {
    test(
      'on success: sets calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaved true and clears '
      'calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionSpeedCalculation(
          totalDailyVolume: 2000,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.enteralNutritionSpeed).isError/'
      'calculatorStatus(CalculatorIds.enteralNutritionSpeed).errorMessage and clears '
      'calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveEnteralNutritionSpeedCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveEnteralNutritionSpeedCalculation(
          totalDailyVolume: 2000,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).errorMessage,
          "Não foi possível salvar o cálculo de velocidade de infusão. "
          "Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.enteralNutritionSpeed) resets '
      'calculatorStatus(CalculatorIds.enteralNutritionSpeed).isError/calculatorStatus(CalculatorIds.enteralNutritionSpeed).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveEnteralNutritionSpeedCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveEnteralNutritionSpeedCalculation(
          totalDailyVolume: 2000,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionSpeed).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.enteralNutritionSpeed);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).errorMessage, isNull);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionSpeedCalculation(
          totalDailyVolume: 2000,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionSpeed).isSaved, isFalse);
      },
    );
  });

  group('saveEnteralNutritionVolumeCalculation', () {
    test(
      'on success: sets calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaved true and clears '
      'calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionVolumeCalculation(
          totalDailyEnergy: 2000,
          caloricDensityOfDiet: 1.5,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.enteralNutritionVolume).isError/'
      'calculatorStatus(CalculatorIds.enteralNutritionVolume).errorMessage and clears '
      'calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveEnteralNutritionVolumeCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveEnteralNutritionVolumeCalculation(
          totalDailyEnergy: 2000,
          caloricDensityOfDiet: 1.5,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.enteralNutritionVolume).errorMessage,
          "Não foi possível salvar o cálculo de volume total. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.enteralNutritionVolume) resets '
      'calculatorStatus(CalculatorIds.enteralNutritionVolume).isError/'
      'calculatorStatus(CalculatorIds.enteralNutritionVolume).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveEnteralNutritionVolumeCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveEnteralNutritionVolumeCalculation(
          totalDailyEnergy: 2000,
          caloricDensityOfDiet: 1.5,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionVolume).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.enteralNutritionVolume);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).errorMessage, isNull);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnteralNutritionVolumeCalculation(
          totalDailyEnergy: 2000,
          caloricDensityOfDiet: 1.5,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.enteralNutritionVolume).isSaved, isFalse);
      },
    );
  });

  group('saveGlucoseInfusionRateCalculation', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime.now(),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
    });

    test(
      'on success: sets calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaved true and clears '
      'calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveGlucoseInfusionRateCalculation(totalGlucose: 50);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.glucoseInfusionRate).isError/'
      'calculatorStatus(CalculatorIds.glucoseInfusionRate).errorMessage and clears '
      'calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveGlucoseInfusionRateCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveGlucoseInfusionRateCalculation(totalGlucose: 50);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.glucoseInfusionRate).errorMessage,
          "Não foi possível salvar o cálculo de TIG. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.glucoseInfusionRate) resets '
      'calculatorStatus(CalculatorIds.glucoseInfusionRate).isError/calculatorStatus(CalculatorIds.glucoseInfusionRate).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveGlucoseInfusionRateCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveGlucoseInfusionRateCalculation(totalGlucose: 50);

        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.glucoseInfusionRate).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.glucoseInfusionRate);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).errorMessage, isNull);
      },
    );

    test('no weight data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveGlucoseInfusionRateCalculation(totalGlucose: 50);

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isError, isFalse);
    });

    test(
      'on success: calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveGlucoseInfusionRateCalculation(totalGlucose: 50);
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.glucoseInfusionRate).isSaved, isFalse);
      },
    );
  });

  group('saveWeightLossClassificationCalculation', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime(2026, 9, 20),
          value: 65,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
        WeightEntity(
          createdAt: DateTime(2026, 9, 1),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
    });

    test(
      'on success: sets calculatorStatus(CalculatorIds.weightLossClassification).isSaved true and clears '
      'calculatorStatus(CalculatorIds.weightLossClassification).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveWeightLossClassificationCalculation();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.weightLossClassification).isError/'
      'calculatorStatus(CalculatorIds.weightLossClassification).errorMessage and clears '
      'calculatorStatus(CalculatorIds.weightLossClassification).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveWeightLossClassificationCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveWeightLossClassificationCalculation();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.weightLossClassification).errorMessage,
          "Não foi possível salvar a classificação de perda de peso. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.weightLossClassification) resets '
      'calculatorStatus(CalculatorIds.weightLossClassification).isError/'
      'calculatorStatus(CalculatorIds.weightLossClassification).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveWeightLossClassificationCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveWeightLossClassificationCalculation();

        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.weightLossClassification).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.weightLossClassification);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).errorMessage, isNull);
      },
    );

    test('fewer than 2 weights: does nothing', () async {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime.now(),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
      await cubit.init(patientId);

      await cubit.saveWeightLossClassificationCalculation();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isError, isFalse);
    });

    test(
      'on success: calculatorStatus(CalculatorIds.weightLossClassification).isSaved reverts to false after '
      'the auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveWeightLossClassificationCalculation();
        expect(
          (cubit.state as PatientDetailsStateLoaded)
              .calculatorStatus(CalculatorIds.weightLossClassification).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.weightLossClassification).isSaved, isFalse);
      },
    );
  });

  group('saveMustCalculation', () {
    test(
      'on success: sets calculatorStatus(CalculatorIds.must).isSaved true and clears calculatorStatus(CalculatorIds.must).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveMustCalculation(
          bmi: 19,
          avgWeightLossIn3To6Months: 3,
          severeIllnessPresent: false,
          reducedFoodIntakeForMoreThan5Days: false,
          willReduceFoodIntakeForMoreThan5Days: false,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.must).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.must).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.must).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.must).isError/calculatorStatus(CalculatorIds.must).errorMessage and clears '
      'calculatorStatus(CalculatorIds.must).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveMustCalculation.resultToReturn = Error("db failure");

        await cubit.saveMustCalculation(
          bmi: 19,
          avgWeightLossIn3To6Months: 3,
          severeIllnessPresent: false,
          reducedFoodIntakeForMoreThan5Days: false,
          willReduceFoodIntakeForMoreThan5Days: false,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.must).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.must).errorMessage,
          "Não foi possível salvar a triagem MUST. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.must).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.must) resets calculatorStatus(CalculatorIds.must).isError/calculatorStatus(CalculatorIds.must).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveMustCalculation.resultToReturn = Error("db failure");
        await cubit.saveMustCalculation(
          bmi: 19,
          avgWeightLossIn3To6Months: 3,
          severeIllnessPresent: false,
          reducedFoodIntakeForMoreThan5Days: false,
          willReduceFoodIntakeForMoreThan5Days: false,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.must).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.must);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.must).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.must).errorMessage, isNull);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.must).isSaved reverts to false after the auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveMustCalculation(
          bmi: 19,
          avgWeightLossIn3To6Months: 3,
          severeIllnessPresent: false,
          reducedFoodIntakeForMoreThan5Days: false,
          willReduceFoodIntakeForMoreThan5Days: false,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.must).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.must).isSaved, isFalse);
      },
    );
  });

  group('saveNrs2002Calculation', () {
    test(
      'on success: sets calculatorStatus(CalculatorIds.nrs2002).isSaved true and clears calculatorStatus(CalculatorIds.nrs2002).isSaving',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 45,
        );
        await cubit.init(patientId);

        await cubit.saveNrs2002Calculation(
          isSeverelyIll: false,
          weightLossLast3Months: false,
          reducedFoodIntakeLastWeek: false,
          lowBmi: false,
          nutritionalStatusClassification: Nrs2002Step2Classification.absent,
          illnessSeverityClassification: Nrs2002Step2Classification.absent,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nrs2002).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.nrs2002).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.nrs2002).isError, isFalse);
      },
    );

    test('no patient age: does nothing', () async {
      await cubit.init(patientId);

      await cubit.saveNrs2002Calculation(
        isSeverelyIll: false,
        weightLossLast3Months: false,
        reducedFoodIntakeLastWeek: false,
        lowBmi: false,
        nutritionalStatusClassification: Nrs2002Step2Classification.absent,
        illnessSeverityClassification: Nrs2002Step2Classification.absent,
      );

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.nrs2002).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.nrs2002).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.nrs2002).isError, isFalse);
    });

    test(
      'on error: sets calculatorStatus(CalculatorIds.nrs2002).isError/calculatorStatus(CalculatorIds.nrs2002).errorMessage and clears '
      'calculatorStatus(CalculatorIds.nrs2002).isSaving',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 45,
        );
        await cubit.init(patientId);
        fakeSaveNrs2002Calculation.resultToReturn = Error("db failure");

        await cubit.saveNrs2002Calculation(
          isSeverelyIll: false,
          weightLossLast3Months: false,
          reducedFoodIntakeLastWeek: false,
          lowBmi: false,
          nutritionalStatusClassification: Nrs2002Step2Classification.absent,
          illnessSeverityClassification: Nrs2002Step2Classification.absent,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nrs2002).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.nrs2002).errorMessage,
          "Não foi possível salvar a triagem NRS-2002. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.nrs2002).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.nrs2002) resets calculatorStatus(CalculatorIds.nrs2002).isError/'
      'calculatorStatus(CalculatorIds.nrs2002).errorMessage',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 45,
        );
        await cubit.init(patientId);
        fakeSaveNrs2002Calculation.resultToReturn = Error("db failure");
        await cubit.saveNrs2002Calculation(
          isSeverelyIll: false,
          weightLossLast3Months: false,
          reducedFoodIntakeLastWeek: false,
          lowBmi: false,
          nutritionalStatusClassification: Nrs2002Step2Classification.absent,
          illnessSeverityClassification: Nrs2002Step2Classification.absent,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.nrs2002).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.nrs2002);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nrs2002).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.nrs2002).errorMessage, isNull);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.nrs2002).isSaved reverts to false after the auto-close '
      'delay',
      () async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 45,
        );
        await cubit.init(patientId);

        await cubit.saveNrs2002Calculation(
          isSeverelyIll: false,
          weightLossLast3Months: false,
          reducedFoodIntakeLastWeek: false,
          lowBmi: false,
          nutritionalStatusClassification: Nrs2002Step2Classification.absent,
          illnessSeverityClassification: Nrs2002Step2Classification.absent,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.nrs2002).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.nrs2002).isSaved, isFalse);
      },
    );
  });

  group('saveStrongKidsCalculation', () {
    test(
      'on success: sets calculatorStatus(CalculatorIds.strongKids).isSaved true and clears '
      'calculatorStatus(CalculatorIds.strongKids).isSaving',
      () async {
        await cubit.init(patientId);

        await cubit.saveStrongKidsCalculation(
          clinicalAppearanceOfMalnutrition: false,
          highRiskDiseasePresent: false,
          reducedIntakeOrLosses: false,
          weightLossOrGrowthDeficit: false,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.strongKids).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.strongKids).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.strongKids).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.strongKids).isError/calculatorStatus(CalculatorIds.strongKids).errorMessage and '
      'clears calculatorStatus(CalculatorIds.strongKids).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveStrongKidsCalculation.resultToReturn = Error("db failure");

        await cubit.saveStrongKidsCalculation(
          clinicalAppearanceOfMalnutrition: false,
          highRiskDiseasePresent: false,
          reducedIntakeOrLosses: false,
          weightLossOrGrowthDeficit: false,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.strongKids).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.strongKids).errorMessage,
          "Não foi possível salvar a triagem STRONG-Kids. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.strongKids).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.strongKids) resets calculatorStatus(CalculatorIds.strongKids).isError/'
      'calculatorStatus(CalculatorIds.strongKids).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveStrongKidsCalculation.resultToReturn = Error("db failure");
        await cubit.saveStrongKidsCalculation(
          clinicalAppearanceOfMalnutrition: false,
          highRiskDiseasePresent: false,
          reducedIntakeOrLosses: false,
          weightLossOrGrowthDeficit: false,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.strongKids).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.strongKids);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.strongKids).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.strongKids).errorMessage, isNull);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.strongKids).isSaved reverts to false after the auto-close '
      'delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveStrongKidsCalculation(
          clinicalAppearanceOfMalnutrition: false,
          highRiskDiseasePresent: false,
          reducedIntakeOrLosses: false,
          weightLossOrGrowthDeficit: false,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.strongKids).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.strongKids).isSaved, isFalse);
      },
    );
  });

  group('saveIdealWeightCalculation', () {
    setUp(() {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(
          createdAt: DateTime.now(),
          value: 70,
          patientId: patientId,
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      ];
      fakeGetHeights.heightsToReturn = [
        HeightEntity(
          createdAt: DateTime.now(),
          value: 170,
          patientId: patientId,
        ),
      ];
    });

    test(
      'on success: sets calculatorStatus(CalculatorIds.idealWeight).isSaved true, clears calculatorStatus(CalculatorIds.idealWeight).isSaving, '
      'refetches weights and recomputes BMI',
      () async {
        await cubit.init(patientId);

        await cubit.saveIdealWeightCalculation(
          gender: Gender.female,
          considerForCalculations: true,
        );
        // saveIdealWeightCalculation's outer Future resolves before the
        // inner async callback's second await (the weights refetch)
        // settles - see _executeOnStateLoaded, which invokes the async
        // callback without awaiting it (same as saveWeight). Pump the
        // microtask queue so the refetch/emit completes.
        await Future.delayed(Duration.zero);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaved, isTrue);
        expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaving, isFalse);
        expect(state.calculatorStatus(CalculatorIds.idealWeight).isError, isFalse);
      },
    );

    test(
      'on error: sets calculatorStatus(CalculatorIds.idealWeight).isError/calculatorStatus(CalculatorIds.idealWeight).errorMessage '
      'and clears calculatorStatus(CalculatorIds.idealWeight).isSaving',
      () async {
        await cubit.init(patientId);
        fakeSaveIdealWeightCalculation.resultToReturn = Error("db failure");

        await cubit.saveIdealWeightCalculation(
          gender: Gender.female,
          considerForCalculations: true,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.idealWeight).isError, isTrue);
        expect(
          state.calculatorStatus(CalculatorIds.idealWeight).errorMessage,
          "Não foi possível salvar o cálculo de Peso Ideal. Tente novamente.",
        );
        expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaving, isFalse);
      },
    );

    test(
      'closedCalculatorErrorModal(CalculatorIds.idealWeight) resets calculatorStatus(CalculatorIds.idealWeight).isError/'
      'calculatorStatus(CalculatorIds.idealWeight).errorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveIdealWeightCalculation.resultToReturn = Error("db failure");
        await cubit.saveIdealWeightCalculation(
          gender: Gender.female,
          considerForCalculations: true,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.idealWeight).isError,
          isTrue,
        );

        cubit.closedCalculatorErrorModal(CalculatorIds.idealWeight);

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.idealWeight).isError, isFalse);
        expect(state.calculatorStatus(CalculatorIds.idealWeight).errorMessage, isNull);
      },
    );

    test('no height data: does nothing', () async {
      fakeGetHeights.heightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveIdealWeightCalculation(
        gender: Gender.female,
        considerForCalculations: true,
      );

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.idealWeight).isError, isFalse);
    });

    test('no weight data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveIdealWeightCalculation(
        gender: Gender.female,
        considerForCalculations: true,
      );

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaving, isFalse);
      expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaved, isFalse);
      expect(state.calculatorStatus(CalculatorIds.idealWeight).isError, isFalse);
    });

    test(
      'resolves weight via ResolveWeightForCalculations: with a newer '
      'weight excluded from calculations and an older one included, the '
      'older (considerForCalculations: true) weight is passed to '
      'SaveIdealWeightCalculationUseCase, not the newest',
      () async {
        fakeGetWeights.weightsToReturn = [
          WeightEntity(
            createdAt: DateTime.now(),
            value: 80,
            patientId: patientId,
            considerForCalculations: false,
            weightType: WeightTypeEnum.measuredByScale,
          ),
          WeightEntity(
            createdAt: DateTime.now().subtract(Duration(days: 10)),
            value: 65,
            patientId: patientId,
            considerForCalculations: true,
            weightType: WeightTypeEnum.measuredByScale,
          ),
        ];
        await cubit.init(patientId);

        await cubit.saveIdealWeightCalculation(
          gender: Gender.female,
          considerForCalculations: true,
        );

        expect(fakeSaveIdealWeightCalculation.lastWeightKg, 65);
      },
    );

    test(
      'on success: calculatorStatus(CalculatorIds.idealWeight).isSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveIdealWeightCalculation(
          gender: Gender.female,
          considerForCalculations: true,
        );
        // Pump the microtask queue so the weights-refetch/emit (the second
        // await in the success path) completes before asserting - see
        // saveWeight's identical precedent.
        await Future.delayed(Duration.zero);
        expect(
          (cubit.state as PatientDetailsStateLoaded).calculatorStatus(CalculatorIds.idealWeight).isSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.calculatorStatus(CalculatorIds.idealWeight).isSaved, isFalse);
      },
    );
  });
}
