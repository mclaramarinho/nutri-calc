import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/entities/protein_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/repositories/protein_needs_repository.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/save_protein_needs_calculation_use_case.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';
import 'package:nutri_calc/features/calculators/protein_needs/data/models/protein_needs_model.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeProteinNeedsRepository implements ProteinNeedsRepository {
  Result<ProteinNeedsCalculationEntity, String>? nextResult;
  ProteinNeedsCalculationEntity? lastReceived;

  @override
  Future<Result<ProteinNeedsCalculationEntity, String>> createProteinNeeds(
    ProteinNeedsCalculationEntity proteinNeeds,
  ) async {
    lastReceived = proteinNeeds;
    return nextResult ?? Ok(proteinNeeds);
  }
  @override
  Future<Result<List<ProteinNeedsModel>, String>> getProteinNeeds(String patientId) async {
    return const Ok([]);
  }

  @override
  Future<Result<void, String>> deleteProteinNeeds(String id) async {
    return const Ok(null);
  }
}

void main() {
  late _FakeProteinNeedsRepository fakeRepository;
  late SaveProteinNeedsCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeProteinNeedsRepository();
    useCase = SaveProteinNeedsCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  test(
    'success path: calculates protein needs via CalculateProteinNeeds, '
    'builds inputParams (patient_state stored as .name) and persists via '
    'the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        weightKg: 70,
        patientState: PatientState.criticalStable,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      // criticalStable: 1.5 - 2.0 g/kg
      expect(value.minValue, closeTo(105, 0.001));
      expect(value.maxValue, closeTo(140, 0.001));
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.inputParams, hasLength(2));
      expect(received.inputParams[0].key, 'weight_kg');
      expect(received.inputParams[0].value, 70);
      expect(received.inputParams[1].key, 'patient_state');
      expect(received.inputParams[1].value, 'criticalStable');
    },
  );

  test(
    'INVALID_PARAMS: negative weight propagates as Error, not thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        weightKg: -1,
        patientState: PatientState.healthy,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'INVALID_PARAMS'),
      );
      expect(fakeRepository.lastReceived, isNull);
    },
  );

  test(
    'error path: repository returning Error propagates as Error, not thrown',
    () async {
      fakeRepository.nextResult = const Error('DB failure');

      final res = await useCase.call(
        patientId: 'patient-c',
        weightKg: 70,
        patientState: PatientState.healthy,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
