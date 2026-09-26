import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/entities/weight_loss_classification_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/repositories/weight_loss_classification_repository.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/save_weight_loss_classification_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/data/models/weight_loss_classification_model.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeWeightLossClassificationRepository
    implements WeightLossClassificationRepository {
  Result<WeightLossClassificationCalculationEntity, String>? nextResult;
  WeightLossClassificationCalculationEntity? lastReceived;

  @override
  Future<Result<WeightLossClassificationCalculationEntity, String>>
  createWeightLossClassification(
    WeightLossClassificationCalculationEntity weightLossClassification,
  ) async {
    lastReceived = weightLossClassification;
    return nextResult ?? Ok(weightLossClassification);
  }
  @override
  Future<Result<List<WeightLossClassificationModel>, String>> getWeightLossClassifications(String patientId) async {
    return const Ok([]);
  }

  @override
  Future<Result<void, String>> deleteWeightLossClassification(String id) async {
    return const Ok(null);
  }
}

void main() {
  late _FakeWeightLossClassificationRepository fakeRepository;
  late SaveWeightLossClassificationCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeWeightLossClassificationRepository();
    useCase = SaveWeightLossClassificationCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  test(
    'success path: classifies the weight loss through the real '
    'ClassifyWeighLoss, builds inputParams and persists via the '
    'repository, returning Ok',
    () async {
      final currentWeightDate = DateTime(2026, 9, 20);
      final lastWeightDate = DateTime(2026, 9, 13); // 7 days earlier

      final res = await useCase.call(
        patientId: 'patient-a',
        currentWeight: 63,
        currentWeightDate: currentWeightDate,
        lastWeight: 70,
        lastWeightDate: lastWeightDate,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      expect(value.percentage, closeTo(10, 0.001));
      expect(value.timeReference, 7);
      expect(value.classification, WeightLossClassification.severe);
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.inputParams, hasLength(4));
      expect(received.inputParams[0].key, 'current_weight_kg');
      expect(received.inputParams[0].value, 63);
      expect(received.inputParams[1].key, 'current_weight_date');
      expect(received.inputParams[1].value, currentWeightDate.toIso8601String());
      expect(received.inputParams[2].key, 'last_weight_kg');
      expect(received.inputParams[2].value, 70);
      expect(received.inputParams[3].key, 'last_weight_date');
      expect(received.inputParams[3].value, lastWeightDate.toIso8601String());
    },
  );

  test(
    'INVALID_PARAMS: negative weight propagates as Error, not thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        currentWeight: -1,
        currentWeightDate: DateTime(2026, 9, 20),
        lastWeight: 70,
        lastWeightDate: DateTime(2026, 9, 13),
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
        currentWeight: 63,
        currentWeightDate: DateTime(2026, 9, 20),
        lastWeight: 70,
        lastWeightDate: DateTime(2026, 9, 13),
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
