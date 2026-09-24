import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/save_bmi_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/save_energy_expenditure_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/save_enteral_nutrition_dripping_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/save_enteral_nutrition_speed_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/save_enteral_nutrition_volume_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/save_glucose_infusion_rate_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/ideal_weight/domain/use_cases/save_ideal_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/must/domain/entities/must_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/must/domain/use_cases/save_must_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/save_nitrogen_balance_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/entities/nrs_2002_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/use_cases/save_nrs_2002_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/save_protein_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/entities/strong_kids_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/use_cases/save_strong_kids_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/save_water_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/save_weight_loss_classification_calculation_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/create_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/get_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/create_height_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/update_patient_use_case.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/pages/patient_details_page.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_classification_result.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_step_2_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_score_classification.enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

/// Full-page test exercising `PatientDetailsPage`'s real `BlocConsumer`
/// (`listenWhen`/`listener`), not just the cubit or an isolated tab widget.
///
/// This is the layer where Slice 6's real bug lived: the cubit state fields
/// existed and were correct, but the page-level `listenWhen`/`listener`
/// branch that turns a state transition into a `DsDialog` was missing. A
/// cubit-only test (asserting on `cubit.state`) or a `PatientCalculatorsTab`
/// widget test (which never mounts `PatientDetailsPage`'s `BlocConsumer`)
/// cannot catch that class of bug - only a test that pumps the real page and
/// asserts a dialog actually appears can.
///
/// Only the MUST/NRS-2002/STRONG-Kids success+error transitions are covered
/// here (Slice 7's new wiring); the equivalent coverage for every earlier
/// calculator's listener branch is a pre-existing gap this test does not
/// attempt to backfill.
class _FakeLoadPatientDetailsUseCase implements LoadPatientDetailsUseCase {
  EditPatientFormEntity? formToReturn;

  @override
  Future<Result<EditPatientFormEntity, String>> call(
    String patientLocalId,
  ) async => Ok(
    formToReturn ??
        EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientLocalId,
        ),
  );
}

class _FakeUpdatePatientUseCase implements UpdatePatientUseCase {
  @override
  Future<Result<void, String>> call(EditPatientFormEntity form) async =>
      Ok(null);
}

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async => Ok(weight);
}

class _FakeGetWeightsUseCase implements GetWeightsUseCase {
  List<WeightEntity> weightsToReturn = const [];

  @override
  Future<Result<List<WeightEntity>, String>> call(String patientId) async =>
      Ok(weightsToReturn);
}

class _FakeCreateHeightUseCase implements CreateHeightUseCase {
  @override
  Future<Result<HeightEntity, String>> call({
    required HeightEntity height,
  }) async => Ok(height);
}

class _FakeGetHeightsUseCase implements GetHeightsUseCase {
  List<HeightEntity> heightsToReturn = const [];

  @override
  Future<Result<List<HeightEntity>, String>> call(String patientId) async =>
      Ok(heightsToReturn);
}

class _FakeCreateBodyMeasurementUseCase
    implements CreateBodyMeasurementUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGetBodyMeasurementUseCase implements GetBodyMeasurementUseCase {
  @override
  Future<Result<List<BodyMeasurementEntity>, String>> call(
    String patientId,
  ) async => Ok(const []);
}

class _FakeSaveBmiCalculationUseCase implements SaveBmiCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveEnergyExpenditureCalculationUseCase
    implements SaveEnergyExpenditureCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveNitrogenBalanceCalculationUseCase
    implements SaveNitrogenBalanceCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveProteinNeedsCalculationUseCase
    implements SaveProteinNeedsCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveWaterNeedsCalculationUseCase
    implements SaveWaterNeedsCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveEnteralNutritionDrippingCalculationUseCase
    implements SaveEnteralNutritionDrippingCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveEnteralNutritionSpeedCalculationUseCase
    implements SaveEnteralNutritionSpeedCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveEnteralNutritionVolumeCalculationUseCase
    implements SaveEnteralNutritionVolumeCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveGlucoseInfusionRateCalculationUseCase
    implements SaveGlucoseInfusionRateCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeSaveWeightLossClassificationCalculationUseCase
    implements SaveWeightLossClassificationCalculationUseCase {
  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
  }) async =>
      resultToReturn ??
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
  }) async =>
      resultToReturn ??
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
  }) async =>
      resultToReturn ??
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

class _FakeSaveIdealWeightCalculationUseCase
    implements SaveIdealWeightCalculationUseCase {
  Result<WeightEntity, String>? resultToReturn;

  @override
  Future<Result<WeightEntity, String>> call({
    required String patientId,
    required double heightCm,
    required Gender gender,
    required double weightKg,
    required bool considerForCalculations,
  }) async =>
      resultToReturn ??
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

class _FakeAppRouter implements AppRouter {
  _FakeAppRouter(this._params);

  final Map<String, dynamic> _params;

  @override
  void pop<T extends Object?>([T? result]) {}

  @override
  BuildContext? get context => null;

  @override
  AppRoutes? get currentRoute => null;

  @override
  Object? get params => _params;

  @override
  void push(AppRoutes route, {Map<String, dynamic>? params}) {}

  @override
  void replace(AppRoutes route, {Map<String, dynamic>? params}) {}

  @override
  GoRouter get router => throw UnimplementedError();
}

void main() {
  const patientId = "local-id-1";

  late _FakeSaveMustCalculationUseCase fakeSaveMustCalculation;
  late _FakeSaveNrs2002CalculationUseCase fakeSaveNrs2002Calculation;
  late _FakeSaveStrongKidsCalculationUseCase fakeSaveStrongKidsCalculation;
  late _FakeSaveIdealWeightCalculationUseCase fakeSaveIdealWeightCalculation;
  late _FakeGetWeightsUseCase fakeGetWeights;
  late _FakeGetHeightsUseCase fakeGetHeights;
  late PatientDetailsCubit cubit;

  setUp(() {
    fakeSaveMustCalculation = _FakeSaveMustCalculationUseCase();
    fakeSaveNrs2002Calculation = _FakeSaveNrs2002CalculationUseCase();
    fakeSaveStrongKidsCalculation = _FakeSaveStrongKidsCalculationUseCase();
    fakeSaveIdealWeightCalculation = _FakeSaveIdealWeightCalculationUseCase();
    fakeGetWeights = _FakeGetWeightsUseCase();
    fakeGetHeights = _FakeGetHeightsUseCase();

    cubit = PatientDetailsCubit(
      loadPatientDetailsUseCase: _FakeLoadPatientDetailsUseCase()
        ..formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
          hospitalized: true,
        ),
      updatePatientUseCase: _FakeUpdatePatientUseCase(),
      createWeightUseCase: _FakeCreateWeightUseCase(),
      getWeightsUseCase: fakeGetWeights,
      createHeightUseCase: _FakeCreateHeightUseCase(),
      getHeightsUseCase: fakeGetHeights,
      createBodyMeasurementUseCase: _FakeCreateBodyMeasurementUseCase(),
      getBodyMeasurementUseCase: _FakeGetBodyMeasurementUseCase(),
      saveBmiCalculationUseCase: _FakeSaveBmiCalculationUseCase(),
      saveEnergyExpenditureCalculationUseCase:
          _FakeSaveEnergyExpenditureCalculationUseCase(),
      saveNitrogenBalanceCalculationUseCase:
          _FakeSaveNitrogenBalanceCalculationUseCase(),
      saveProteinNeedsCalculationUseCase:
          _FakeSaveProteinNeedsCalculationUseCase(),
      saveWaterNeedsCalculationUseCase:
          _FakeSaveWaterNeedsCalculationUseCase(),
      saveEnteralNutritionDrippingCalculationUseCase:
          _FakeSaveEnteralNutritionDrippingCalculationUseCase(),
      saveEnteralNutritionSpeedCalculationUseCase:
          _FakeSaveEnteralNutritionSpeedCalculationUseCase(),
      saveEnteralNutritionVolumeCalculationUseCase:
          _FakeSaveEnteralNutritionVolumeCalculationUseCase(),
      saveGlucoseInfusionRateCalculationUseCase:
          _FakeSaveGlucoseInfusionRateCalculationUseCase(),
      saveWeightLossClassificationCalculationUseCase:
          _FakeSaveWeightLossClassificationCalculationUseCase(),
      saveMustCalculationUseCase: fakeSaveMustCalculation,
      saveNrs2002CalculationUseCase: fakeSaveNrs2002Calculation,
      saveStrongKidsCalculationUseCase: fakeSaveStrongKidsCalculation,
      saveIdealWeightCalculationUseCase: fakeSaveIdealWeightCalculation,
    );

    getIt.registerFactory<PatientDetailsCubit>(() => cubit);
    getIt.registerSingleton<AppRouter>(
      _FakeAppRouter({"patientId": patientId}),
    );
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget wrap() => const MaterialApp(home: PatientDetailsPage());

  group('PatientDetailsPage listener wiring', () {
    testWidgets('MUST error transition shows the error DsDialog', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      fakeSaveMustCalculation.resultToReturn = Error("db failure");
      await cubit.saveMustCalculation(
        bmi: 19,
        avgWeightLossIn3To6Months: 3,
        severeIllnessPresent: false,
        reducedFoodIntakeForMoreThan5Days: false,
        willReduceFoodIntakeForMoreThan5Days: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar'), findsOneWidget);
      expect(
        find.text('Não foi possível salvar a triagem MUST. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('MUST success transition shows the success DsDialog', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await cubit.saveMustCalculation(
        bmi: 19,
        avgWeightLossIn3To6Months: 3,
        severeIllnessPresent: false,
        reducedFoodIntakeForMoreThan5Days: false,
        willReduceFoodIntakeForMoreThan5Days: false,
      );
      await tester.pump();

      expect(find.text('Triagem MUST salva com sucesso.'), findsOneWidget);
      // Flush the 2s auto-close delay so no pending Timer leaks.
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('NRS-2002 error transition shows the error DsDialog', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      fakeSaveNrs2002Calculation.resultToReturn = Error("db failure");
      await cubit.saveNrs2002Calculation(
        isSeverelyIll: false,
        weightLossLast3Months: false,
        reducedFoodIntakeLastWeek: false,
        lowBmi: false,
        nutritionalStatusClassification: Nrs2002Step2Classification.absent,
        illnessSeverityClassification: Nrs2002Step2Classification.absent,
      );
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar'), findsOneWidget);
      expect(
        find.text(
          'Não foi possível salvar a triagem NRS-2002. Tente novamente.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('NRS-2002 success transition shows the success DsDialog', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await cubit.saveNrs2002Calculation(
        isSeverelyIll: false,
        weightLossLast3Months: false,
        reducedFoodIntakeLastWeek: false,
        lowBmi: false,
        nutritionalStatusClassification: Nrs2002Step2Classification.absent,
        illnessSeverityClassification: Nrs2002Step2Classification.absent,
      );
      await tester.pump();

      expect(
        find.text('Triagem NRS-2002 salva com sucesso.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('STRONG-Kids error transition shows the error DsDialog', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      fakeSaveStrongKidsCalculation.resultToReturn = Error("db failure");
      await cubit.saveStrongKidsCalculation(
        clinicalAppearanceOfMalnutrition: false,
        highRiskDiseasePresent: false,
        reducedIntakeOrLosses: false,
        weightLossOrGrowthDeficit: false,
      );
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar'), findsOneWidget);
      expect(
        find.text(
          'Não foi possível salvar a triagem STRONG-Kids. Tente novamente.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('STRONG-Kids success transition shows the success DsDialog', (
      tester,
    ) async {
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await cubit.saveStrongKidsCalculation(
        clinicalAppearanceOfMalnutrition: false,
        highRiskDiseasePresent: false,
        reducedIntakeOrLosses: false,
        weightLossOrGrowthDeficit: false,
      );
      await tester.pump();

      expect(
        find.text('Triagem STRONG-Kids salva com sucesso.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Ideal Weight error transition shows the error DsDialog', (
      tester,
    ) async {
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
        HeightEntity(createdAt: DateTime.now(), value: 170, patientId: patientId),
      ];
      await cubit.init(patientId);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      fakeSaveIdealWeightCalculation.resultToReturn = Error("db failure");
      await cubit.saveIdealWeightCalculation(
        gender: Gender.female,
        considerForCalculations: true,
      );
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar'), findsOneWidget);
      expect(
        find.text(
          'Não foi possível salvar o cálculo de Peso Ideal. Tente novamente.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Ideal Weight success transition shows the success DsDialog', (
      tester,
    ) async {
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
        HeightEntity(createdAt: DateTime.now(), value: 170, patientId: patientId),
      ];
      await cubit.init(patientId);

      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await cubit.saveIdealWeightCalculation(
        gender: Gender.female,
        considerForCalculations: true,
      );
      await tester.pump();

      expect(
        find.text('Cálculo de Peso Ideal salvo com sucesso.'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
