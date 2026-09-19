import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
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
  @override
  Future<Result<List<BodyMeasurementEntity>, String>> call(
    String patientId,
  ) async {
    return Ok(<BodyMeasurementEntity>[]);
  }
}

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async {
    return Ok(weight);
  }
}

class _FakeCreateHeightUseCase implements CreateHeightUseCase {
  @override
  Future<Result<HeightEntity, String>> call({
    required HeightEntity height,
  }) async {
    return Ok(height);
  }
}

class _FakeCreateBodyMeasurementUseCase implements CreateBodyMeasurementUseCase {
  @override
  Future<Result<BodyMeasurementEntity, String>> call(
    BodyMeasurementEntity entity,
  ) async {
    return Ok(entity);
  }
}

void main() {
  const patientId = "local-id-1";

  late _FakeLoadPatientDetailsUseCase fakeLoad;
  late _FakeUpdatePatientUseCase fakeUpdate;
  late _FakeGetWeightsUseCase fakeGetWeights;
  late _FakeGetHeightsUseCase fakeGetHeights;
  late _FakeGetBodyMeasurementUseCase fakeGetMeasurements;
  late PatientDetailsCubit cubit;

  setUp(() {
    fakeLoad = _FakeLoadPatientDetailsUseCase();
    fakeUpdate = _FakeUpdatePatientUseCase();
    fakeGetWeights = _FakeGetWeightsUseCase();
    fakeGetHeights = _FakeGetHeightsUseCase();
    fakeGetMeasurements = _FakeGetBodyMeasurementUseCase();

    cubit = PatientDetailsCubit(
      loadPatientDetailsUseCase: fakeLoad,
      updatePatientUseCase: fakeUpdate,
      createWeightUseCase: _FakeCreateWeightUseCase(),
      getWeightsUseCase: fakeGetWeights,
      createHeightUseCase: _FakeCreateHeightUseCase(),
      getHeightsUseCase: fakeGetHeights,
      createBodyMeasurementUseCase: _FakeCreateBodyMeasurementUseCase(),
      getBodyMeasurementUseCase: fakeGetMeasurements,
    );
  });

  group('BMI', () {
    test('weight and height both present computes correct BMI', () async {
      fakeGetWeights.weightsToReturn = [
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId),
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
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId),
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
        WeightEntity(createdAt: DateTime.now(), value: 70, patientId: patientId),
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
}
