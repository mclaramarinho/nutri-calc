import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/entities/enteral_nutrition_dripping_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/repositories/enteral_nutrition_dripping_repository.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/save_enteral_nutrition_dripping_calculation_use_case.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeEnteralNutritionDrippingRepository
    implements EnteralNutritionDrippingRepository {
  Result<EnteralNutritionDrippingCalculationEntity, String>? nextResult;
  EnteralNutritionDrippingCalculationEntity? lastReceived;

  @override
  Future<Result<EnteralNutritionDrippingCalculationEntity, String>>
  createEnteralNutritionDripping(
    EnteralNutritionDrippingCalculationEntity enteralNutritionDripping,
  ) async {
    lastReceived = enteralNutritionDripping;
    return nextResult ?? Ok(enteralNutritionDripping);
  }
}

void main() {
  late _FakeEnteralNutritionDrippingRepository fakeRepository;
  late SaveEnteralNutritionDrippingCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeEnteralNutritionDrippingRepository();
    useCase = SaveEnteralNutritionDrippingCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  test(
    'success path: calculates the dripping rate, builds inputParams and '
    'persists via the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        totalVolume: 1000,
        totalHoursForVolume: 8,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      // 1000 / (3 * 8) = 41.666...
      expect(value.value, closeTo(41.666, 0.001));
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.inputParams, hasLength(2));
      expect(received.inputParams[0].key, 'total_volume_ml');
      expect(received.inputParams[0].value, 1000);
      expect(received.inputParams[1].key, 'total_hours_for_volume_h');
      expect(received.inputParams[1].value, 8);
    },
  );

  test(
    'INVALID_PARAMS: negative totalVolume propagates as Error, not thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        totalVolume: -1,
        totalHoursForVolume: 8,
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
        totalVolume: 1000,
        totalHoursForVolume: 8,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
