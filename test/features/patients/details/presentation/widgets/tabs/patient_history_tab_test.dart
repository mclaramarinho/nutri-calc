import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
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
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_classification_result.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_step_2_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_score_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/create_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/get_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/create_height_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/update_patient_use_case.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_history_tab.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_calc/features/calculators/adequation/domain/use_cases/save_adequation_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/adjusted_obesity/domain/use_cases/save_adjusted_obesity_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/adjusted_dry_weight/domain/use_cases/save_adjusted_dry_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/estimated_weight/domain/use_cases/save_estimated_weight_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/ascitis_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/oedema_level.enum.dart';
import 'package:nutri_calc/shared/utils/enums/ethnicity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/get_patient_calculator_history_use_case.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/delete_calculator_history_entry_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/delete_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/delete_height_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/delete_body_measurement_use_case.dart';

/// Fakes implementing the abstract use-case interfaces directly - no mocking
/// package is set up in this project, matching patient_details_cubit_test.dart.
class _FakeLoadPatientDetailsUseCase implements LoadPatientDetailsUseCase {
  EditPatientFormEntity? formToReturn;

  @override
  Future<Result<EditPatientFormEntity, String>> call(
    String patientLocalId,
  ) async {
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
  @override
  Future<Result<void, String>> call(EditPatientFormEntity form) async =>
      Ok(null);
}

class _FakeGetWeightsUseCase implements GetWeightsUseCase {
  List<WeightEntity> weightsToReturn = [];

  @override
  Future<Result<List<WeightEntity>, String>> call(String patientId) async =>
      Ok(weightsToReturn);
}

class _FakeGetHeightsUseCase implements GetHeightsUseCase {
  List<HeightEntity> heightsToReturn = [];

  @override
  Future<Result<List<HeightEntity>, String>> call(String patientId) async =>
      Ok(heightsToReturn);
}

class _FakeGetBodyMeasurementUseCase implements GetBodyMeasurementUseCase {
  @override
  Future<Result<List<BodyMeasurementEntity>, String>> call(
    String patientId,
  ) async => Ok(const []);
}

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async => Ok(weight);
}

class _FakeCreateHeightUseCase implements CreateHeightUseCase {
  @override
  Future<Result<HeightEntity, String>> call({
    required HeightEntity height,
  }) async => Ok(height);
}

class _FakeCreateBodyMeasurementUseCase
    implements CreateBodyMeasurementUseCase {
  @override
  Future<Result<BodyMeasurementEntity, String>> call(
    BodyMeasurementEntity entity,
  ) async => Ok(entity);
}

class _FakeSaveBmiCalculationUseCase implements SaveBmiCalculationUseCase {
  int callCount = 0;

  @override
  Future<Result<BmiCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double heightM,
    required int age,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

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
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<NitrogenBalanceCalculationEntity, String>> call({
    required String patientId,
    required double ingestedProtein,
    required double urineNitrogen24h,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<ProteinNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required PatientState patientState,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<WaterNeedsCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required int age,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>> call({
    required String patientId,
    required double totalVolume,
    required double totalHoursForVolume,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<EnteralNutritionSpeedCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyVolume,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>> call({
    required String patientId,
    required double totalDailyEnergy,
    required double caloricDensityOfDiet,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<GlucoseInfusionRateCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double totalGlucose,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<WeightLossClassificationCalculationEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required DateTime currentWeightDate,
    required double lastWeight,
    required DateTime lastWeightDate,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<MustCalculationEntity, String>> call({
    required String patientId,
    required double bmi,
    required double avgWeightLossIn3To6Months,
    required bool severeIllnessPresent,
    required bool reducedFoodIntakeForMoreThan5Days,
    required bool willReduceFoodIntakeForMoreThan5Days,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

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
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<StrongKidsCalculationEntity, String>> call({
    required String patientId,
    required bool clinicalAppearanceOfMalnutrition,
    required bool highRiskDiseasePresent,
    required bool reducedIntakeOrLosses,
    required bool weightLossOrGrowthDeficit,
  }) async {
    callCount++;
    return Ok(
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
  int callCount = 0;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double heightCm,
    required Gender gender,
    required double weightKg,
    required bool considerForCalculations,
  }) async {
    callCount++;
    return Ok(
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

class _FakeSaveAdequationCalculationUseCase
    implements SaveAdequationCalculationUseCase {
  int callCount = 0;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required double idealWeight,
    required bool considerForCalculations,
  }) async {
    callCount++;
    return Ok(
      WeightEntity(
        id: 'adeq-1',
        createdAt: DateTime.now(),
        value: 100.0,
        patientId: patientId,
        considerForCalculations: considerForCalculations,
        weightType: WeightTypeEnum.adequation,
      ),
    );
  }
}

class _FakeSaveAdjustedObesityCalculationUseCase
    implements SaveAdjustedObesityCalculationUseCase {
  int callCount = 0;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required double idealWeight,
    required bool considerForCalculations,
  }) async {
    callCount++;
    return Ok(
      WeightEntity(
        id: 'adjobes-1',
        createdAt: DateTime.now(),
        value: 70.0,
        patientId: patientId,
        considerForCalculations: considerForCalculations,
        weightType: WeightTypeEnum.adjustedObesity,
      ),
    );
  }
}

class _FakeSaveAdjustedDryWeightCalculationUseCase
    implements SaveAdjustedDryWeightCalculationUseCase {
  int callCount = 0;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double currentWeight,
    required Bmi imc,
    AscitisLevel? ascitis,
    OedemaLevel? oedema,
    required bool considerForCalculations,
  }) async {
    callCount++;
    return Ok(
      WeightEntity(
        id: 'adjdry-1',
        createdAt: DateTime.now(),
        value: 70.0,
        patientId: patientId,
        considerForCalculations: considerForCalculations,
        weightType: WeightTypeEnum.adjustedDryWeight,
      ),
    );
  }
}

class _FakeSaveEstimatedWeightCalculationUseCase
    implements SaveEstimatedWeightCalculationUseCase {
  int callCount = 0;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double kneeHeight,
    required double armCircumference,
    required Gender gender,
    required int age,
    required Ethnicity ethnicity,
    required bool considerForCalculations,
  }) async {
    callCount++;
    return Ok(
      WeightEntity(
        id: 'est-1',
        createdAt: DateTime.now(),
        value: 70.0,
        patientId: patientId,
        considerForCalculations: considerForCalculations,
        weightType: WeightTypeEnum.estimated,
      ),
    );
  }
}

/// Pops via the Navigator wired to [navigatorKey], mirroring how a real
/// GoRouter-backed AppRouter.pop() closes the DsBottomSheet's modal route -
/// needed so DsBottomSheet.show's returned Future actually resolves in tests.
class _FakeAppRouter implements AppRouter {
  _FakeAppRouter(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }

  @override
  BuildContext? get context => navigatorKey.currentContext;

  @override
  AppRoutes? get currentRoute => null;

  @override
  Object? get params => null;

  @override
  void push(AppRoutes route, {Map<String, dynamic>? params}) {}

  @override
  void replace(AppRoutes route, {Map<String, dynamic>? params}) {}

  @override
  GoRouter get router => throw UnimplementedError();
}

class _FakeGetPatientCalculatorHistoryUseCase
    implements GetPatientCalculatorHistoryUseCase {
  List<HistoryEntryEntity> historyToReturn = [];

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(
    String patientId,
  ) async {
    return Ok(historyToReturn);
  }
}

class _FakeDeleteCalculatorHistoryEntryUseCase
    implements DeleteCalculatorHistoryEntryUseCase {
  Result<void, String> resultToReturn = const Ok(null);

  @override
  Future<Result<void, String>> call(HistoryEntryEntity entry) async {
    return resultToReturn;
  }
}

class _FakeDeleteWeightUseCase implements DeleteWeightUseCase {
  Result<void, String> resultToReturn = const Ok(null);

  @override
  Future<Result<void, String>> call(String id) async {
    return resultToReturn;
  }
}

class _FakeDeleteHeightUseCase implements DeleteHeightUseCase {
  Result<void, String> resultToReturn = const Ok(null);

  @override
  Future<Result<void, String>> call(String id) async {
    return resultToReturn;
  }
}

class _FakeDeleteBodyMeasurementUseCase
    implements DeleteBodyMeasurementUseCase {
  Result<void, String> resultToReturn = const Ok(null);

  @override
  Future<Result<void, String>> call(String id) async {
    return resultToReturn;
  }
}

void main() {
  const patientId = "local-id-1";

  late _FakeLoadPatientDetailsUseCase fakeLoad;
  late _FakeGetWeightsUseCase fakeGetWeights;
  late _FakeGetHeightsUseCase fakeGetHeights;
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
  late _FakeSaveAdequationCalculationUseCase fakeSaveAdequationCalculation;
  late _FakeSaveAdjustedObesityCalculationUseCase
  fakeSaveAdjustedObesityCalculation;
  late _FakeSaveAdjustedDryWeightCalculationUseCase
  fakeSaveAdjustedDryWeightCalculation;
  late _FakeSaveEstimatedWeightCalculationUseCase
  fakeSaveEstimatedWeightCalculation;
  late PatientDetailsCubit cubit;
  late _FakeGetPatientCalculatorHistoryUseCase fakeGetHistory;
  final navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    fakeGetHistory = _FakeGetPatientCalculatorHistoryUseCase();
    fakeLoad = _FakeLoadPatientDetailsUseCase();
    fakeGetWeights = _FakeGetWeightsUseCase();
    fakeGetHeights = _FakeGetHeightsUseCase();
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
    fakeSaveAdequationCalculation = _FakeSaveAdequationCalculationUseCase();
    fakeSaveAdjustedObesityCalculation =
        _FakeSaveAdjustedObesityCalculationUseCase();
    fakeSaveAdjustedDryWeightCalculation =
        _FakeSaveAdjustedDryWeightCalculationUseCase();
    fakeSaveEstimatedWeightCalculation =
        _FakeSaveEstimatedWeightCalculationUseCase();

    cubit = PatientDetailsCubit(
      getPatientCalculatorHistoryUseCase: fakeGetHistory,
      deleteCalculatorHistoryEntryUseCase: _FakeDeleteCalculatorHistoryEntryUseCase(),
      deleteWeightUseCase: _FakeDeleteWeightUseCase(),
      deleteHeightUseCase: _FakeDeleteHeightUseCase(),
      deleteBodyMeasurementUseCase: _FakeDeleteBodyMeasurementUseCase(),
      loadPatientDetailsUseCase: fakeLoad,
      updatePatientUseCase: _FakeUpdatePatientUseCase(),
      createWeightUseCase: _FakeCreateWeightUseCase(),
      getWeightsUseCase: fakeGetWeights,
      createHeightUseCase: _FakeCreateHeightUseCase(),
      getHeightsUseCase: fakeGetHeights,
      createBodyMeasurementUseCase: _FakeCreateBodyMeasurementUseCase(),
      getBodyMeasurementUseCase: _FakeGetBodyMeasurementUseCase(),
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
      saveAdequationCalculationUseCase: fakeSaveAdequationCalculation,
      saveAdjustedObesityCalculationUseCase:
          fakeSaveAdjustedObesityCalculation,
      saveAdjustedDryWeightCalculationUseCase:
          fakeSaveAdjustedDryWeightCalculation,
      saveEstimatedWeightCalculationUseCase:
          fakeSaveEstimatedWeightCalculation,
    );

    getIt.registerSingleton<AppRouter>(_FakeAppRouter(navigatorKey));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget wrap() => MaterialApp(
    navigatorKey: navigatorKey,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        DsScreenAdapter.init(context);
        return Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const PatientHistoryTab(),
          ),
        );
      },
    ),
  );

  group('PatientHistoryTab (Slice 11)', () {
    HistoryEntryEntity entry({
      required String id,
      required CalculatorType type,
      required HistorySourceType sourceType,
      required String label,
      DateTime? createdAt,
    }) => HistoryEntryEntity(
      id: id,
      patientId: patientId,
      type: type,
      sourceType: sourceType,
      label: label,
      resultSummary: '$label summary',
      inputParams: const [],
      createdAt: createdAt ?? DateTime(2026, 1, 1),
    );

    testWidgets(
      'all-empty history shows "Sem histórico de cálculos para esse '
      'paciente" instead of the grouped list',
      (tester) async {
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(
          find.text('Sem histórico de cálculos para esse paciente'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a CalculatorType with zero results does not render its group header '
      'at all (only groups with >=1 entry are shown)',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: 'Ana',
          lastName: 'Silva',
          patientLocalId: patientId,
        );
        // Only BMI has entries; every other CalculatorType (Weight, Energy
        // Expenditure, Enteral Nutrition, Screening, etc.) has none.
        fakeGetHistory.historyToReturn = [
          entry(
            id: 'bmi1',
            type: CalculatorType.bmi,
            sourceType: HistorySourceType.bmi,
            label: 'IMC',
          ),
        ];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        // BMI's group header ("IMC") is rendered...
        expect(find.text('IMC'), findsWidgets);
        // ...but no other CalculatorType's group header is - e.g. "Peso"
        // (Weight) never appears anywhere, since it has zero entries.
        expect(find.text(CalculatorType.weight.label), findsNothing);
        expect(find.text(CalculatorType.screening.label), findsNothing);
        expect(find.text(CalculatorType.waterNeeds.label), findsNothing);
        expect(
          find.text('Sem histórico de cálculos para esse paciente'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'multiple non-empty groups (some empty, some not) render only the '
      'non-empty ones, latest-first within a group',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: 'Ana',
          lastName: 'Silva',
          patientLocalId: patientId,
        );
        fakeGetHistory.historyToReturn = [
          entry(
            id: 'bmi-old',
            type: CalculatorType.bmi,
            sourceType: HistorySourceType.bmi,
            label: 'IMC',
            createdAt: DateTime(2026, 1, 1),
          ),
          entry(
            id: 'bmi-new',
            type: CalculatorType.bmi,
            sourceType: HistorySourceType.bmi,
            label: 'IMC',
            createdAt: DateTime(2026, 6, 1),
          ),
          entry(
            id: 'must1',
            type: CalculatorType.screening,
            sourceType: HistorySourceType.must,
            label: 'MUST',
            createdAt: DateTime(2026, 3, 1),
          ),
        ];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(find.text('IMC'), findsWidgets);
        expect(find.text(CalculatorType.screening.label), findsOneWidget);
        expect(find.text(CalculatorType.weight.label), findsNothing);
        expect(find.text(CalculatorType.waterNeeds.label), findsNothing);

        // Both BMI entries render (subtitle text includes the
        // resultSummary "IMC summary" followed by the formatted date).
        expect(find.textContaining('IMC summary'), findsNWidgets(2));
      },
    );

    testWidgets(
      'tapping an entry opens a DsBottomSheet showing its inputParams and '
      'result',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: 'Ana',
          lastName: 'Silva',
          patientLocalId: patientId,
        );
        fakeGetHistory.historyToReturn = [
          HistoryEntryEntity(
            id: 'bmi1',
            patientId: patientId,
            type: CalculatorType.bmi,
            sourceType: HistorySourceType.bmi,
            label: 'IMC',
            resultSummary: 'IMC: 22.0',
            inputParams: const [
              InputParamEntity(key: 'weight_kg', label: 'Peso', value: '70 kg'),
              InputParamEntity(key: 'height_m', label: 'Altura', value: '1.75 m'),
            ],
            createdAt: DateTime(2026, 1, 1),
          ),
        ];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        // 'IMC' appears twice: once as the group header, once as the
        // DsListTile's title (entry.label) - the tile is the tappable one.
        await tester.tap(find.text('IMC').last);
        await tester.pumpAndSettle();

        expect(find.text('Peso: 70 kg'), findsOneWidget);
        expect(find.text('Altura: 1.75 m'), findsOneWidget);
        expect(find.text('IMC: 22.0'), findsOneWidget);
        expect(find.text('Fechar'), findsOneWidget);

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(find.text('Fechar'), findsNothing);
      },
    );
  });
}
