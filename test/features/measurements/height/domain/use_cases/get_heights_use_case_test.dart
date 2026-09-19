import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/height/data/models/height_model.dart';
import 'package:nutri_calc/features/measurements/height/domain/repositories/height_repository.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';

class _FakeHeightRepository implements HeightRepository {
  List<HeightModel> heightsToReturn = [];

  @override
  Future<Result<HeightModel, String>> createHeight({
    required double value,
    required String patientId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<HeightModel>, String>> getHeights(
    String patientId,
  ) async {
    return Ok(heightsToReturn);
  }
}

void main() {
  test('result list is sorted newest-first given out-of-order input', () async {
    final fakeRepository = _FakeHeightRepository();
    fakeRepository.heightsToReturn = [
      HeightModel(
        id: 'h1',
        value: 170,
        createdAt: DateTime(2024, 1, 1),
        patientId: 'p1',
      ),
      HeightModel(
        id: 'h2',
        value: 175,
        createdAt: DateTime(2024, 3, 1),
        patientId: 'p1',
      ),
      HeightModel(
        id: 'h3',
        value: 172,
        createdAt: DateTime(2024, 2, 1),
        patientId: 'p1',
      ),
    ];

    final useCase = GetHeightsUseCaseImpl(repository: fakeRepository);
    final res = await useCase.call('p1');

    expect(res.isOk, isTrue);
    final values = res.getOrElse(() => []);
    expect(values.map((v) => v.id).toList(), ['h2', 'h3', 'h1']);
  });
}
