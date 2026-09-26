import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/estimated_weight/domain/use_cases/save_estimated_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/utils/enums/ethnicity.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  Result<WeightEntity, String>? resultToReturn;
  WeightEntity? lastCall;

  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async {
    lastCall = weight;
    return resultToReturn ?? Ok(weight.copyWith(id: 'est-1'));
  }
}

void main() {
  late _FakeCreateWeightUseCase fakeCreateWeight;
  late SaveEstimatedWeightCalculationUseCase useCase;

  setUp(() {
    fakeCreateWeight = _FakeCreateWeightUseCase();
    useCase = SaveEstimatedWeightCalculationUseCaseImpl(
      createWeightUseCase: fakeCreateWeight,
    );
  });

  test(
    'computes the female/white 19-59 formula and persists it as a WEIGHTS '
    'row with weightType .estimated',
    () async {
      final res = await useCase(
        patientId: 'p1',
        kneeHeight: 50,
        armCircumference: 30,
        gender: Gender.female,
        age: 40,
        ethnicity: Ethnicity.white,
        considerForCalculations: true,
      );

      expect(res.isOk, isTrue);
      final persisted = (res as Ok<WeightEntity, String>).value;
      expect(
        persisted.value,
        closeTo((50 * 1.01) + (30 * 2.81) - 66.04, 0.001),
      );
      expect(persisted.weightType, WeightTypeEnum.estimated);
      expect(
        fakeCreateWeight.lastCall!.inputParams.map((p) => p.key),
        containsAll([
          'knee_height_cm',
          'arm_circumference_cm',
          'gender',
          'ethnicity',
        ]),
      );
    },
  );

  test(
    'propagates Error("INVALID_AGE") from CalculateEstimatedWeight for '
    'age > 80 without ever reaching CreateWeightUseCase',
    () async {
      final res = await useCase(
        patientId: 'p1',
        kneeHeight: 50,
        armCircumference: 30,
        gender: Gender.female,
        age: 81,
        ethnicity: Ethnicity.white,
        considerForCalculations: true,
      );

      expect(res.isError, isTrue);
      expect((res as Error<WeightEntity, String>).error, 'INVALID_AGE');
      expect(fakeCreateWeight.lastCall, isNull);
    },
  );

  test('propagates an Error from CreateWeightUseCase', () async {
    fakeCreateWeight.resultToReturn = Error("db failure");

    final res = await useCase(
      patientId: 'p1',
      kneeHeight: 50,
      armCircumference: 30,
      gender: Gender.female,
      age: 40,
      ethnicity: Ethnicity.white,
      considerForCalculations: true,
    );

    expect(res.isError, isTrue);
  });

  test(
    'regression: amputation is always passed null to CalculateEstimatedWeight '
    '(no amputation UI exists this slice - known scope limitation) - verified '
    'indirectly by confirming the persisted result matches the no-amputation '
    'formula output exactly',
    () async {
      final res = await useCase(
        patientId: 'p1',
        kneeHeight: 50,
        armCircumference: 30,
        gender: Gender.male,
        age: 70,
        ethnicity: Ethnicity.black,
        considerForCalculations: true,
      );

      expect(res.isOk, isTrue);
      final persisted = (res as Ok<WeightEntity, String>).value;
      // Male/black, age > 59 formula, no amputation adjustment applied.
      expect(
        persisted.value,
        closeTo((50 * 0.44) + (30 * 2.86) - 39.21, 0.001),
      );
    },
  );
}
