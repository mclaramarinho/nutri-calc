import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/entities/glucose_infusion_rate_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/repositories/glucose_infusion_rate_repository.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/save_glucose_infusion_rate_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/data/models/glucose_infusion_rate_model.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeGlucoseInfusionRateRepository
    implements GlucoseInfusionRateRepository {
  Result<GlucoseInfusionRateCalculationEntity, String>? nextResult;
  GlucoseInfusionRateCalculationEntity? lastReceived;

  @override
  Future<Result<GlucoseInfusionRateCalculationEntity, String>>
  createGlucoseInfusionRate(
    GlucoseInfusionRateCalculationEntity glucoseInfusionRate,
  ) async {
    lastReceived = glucoseInfusionRate;
    return nextResult ?? Ok(glucoseInfusionRate);
  }
  @override
  Future<Result<List<GlucoseInfusionRateModel>, String>> getGlucoseInfusionRates(String patientId) async {
    return const Ok([]);
  }

  @override
  Future<Result<void, String>> deleteGlucoseInfusionRate(String id) async {
    return const Ok(null);
  }
}

void main() {
  late _FakeGlucoseInfusionRateRepository fakeRepository;
  late SaveGlucoseInfusionRateCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeGlucoseInfusionRateRepository();
    useCase = SaveGlucoseInfusionRateCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  test(
    'success path: calculates the TIG, builds inputParams and persists via '
    'the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        weightKg: 70,
        totalGlucose: 50,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      // (50 * 1000) / (1400 * 70) = 50000 / 98000 = 0.5102...
      expect(value.value, closeTo(0.5102, 0.001));
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.inputParams, hasLength(2));
      expect(received.inputParams[0].key, 'weight_kg');
      expect(received.inputParams[0].value, 70);
      expect(received.inputParams[1].key, 'total_glucose_g');
      expect(received.inputParams[1].value, 50);
    },
  );

  test(
    'zero totalGlucose is allowed (matches the pure-math use case\'s own '
    '>= 0 guard), returning Ok with value 0',
    () async {
      final res = await useCase.call(
        patientId: 'patient-z',
        weightKg: 70,
        totalGlucose: 0,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));
      expect(value.value, 0);
    },
  );

  test(
    'INVALID_PARAMS: negative totalGlucose propagates as Error, not thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        weightKg: 70,
        totalGlucose: -1,
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
        totalGlucose: 50,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
