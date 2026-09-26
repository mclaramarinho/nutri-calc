import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/adjusted_obesity/domain/use_cases/save_adjusted_obesity_calculation_use_case.dart';
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
    return resultToReturn ?? Ok(weight.copyWith(id: 'adjobes-1'));
  }
}

void main() {
  late _FakeCreateWeightUseCase fakeCreateWeight;
  late SaveAdjustedObesityCalculationUseCase useCase;

  setUp(() {
    fakeCreateWeight = _FakeCreateWeightUseCase();
    useCase = SaveAdjustedObesityCalculationUseCaseImpl(
      createWeightUseCase: fakeCreateWeight,
    );
  });

  test(
    'computes idealWeight + 0.4*(current - ideal) and persists it as a '
    'WEIGHTS row with weightType .adjustedObesity',
    () async {
      final res = await useCase(
        patientId: 'p1',
        currentWeight: 100,
        idealWeight: 65,
        considerForCalculations: false,
      );

      expect(res.isOk, isTrue);
      final persisted = (res as Ok<WeightEntity, String>).value;
      expect(persisted.value, closeTo(65 + (0.4 * (100 - 65)), 0.001));
      expect(persisted.weightType, WeightTypeEnum.adjustedObesity);
      expect(persisted.considerForCalculations, isFalse);
      expect(
        fakeCreateWeight.lastCall!.inputParams.map((p) => p.key),
        containsAll(['current_weight_kg', 'ideal_weight_kg']),
      );
    },
  );

  test('propagates an Error from CalculateAdjustedObesityWeight (negative params)', () async {
    final res = await useCase(
      patientId: 'p1',
      currentWeight: -5,
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
      currentWeight: 100,
      idealWeight: 65,
      considerForCalculations: true,
    );

    expect(res.isError, isTrue);
  });
}
