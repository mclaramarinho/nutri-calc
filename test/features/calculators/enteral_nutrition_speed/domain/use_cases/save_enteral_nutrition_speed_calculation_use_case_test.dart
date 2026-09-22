import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/entities/enteral_nutrition_speed_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/repositories/enteral_nutrition_speed_repository.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/save_enteral_nutrition_speed_calculation_use_case.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeEnteralNutritionSpeedRepository
    implements EnteralNutritionSpeedRepository {
  Result<EnteralNutritionSpeedCalculationEntity, String>? nextResult;
  EnteralNutritionSpeedCalculationEntity? lastReceived;

  @override
  Future<Result<EnteralNutritionSpeedCalculationEntity, String>>
  createEnteralNutritionSpeed(
    EnteralNutritionSpeedCalculationEntity enteralNutritionSpeed,
  ) async {
    lastReceived = enteralNutritionSpeed;
    return nextResult ?? Ok(enteralNutritionSpeed);
  }
}

void main() {
  late _FakeEnteralNutritionSpeedRepository fakeRepository;
  late SaveEnteralNutritionSpeedCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeEnteralNutritionSpeedRepository();
    useCase = SaveEnteralNutritionSpeedCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  test(
    'success path: calculates the infusion speed, builds inputParams and '
    'persists via the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        totalDailyVolume: 2400,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      // 2400 / 24 = 100
      expect(value.value, closeTo(100, 0.001));
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.inputParams, hasLength(1));
      expect(received.inputParams[0].key, 'total_daily_volume_ml');
      expect(received.inputParams[0].value, 2400);
    },
  );

  test(
    'INVALID_PARAMS: negative totalDailyVolume propagates as Error, not '
    'thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        totalDailyVolume: -1,
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
        totalDailyVolume: 2400,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
