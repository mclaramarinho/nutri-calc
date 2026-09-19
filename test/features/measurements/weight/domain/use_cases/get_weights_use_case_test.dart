import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/weight/data/models/weight_model.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/repositories/weight_repository.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';

class _FakeWeightRepository implements WeightRepository {
  List<WeightModel> weightsToReturn = [];

  @override
  Future<Result<WeightModel, String>> createWeight({
    required double value,
    required String patientId,
    required bool considerForCalculations,
    required WeightTypeEnum weightType,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<WeightModel>, String>> getWeights(
    String patientId,
  ) async {
    return Ok(weightsToReturn);
  }
}

void main() {
  test('result list is sorted newest-first given out-of-order input', () async {
    final fakeRepository = _FakeWeightRepository();
    fakeRepository.weightsToReturn = [
      WeightModel(
        id: 'w1',
        value: 70,
        createdAt: DateTime(2024, 1, 1),
        patientId: 'p1',
        considerForCalculations: true,
        weightType: WeightTypeEnum.measuredByScale,
      ),
      WeightModel(
        id: 'w2',
        value: 75,
        createdAt: DateTime(2024, 3, 1),
        patientId: 'p1',
        considerForCalculations: true,
        weightType: WeightTypeEnum.measuredByScale,
      ),
      WeightModel(
        id: 'w3',
        value: 72,
        createdAt: DateTime(2024, 2, 1),
        patientId: 'p1',
        considerForCalculations: true,
        weightType: WeightTypeEnum.measuredByScale,
      ),
    ];

    final useCase = GetWeightsUseCaseImpl(repository: fakeRepository);
    final res = await useCase.call('p1');

    expect(res.isOk, isTrue);
    final values = res.getOrElse(() => []);
    expect(values.map((v) => v.id).toList(), ['w2', 'w3', 'w1']);
  });
}
