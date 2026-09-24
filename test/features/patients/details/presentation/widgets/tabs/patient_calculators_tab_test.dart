import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
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
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_calculators_tab.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:go_router/go_router.dart';

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
  late PatientDetailsCubit cubit;
  final navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
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

    cubit = PatientDetailsCubit(
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
    );

    getIt.registerSingleton<AppRouter>(_FakeAppRouter(navigatorKey));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget wrap() => MaterialApp(
    navigatorKey: navigatorKey,
    home: Builder(
      builder: (context) {
        DsScreenAdapter.init(context);
        return Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const PatientCalculatorsTab(),
          ),
        );
      },
    ),
  );

  group('PatientCalculatorsTab', () {
    testWidgets(
      'BMI tap-flow regression: insufficient data shows message and does '
      'not call saveBmiCalculation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
        fakeGetWeights.weightsToReturn = [];
        fakeGetHeights.heightsToReturn = [];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('IMC'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Não há dados suficientes para calcular o IMC. Cadastre ao "
            "menos um peso e uma altura para esse paciente.",
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(fakeSaveBmiCalculation.callCount, 0);
      },
    );

    testWidgets(
      'BMI tap-flow regression: preview shown, Confirmar calls '
      'cubit.saveBmiCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
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
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('IMC'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isBmiSaved auto-reset delay in
        // PatientDetailsCubit.saveBmiCalculation so no pending Timer leaks
        // past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveBmiCalculation.callCount, 1);
      },
    );

    testWidgets(
      'age < 19, not hospitalized/confined -> relevant list only shows the '
      'always-relevant calculators (Protein Needs, Water Needs), toggle '
      'reveals every calculator under their group headers',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 10,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        // Protein Needs, Water Needs (always relevant) and STRONG-Kids
        // (age < 19, added Slice 7) are relevant even though BMI/Energy
        // Expenditure/Nitrogen Balance/MUST/NRS-2002 don't qualify here.
        expect(
          find.text('Nenhuma calculadora relevante no momento.'),
          findsNothing,
        );
        expect(find.byType(DsListTile), findsNWidgets(3));

        await tester.tap(find.byType(DsButton));
        await tester.pumpAndSettle();

        // "IMC" is both the group header (CalculatorType.bmi.label) and the
        // tile title (the definition's name) - genuine collision, not a
        // test bug. Likewise for "Gasto Energético" (Energy Expenditure) and
        // "Balanço Nitrogenado" (Nitrogen Balance). "Necessidade Proteica"/
        // "Necessidade Hídrica" tile titles don't collide with their group
        // headers ("Necessidades Proteicas"/"Necessidades Hídricas" -
        // singular vs plural, the known Slice 2/3 cosmetic mismatch).
        expect(find.text('IMC'), findsNWidgets(2));
        expect(find.text('Gasto Energético'), findsNWidgets(2));
        expect(find.text('Balanço Nitrogenado'), findsNWidgets(2));
        // Slice 5 added 4 more calculators (Enteral Nutrition Dripping/
        // Speed/Volume, Glucose Infusion Rate), none relevant for this
        // patient (not on enteral/parenteral nutrition); Slice 6 added
        // Weight Loss Classification (not relevant - no weights registered);
        // Slice 7 added MUST/NRS-2002/STRONG-Kids (3 more). All still shown
        // by "See All": 5 pre-slice-5 tiles + 4 slice-5 + 1 slice-6 + 3
        // slice-7.
        expect(find.byType(DsListTile), findsNWidgets(13));
      },
    );

    testWidgets(
      'age 25+ with weight/height -> BMI, Protein Needs and Water Needs '
      'shown directly in flat view, tap still works',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
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
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        // BMI + MUST (both age >= 19, MUST added Slice 7) + Protein
        // Needs/Water Needs (always relevant). NRS-2002 also needs age >= 19
        // but additionally requires `hospitalized`, not set here.
        expect(find.byType(DsListTile), findsNWidgets(4));
        expect(find.text('IMC'), findsOneWidget);

        await tester.tap(find.text('IMC'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
      },
    );

    testWidgets(
      'Energy Expenditure pre-gate: no weight data shows the '
      'insufficient-data message and Fechar closes it without crashing or '
      'calling saveEnergyExpenditureCalculation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          hospitalized: true,
        );
        fakeGetWeights.weightsToReturn = [];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Gasto Energético'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Não há dados suficientes para calcular o gasto energético. "
            "Cadastre ao menos um peso para esse paciente.",
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(fakeSaveEnergyExpenditureCalculation.callCount, 0);
      },
    );

    testWidgets(
      'Energy Expenditure tap-flow regression (Pocket formula): selecting '
      'Pocket, calculating and confirming calls '
      'cubit.saveEnergyExpenditureCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          hospitalized: true,
        );
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

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Gasto Energético'));
        await tester.pumpAndSettle();

        // Step 1: pick the "Fórmula de Bolso" (Pocket) formula from the
        // Fórmula DsSelect dropdown - the simplest formula (weight only).
        // Tapping the DropdownMenuFormField itself (rather than its "Fórmula"
        // label Text, which sits over the underlying TextField and can miss
        // the hit test) reliably opens the menu.
        await tester.tap(
          find.byType(DropdownMenuFormField<EnergyExpenditureFormulaEnum>),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Fórmula de Bolso').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        // Step 2: confirm the preview.
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isEnergyExpenditureSaved auto-reset delay in
        // PatientDetailsCubit.saveEnergyExpenditureCalculation so no pending
        // Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveEnergyExpenditureCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Nitrogen Balance tap-flow: filling both fields, calculating and '
      'confirming calls cubit.saveNitrogenBalanceCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          hospitalized: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Balanço Nitrogenado'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), '90');
        await tester.enterText(find.byType(TextFormField).at(1), '10');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isNitrogenBalanceSaved auto-reset delay in
        // PatientDetailsCubit.saveNitrogenBalanceCalculation so no pending
        // Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveNitrogenBalanceCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Nitrogen Balance "Calcular" DsButton stays disabled for empty inputs '
      'and for negative input values',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          hospitalized: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Balanço Nitrogenado'));
        await tester.pumpAndSettle();

        // Empty inputs (both fields blank): "Calcular" must be disabled.
        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        // Negative input values: "Calcular" must remain disabled.
        await tester.enterText(find.byType(TextFormField).at(0), '-5');
        await tester.enterText(find.byType(TextFormField).at(1), '-5');
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        // Tapping the disabled button produces no effect: no preview shown.
        await tester.tap(find.text('Calcular'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('Confirmar'), findsNothing);
      },
    );

    testWidgets(
      'Protein Needs pre-gate: no weight data shows the insufficient-data '
      'message and Fechar closes it without calling '
      'saveProteinNeedsCalculation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
        fakeGetWeights.weightsToReturn = [];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Necessidade Proteica'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Não há dados suficientes para calcular a necessidade proteica. "
            "Cadastre ao menos um peso para esse paciente.",
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(fakeSaveProteinNeedsCalculation.callCount, 0);
      },
    );

    testWidgets(
      'Protein Needs tap-flow: selecting a patient state, calculating and '
      'confirming calls cubit.saveProteinNeedsCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
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

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Necessidade Proteica'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(DropdownMenuFormField<PatientState>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(PatientState.healthy.label).last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isProteinNeedsSaved auto-reset delay in
        // PatientDetailsCubit.saveProteinNeedsCalculation so no pending
        // Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveProteinNeedsCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Water Needs pre-gate: no weight/age data shows the insufficient-data '
      'message and Fechar closes it without calling '
      'saveWaterNeedsCalculation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
        );
        fakeGetWeights.weightsToReturn = [];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Necessidade Hídrica'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Não há dados suficientes para calcular a necessidade hídrica. "
            "Cadastre ao menos um peso e a idade desse paciente.",
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(fakeSaveWaterNeedsCalculation.callCount, 0);
      },
    );

    testWidgets(
      'Water Needs tap-flow: preview shown, Confirmar calls '
      'cubit.saveWaterNeedsCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
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

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Necessidade Hídrica'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isWaterNeedsSaved auto-reset delay in
        // PatientDetailsCubit.saveWaterNeedsCalculation so no pending Timer
        // leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveWaterNeedsCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Enteral Nutrition Dripping tap-flow: filling both fields, '
      'calculating and confirming calls '
      'cubit.saveEnteralNutritionDrippingCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          enteralNutrition: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Gotejamento'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), '1000');
        await tester.enterText(find.byType(TextFormField).at(1), '8');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isEnteralNutritionDrippingSaved auto-reset delay in
        // PatientDetailsCubit.saveEnteralNutritionDrippingCalculation so no
        // pending Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveEnteralNutritionDrippingCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Enteral Nutrition Dripping "Calcular" DsButton stays disabled for '
      'zero/negative Tempo Total (h) - strict >0 denominator validation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          enteralNutrition: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Gotejamento'));
        await tester.pumpAndSettle();

        // Volume Total valid, Tempo Total (h) == 0 - must stay disabled
        // (the denominator is the "strict >0" field).
        await tester.enterText(find.byType(TextFormField).at(0), '1000');
        await tester.enterText(find.byType(TextFormField).at(1), '0');
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        await tester.tap(find.text('Calcular'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('Confirmar'), findsNothing);
      },
    );

    testWidgets(
      'Enteral Nutrition Speed tap-flow: filling the field, calculating and '
      'confirming calls cubit.saveEnteralNutritionSpeedCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          enteralNutrition: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Velocidade de Infusão'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), '2000');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isEnteralNutritionSpeedSaved auto-reset delay in
        // PatientDetailsCubit.saveEnteralNutritionSpeedCalculation so no
        // pending Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveEnteralNutritionSpeedCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Enteral Nutrition Volume tap-flow: filling both fields, calculating '
      'and confirming calls cubit.saveEnteralNutritionVolumeCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          enteralNutrition: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Volume Total'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), '2000');
        await tester.enterText(find.byType(TextFormField).at(1), '1.5');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isEnteralNutritionVolumeSaved auto-reset delay in
        // PatientDetailsCubit.saveEnteralNutritionVolumeCalculation so no
        // pending Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveEnteralNutritionVolumeCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Enteral Nutrition Volume "Calcular" DsButton stays disabled for '
      'zero/negative Densidade Calórica da Dieta - strict >0 denominator '
      'validation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          enteralNutrition: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Volume Total'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), '2000');
        await tester.enterText(find.byType(TextFormField).at(1), '0');
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        await tester.tap(find.text('Calcular'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('Confirmar'), findsNothing);
      },
    );

    testWidgets(
      'Glucose Infusion Rate pre-gate: no weight data shows the '
      'insufficient-data message and Fechar closes it without calling '
      'saveGlucoseInfusionRateCalculation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          parenteralNutrition: true,
        );
        fakeGetWeights.weightsToReturn = [];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('TIG'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Não há dados suficientes para calcular a TIG. Cadastre ao "
            "menos um peso para esse paciente.",
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(fakeSaveGlucoseInfusionRateCalculation.callCount, 0);
      },
    );

    testWidgets(
      'Glucose Infusion Rate tap-flow: weight derived from the latest '
      'WeightEntity, zero Glicose Total is allowed, confirming calls '
      'cubit.saveGlucoseInfusionRateCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          parenteralNutrition: true,
        );
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

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('TIG'));
        await tester.pumpAndSettle();

        // Derived weight is shown read-only, not editable.
        expect(find.text('Peso: 70.0 kg'), findsOneWidget);

        // Zero must be allowed (matches the pure-math use case's own >= 0
        // guard) - "Calcular" must become enabled, not stay disabled.
        await tester.enterText(find.byType(TextFormField).at(0), '0');
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isFalse,
        );

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isGlucoseInfusionRateSaved auto-reset delay in
        // PatientDetailsCubit.saveGlucoseInfusionRateCalculation so no
        // pending Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveGlucoseInfusionRateCalculation.callCount, 1);
      },
    );

    testWidgets(
      'Glucose Infusion Rate "Calcular" DsButton stays disabled for '
      'negative Glicose Total (only >= 0 is allowed)',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          parenteralNutrition: true,
        );
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

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('TIG'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), '-5');
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        await tester.tap(find.text('Calcular'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('Confirmar'), findsNothing);
      },
    );

    testWidgets(
      'Weight Loss Classification pre-gate: fewer than 2 weights shows the '
      'insufficient-data message and Fechar closes it without calling '
      'saveWeightLossClassificationCalculation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
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

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        // Not relevant on its own (only 1 weight registered) - reach it via
        // "Ver todas as calculadoras".
        await tester.tap(find.text('Ver todas as calculadoras'));
        await tester.pumpAndSettle();

        // Slice 7's "Triagem" group (screening tools) sorts before
        // "Classificação de Perda de Peso" in CalculatorType enum order,
        // pushing this tile below the fixed test viewport - scroll it into
        // view before tapping.
        await tester.ensureVisible(
          find.text('Classificação de Perda de Peso').last,
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Classificação de Perda de Peso').last);
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Não há dados suficientes para calcular a Classificação de "
            "Perda de Peso. Cadastre ao menos dois pesos para esse "
            "paciente.",
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(fakeSaveWeightLossClassificationCalculation.callCount, 0);
      },
    );

    testWidgets(
      'Weight Loss Classification tap-flow: preview shown with both '
      'weights/dates, Confirmar calls '
      'cubit.saveWeightLossClassificationCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
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
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Classificação de Perda de Peso').first);
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isWeightLossClassificationSaved auto-reset delay in
        // PatientDetailsCubit.saveWeightLossClassificationCalculation so no
        // pending Timer leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveWeightLossClassificationCalculation.callCount, 1);
      },
    );

    testWidgets(
      'MUST tap-flow: filling BMI/weight-loss fields, calculating and '
      'confirming calls cubit.saveMustCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('MUST'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField).at(0), '19');
        await tester.enterText(find.byType(TextFormField).at(1), '3');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isMustSaved auto-reset delay in
        // PatientDetailsCubit.saveMustCalculation so no pending Timer leaks
        // past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveMustCalculation.callCount, 1);
      },
    );

    testWidgets(
      'NRS-2002 tap-flow: selecting both classification dropdowns, '
      'calculating and confirming calls cubit.saveNrs2002Calculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          hospitalized: true,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('NRS-2002'));
        await tester.pumpAndSettle();

        final dropdowns = find.byType(
          DropdownMenuFormField<Nrs2002Step2Classification>,
        );

        await tester.tap(dropdowns.at(0));
        await tester.pumpAndSettle();
        await tester
            .tap(find.text('Ausente - estado nutricional normal').last);
        await tester.pumpAndSettle();

        await tester.tap(dropdowns.at(1));
        await tester.pumpAndSettle();
        await tester
            .tap(find.text('Ausente - estado nutricional normal').last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isNrs2002Saved auto-reset delay in
        // PatientDetailsCubit.saveNrs2002Calculation so no pending Timer
        // leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveNrs2002Calculation.callCount, 1);
      },
    );

    testWidgets(
      'STRONG-Kids tap-flow: answering all 4 questions, calculating and '
      'confirming calls cubit.saveStrongKidsCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 10,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('STRONG-Kids'));
        await tester.pumpAndSettle();

        // "Calcular" starts disabled until all 4 questions are explicitly
        // answered (RESOLVED UX decision - see StrongKidsSheetBody).
        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        for (final checkbox in find.byType(Checkbox).evaluate().toList()) {
          await tester.tap(find.byWidget(checkbox.widget));
          await tester.pumpAndSettle();
        }

        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isFalse,
        );

        await tester.tap(find.text('Calcular'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isStrongKidsSaved auto-reset delay in
        // PatientDetailsCubit.saveStrongKidsCalculation so no pending Timer
        // leaks past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveStrongKidsCalculation.callCount, 1);
      },
    );

    testWidgets(
      'STRONG-Kids Calcular gating: disabled until all 4 questions are '
      'explicitly answered - answering 3 of 4 keeps it disabled, and '
      'answering all 4 even as "Não" enables it (nullable bool? per-question '
      'state, not a silent default-to-false)',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 10,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('STRONG-Kids'));
        await tester.pumpAndSettle();

        // Untouched: disabled.
        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        final checkboxes = find.byType(Checkbox).evaluate().toList();
        expect(checkboxes.length, 4);

        // Answer only 3 of the 4 questions: still disabled.
        for (final checkbox in checkboxes.take(3)) {
          await tester.tap(find.byWidget(checkbox.widget));
          await tester.pumpAndSettle();
        }
        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isTrue,
        );

        // Answer the 4th question, then flip every answer back to "Não"
        // (each checkbox: unanswered -> "Sim" -> "Não") so every question
        // ends up explicitly answered false, not just left untouched.
        final allCheckboxes = find.byType(Checkbox).evaluate().toList();
        await tester.tap(find.byWidget(allCheckboxes[3].widget));
        await tester.pumpAndSettle();

        for (final checkbox in find.byType(Checkbox).evaluate().toList()) {
          await tester.tap(find.byWidget(checkbox.widget));
          await tester.pumpAndSettle();
        }

        // All 4 questions explicitly answered "Não" (false): Calcular must
        // enable - a missing gate would silently default each question to
        // false and never distinguish "answered no" from "untouched".
        expect(
          tester
              .widget<DsButton>(find.widgetWithText(DsButton, 'Calcular'))
              .disabled,
          isFalse,
        );
      },
    );
  });
}
