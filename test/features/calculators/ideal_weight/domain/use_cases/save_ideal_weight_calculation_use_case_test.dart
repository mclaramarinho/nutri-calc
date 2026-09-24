import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/ideal_weight/domain/use_cases/save_ideal_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  Result<WeightEntity, String>? resultToReturn;
  WeightEntity? lastCall;

  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async {
    lastCall = weight;
    return resultToReturn ?? Ok(weight.copyWith(id: 'iw-1'));
  }
}

void main() {
  late _FakeCreateWeightUseCase fakeCreateWeight;
  late SaveIdealWeightCalculationUseCase useCase;

  setUp(() {
    fakeCreateWeight = _FakeCreateWeightUseCase();
    useCase = SaveIdealWeightCalculationUseCaseImpl(
      createWeightUseCase: fakeCreateWeight,
    );
  });

  test(
    'computes idealWeight = 21 * height(m)^2 for female and persists it as '
    'a WEIGHTS row with weightType .ideal',
    () async {
      final res = await useCase(
        patientId: 'p1',
        heightCm: 170,
        gender: Gender.female,
        weightKg: 70,
        considerForCalculations: true,
      );

      expect(res.isOk, isTrue);
      final value = (res as Ok<WeightEntity, String>).value.value;
      expect(value, closeTo(21 * 1.7 * 1.7, 0.001));

      final persisted = fakeCreateWeight.lastCall!;
      expect(persisted.patientId, 'p1');
      expect(persisted.weightType, WeightTypeEnum.ideal);
      expect(persisted.considerForCalculations, isTrue);
      expect(
        persisted.inputParams.map((p) => p.key),
        containsAll(['height_cm', 'gender', 'weight_kg']),
      );
    },
  );

  test('computes idealWeight = 22 * height(m)^2 for male', () async {
    final res = await useCase(
      patientId: 'p1',
      heightCm: 180,
      gender: Gender.male,
      weightKg: 80,
      considerForCalculations: false,
    );

    expect(res.isOk, isTrue);
    final value = (res as Ok<WeightEntity, String>).value.value;
    expect(value, closeTo(22 * 1.8 * 1.8, 0.001));
    expect(fakeCreateWeight.lastCall!.considerForCalculations, isFalse);
  });

  test('propagates an Error from CreateWeightUseCase', () async {
    fakeCreateWeight.resultToReturn = Error("db failure");

    final res = await useCase(
      patientId: 'p1',
      heightCm: 170,
      gender: Gender.female,
      weightKg: 70,
      considerForCalculations: true,
    );

    expect(res.isError, isTrue);
  });
}
