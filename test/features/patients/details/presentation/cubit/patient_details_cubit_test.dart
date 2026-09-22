import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_type_enum.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/create_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/get_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/create_height_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/save_bmi_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/save_energy_expenditure_calculation_use_case.dart';
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

    test('on success: sets isBmiSaved true and clears isSavingBmi', () async {
      await cubit.init(patientId);

      await cubit.saveBmiCalculation();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isBmiSaved, isTrue);
      expect(state.isSavingBmi, isFalse);
      expect(state.isBmiSaveError, isFalse);
    });

    test(
      'on error: sets isBmiSaveError/bmiSaveErrorMessage and clears isSavingBmi',
      () async {
        await cubit.init(patientId);
        fakeSaveBmiCalculation.resultToReturn = Error("db failure");

        await cubit.saveBmiCalculation();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isBmiSaveError, isTrue);
        expect(
          state.bmiSaveErrorMessage,
          "Não foi possível salvar o cálculo de IMC. Tente novamente.",
        );
        expect(state.isSavingBmi, isFalse);
      },
    );

    test(
      'closedBmiErrorModal() resets isBmiSaveError/bmiSaveErrorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveBmiCalculation.resultToReturn = Error("db failure");
        await cubit.saveBmiCalculation();

        expect(
          (cubit.state as PatientDetailsStateLoaded).isBmiSaveError,
          isTrue,
        );

        cubit.closedBmiErrorModal();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isBmiSaveError, isFalse);
        expect(state.bmiSaveErrorMessage, isNull);
      },
    );

    test('no weight/height data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveBmiCalculation();

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSavingBmi, isFalse);
      expect(state.isBmiSaved, isFalse);
      expect(state.isBmiSaveError, isFalse);
    });

    test(
      // Regression test for the same "stuck true forever" bug class fixed
      // for isSaveError (roadmap 2.1.4 general notes, 2026-09-19): isBmiSaved
      // must revert to false ~2s after a successful save so the page's
      // listenWhen previous-vs-current true-transition check can fire again
      // for a later successful calculation.
      'on success: isBmiSaved reverts to false after the auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveBmiCalculation();
        expect(
          (cubit.state as PatientDetailsStateLoaded).isBmiSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isBmiSaved, isFalse);
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
      'on success: sets isEnergyExpenditureSaved true and clears '
      'isSavingEnergyExpenditure',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isEnergyExpenditureSaved, isTrue);
        expect(state.isSavingEnergyExpenditure, isFalse);
        expect(state.isEnergyExpenditureSaveError, isFalse);
      },
    );

    test(
      'on error: sets isEnergyExpenditureSaveError/'
      'energyExpenditureSaveErrorMessage and clears isSavingEnergyExpenditure',
      () async {
        await cubit.init(patientId);
        fakeSaveEnergyExpenditureCalculation.resultToReturn = Error(
          "db failure",
        );

        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isEnergyExpenditureSaveError, isTrue);
        expect(
          state.energyExpenditureSaveErrorMessage,
          "Não foi possível salvar o cálculo de gasto energético. Tente novamente.",
        );
        expect(state.isSavingEnergyExpenditure, isFalse);
      },
    );

    test(
      'closedEnergyExpenditureErrorModal() resets '
      'isEnergyExpenditureSaveError/energyExpenditureSaveErrorMessage',
      () async {
        await cubit.init(patientId);
        fakeSaveEnergyExpenditureCalculation.resultToReturn = Error(
          "db failure",
        );
        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );

        expect(
          (cubit.state as PatientDetailsStateLoaded).isEnergyExpenditureSaveError,
          isTrue,
        );

        cubit.closedEnergyExpenditureErrorModal();

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isEnergyExpenditureSaveError, isFalse);
        expect(state.energyExpenditureSaveErrorMessage, isNull);
      },
    );

    test('no weight data: does nothing', () async {
      fakeGetWeights.weightsToReturn = [];
      await cubit.init(patientId);

      await cubit.saveEnergyExpenditureCalculation(
        formula: EnergyExpenditureFormulaEnum.pocket,
      );

      final state = cubit.state as PatientDetailsStateLoaded;
      expect(state.isSavingEnergyExpenditure, isFalse);
      expect(state.isEnergyExpenditureSaved, isFalse);
      expect(state.isEnergyExpenditureSaveError, isFalse);
    });

    test(
      // Regression test for the same "stuck true forever" bug class fixed
      // for isBmiSaved/isSaveError: isEnergyExpenditureSaved must revert to
      // false ~2s after a successful save so the page's listenWhen
      // previous-vs-current true-transition check can fire again for a
      // later successful calculation.
      'on success: isEnergyExpenditureSaved reverts to false after the '
      'auto-close delay',
      () async {
        await cubit.init(patientId);

        await cubit.saveEnergyExpenditureCalculation(
          formula: EnergyExpenditureFormulaEnum.pocket,
        );
        expect(
          (cubit.state as PatientDetailsStateLoaded).isEnergyExpenditureSaved,
          isTrue,
        );

        await Future.delayed(Duration(seconds: 2, milliseconds: 100));

        final state = cubit.state as PatientDetailsStateLoaded;
        expect(state.isEnergyExpenditureSaved, isFalse);
      },
    );
  });
}
