import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/adequation/domain/use_cases/save_adequation_calculation_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  Result<WeightEntity, String>? resultToReturn;
  WeightEntity? lastCall;

  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async {
    lastCall = weight;
    return resultToReturn ?? Ok(weight.copyWith(id: 'adeq-1'));
  }
}

void main() {
  late _FakeCreateWeightUseCase fakeCreateWeight;
  late SaveAdequationCalculationUseCase useCase;

  setUp(() {
    fakeCreateWeight = _FakeCreateWeightUseCase();
    useCase = SaveAdequationCalculationUseCaseImpl(
      createWeightUseCase: fakeCreateWeight,
    );
  });

  test(
    'computes adequation = (current * 100) / ideal and persists it as a '
    'WEIGHTS row with weightType .adequation, value as a percentage (not kg)',
    () async {
      final res = await useCase(
        patientId: 'p1',
        currentWeight: 70,
        idealWeight: 65,
        considerForCalculations: true,
      );

      expect(res.isOk, isTrue);
      final persisted = (res as Ok<WeightEntity, String>).value;
      expect(persisted.value, closeTo((70 * 100) / 65, 0.001));
      expect(persisted.weightType, WeightTypeEnum.adequation);
      expect(persisted.patientId, 'p1');
      expect(persisted.considerForCalculations, isTrue);
      expect(
        fakeCreateWeight.lastCall!.inputParams.map((p) => p.key),
        containsAll(['current_weight_kg', 'ideal_weight_kg', 'classification']),
      );
    },
  );

  test('propagates an Error from CalculateWeightAdequation (negative params)', () async {
    final res = await useCase(
      patientId: 'p1',
      currentWeight: -1,
      idealWeight: 65,
      considerForCalculations: true,
    );

    expect(res.isError, isTrue);
    expect(fakeCreateWeight.lastCall, isNull);
  });

  test('propagates an Error from CreateWeightUseCase', () async {
    fakeCreateWeight.resultToReturn = Error("db failure");

    final res = await useCase(
      patientId: 'p1',
      currentWeight: 70,
      idealWeight: 65,
      considerForCalculations: true,
    );

    expect(res.isError, isTrue);
  });
}
