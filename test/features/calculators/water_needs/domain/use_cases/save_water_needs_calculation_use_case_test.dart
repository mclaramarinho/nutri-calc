import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/entities/water_needs_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/repositories/water_needs_repository.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/save_water_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/data/models/water_needs_model.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeWaterNeedsRepository implements WaterNeedsRepository {
  Result<WaterNeedsCalculationEntity, String>? nextResult;
  WaterNeedsCalculationEntity? lastReceived;

  @override
  Future<Result<WaterNeedsCalculationEntity, String>> createWaterNeeds(
    WaterNeedsCalculationEntity waterNeeds,
  ) async {
    lastReceived = waterNeeds;
    return nextResult ?? Ok(waterNeeds);
  }
  @override
  Future<Result<List<WaterNeedsModel>, String>> getWaterNeeds(String patientId) async {
    return const Ok([]);
  }

  @override
  Future<Result<void, String>> deleteWaterNeeds(String id) async {
    return const Ok(null);
  }
}

void main() {
  late _FakeWaterNeedsRepository fakeRepository;
  late SaveWaterNeedsCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeWaterNeedsRepository();
    useCase = SaveWaterNeedsCalculationUseCaseImpl(repository: fakeRepository);
  });

  test(
    'success path (< 60 years): calculates 30ml/kg, builds inputParams and '
    'persists via the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        weightKg: 70,
        age: 30,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      expect(value.value, closeTo(2100, 0.001));
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.inputParams, hasLength(2));
      expect(received.inputParams[0].key, 'weight_kg');
      expect(received.inputParams[0].value, 70);
      expect(received.inputParams[1].key, 'age');
      expect(received.inputParams[1].value, 30);
    },
  );

  test(
    'success path (>= 60 years): calculates 25ml/kg through the real '
    'CalculateWaterNeeds',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        weightKg: 70,
        age: 65,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));
      expect(value.value, closeTo(1750, 0.001));
    },
  );

  test(
    'INVALID_PARAMS: negative weight propagates as Error, not thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-c',
        weightKg: -1,
        age: 30,
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
        patientId: 'patient-d',
        weightKg: 70,
        age: 30,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
