import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/entities/enteral_nutrition_volume_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/repositories/enteral_nutrition_volume_repository.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/save_enteral_nutrition_volume_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/data/models/enteral_nutrition_volume_model.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeEnteralNutritionVolumeRepository
    implements EnteralNutritionVolumeRepository {
  Result<EnteralNutritionVolumeCalculationEntity, String>? nextResult;
  EnteralNutritionVolumeCalculationEntity? lastReceived;

  @override
  Future<Result<EnteralNutritionVolumeCalculationEntity, String>>
  createEnteralNutritionVolume(
    EnteralNutritionVolumeCalculationEntity enteralNutritionVolume,
  ) async {
    lastReceived = enteralNutritionVolume;
    return nextResult ?? Ok(enteralNutritionVolume);
  }
  @override
  Future<Result<List<EnteralNutritionVolumeModel>, String>> getEnteralNutritionVolumes(String patientId) async {
    return const Ok([]);
  }

  @override
  Future<Result<void, String>> deleteEnteralNutritionVolume(String id) async {
    return const Ok(null);
  }
}

void main() {
  late _FakeEnteralNutritionVolumeRepository fakeRepository;
  late SaveEnteralNutritionVolumeCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeEnteralNutritionVolumeRepository();
    useCase = SaveEnteralNutritionVolumeCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  test(
    'success path: calculates the total volume, builds inputParams and '
    'persists via the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        totalDailyEnergy: 2000,
        caloricDensityOfDiet: 1.5,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      // 2000 / 1.5 = 1333.33...
      expect(value.value, closeTo(1333.333, 0.001));
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.inputParams, hasLength(2));
      expect(received.inputParams[0].key, 'total_daily_energy_kcal');
      expect(received.inputParams[0].value, 2000);
      expect(received.inputParams[1].key, 'caloric_density_of_diet_kcal_ml');
      expect(received.inputParams[1].value, 1.5);
    },
  );

  test(
    'INVALID_PARAMS: negative totalDailyEnergy propagates as Error, not '
    'thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        totalDailyEnergy: -1,
        caloricDensityOfDiet: 1.5,
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
        totalDailyEnergy: 2000,
        caloricDensityOfDiet: 1.5,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
