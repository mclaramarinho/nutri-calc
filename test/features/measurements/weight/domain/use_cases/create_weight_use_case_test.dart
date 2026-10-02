import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/repositories/weight_repository.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';

class _FakeWeightRepository implements WeightRepository {
  Result<WeightModel, String>? resultToReturn;

  @override
  Future<Result<WeightModel, String>> createWeight({
    required double value,
    required String patientId,
    required bool considerForCalculations,
    required WeightTypeEnum weightType,
    required DateTime createdAt,
    List<InputParamEntity> inputParams = const [],
  }) async {
    return resultToReturn!;
  }

  @override
  Future<Result<List<WeightModel>, String>> getWeights(
    String patientId,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, String>> deleteWeight(String id) async {
    return const Ok(null);
  }
}

void main() {
  // Regression test for the `(res as Ok).value >= 1` bug: casting to a
  // generics-erased `Ok` and calling `>=` on what is actually a
  // `WeightModel` used to throw `NoSuchMethodError` on every successful
  // repository create. This asserts a clean `Ok` result with the created
  // entity's id populated from the repository's model, no crash.
  test(
    'returns Ok with the repository-generated id on a successful create',
    () async {
      final fakeRepository = _FakeWeightRepository();
      fakeRepository.resultToReturn = Ok(
        WeightModel(
          id: 'generated-id',
          value: 70,
          createdAt: DateTime(2024, 1, 1),
          patientId: 'p1',
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      );

      final useCase = CreateWeightUseCaseImpl(repository: fakeRepository);

      final res = await useCase.call(
        weight: WeightEntity(
          createdAt: DateTime(2024, 1, 1),
          value: 70,
          patientId: 'p1',
          considerForCalculations: true,
          weightType: WeightTypeEnum.measuredByScale,
        ),
      );

      expect(res.isOk, isTrue);
      final entity = res.getOrElse(() => throw StateError('expected Ok'));
      expect(entity.id, 'generated-id');
      expect(entity.value, 70);
    },
  );

  test('returns Error when the repository create fails', () async {
    final fakeRepository = _FakeWeightRepository();
    fakeRepository.resultToReturn = Error('boom');

    final useCase = CreateWeightUseCaseImpl(repository: fakeRepository);

    final res = await useCase.call(
      weight: WeightEntity(
        createdAt: DateTime(2024, 1, 1),
        value: 70,
        patientId: 'p1',
        considerForCalculations: true,
        weightType: WeightTypeEnum.measuredByScale,
      ),
    );

    expect(res.isError, isTrue);
  });
}
