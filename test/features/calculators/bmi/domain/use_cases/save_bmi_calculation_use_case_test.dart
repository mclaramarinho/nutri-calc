import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/repositories/bmi_repository.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/save_bmi_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:nutri_calc/features/calculators/bmi/data/models/bmi_model.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase
/// (e.g. `patient_details_cubit_test.dart`).
class _FakeBmiRepository implements BmiRepository {
  Result<BmiCalculationEntity, String>? nextResult;
  BmiCalculationEntity? lastReceived;

  @override
  Future<Result<BmiCalculationEntity, String>> createBmi(
    BmiCalculationEntity bmi,
  ) async {
    lastReceived = bmi;
    return nextResult ?? Ok(bmi);
  }
  @override
  Future<Result<List<BmiModel>, String>> getBmis(String patientId) async {
    return const Ok([]);
  }

  @override
  Future<Result<void, String>> deleteBmi(String id) async {
    return const Ok(null);
  }
}

void main() {
  late _FakeBmiRepository fakeRepository;
  late SaveBmiCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeBmiRepository();
    useCase = SaveBmiCalculationUseCaseImpl(repository: fakeRepository);
  });

  test(
    'success path: calculates BMI via CalculateBmi, builds inputParams and '
    'persists via the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        weightKg: 70,
        heightM: 1.75,
        age: 30,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      // BMI = 70 / (1.75 * 1.75) = 22.857...
      expect(value.value, closeTo(22.857, 0.001));
      expect(value.classification, BmiClassification.eutrophy);
      expect(value.patientId, 'patient-a');

      // The use case must have actually delegated to the repository with
      // the correctly-built entity (not just returned a local Ok).
      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.patientId, 'patient-a');
      expect(received.value, closeTo(22.857, 0.001));
      expect(received.classification, BmiClassification.eutrophy);
      expect(received.inputParams, hasLength(3));
      expect(received.inputParams[0].key, 'weight_kg');
      expect(received.inputParams[0].value, 70);
      expect(received.inputParams[1].key, 'height_m');
      expect(received.inputParams[1].value, 1.75);
      expect(received.inputParams[2].key, 'age');
      expect(received.inputParams[2].value, 30);
    },
  );

  test(
    'elder classification path (age >= 60) is exercised end-to-end through '
    'the real CalculateBmi',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        weightKg: 90,
        heightM: 1.7,
        age: 65,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));
      // BMI = 90 / (1.7*1.7) = 31.14... -> elder classification uses the
      // Lipshitz thresholds (>27 => overweight), not the adult ones.
      expect(value.classification, BmiClassification.overweight);
    },
  );

  test(
    'error path: repository returning Error propagates as Error, not thrown',
    () async {
      fakeRepository.nextResult = const Error('DB failure');

      final res = await useCase.call(
        patientId: 'patient-c',
        weightKg: 70,
        heightM: 1.75,
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
