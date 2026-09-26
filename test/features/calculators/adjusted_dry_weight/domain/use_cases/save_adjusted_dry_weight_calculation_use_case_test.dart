import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/adjusted_dry_weight/domain/use_cases/save_adjusted_dry_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/ascitis_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/oedema_level.enum.dart';

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  Result<WeightEntity, String>? resultToReturn;
  WeightEntity? lastCall;

  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async {
    lastCall = weight;
    return resultToReturn ?? Ok(weight.copyWith(id: 'adjdry-1'));
  }
}

void main() {
  late _FakeCreateWeightUseCase fakeCreateWeight;
  late SaveAdjustedDryWeightCalculationUseCase useCase;

  const imc = Bmi(value: 35, classification: BmiClassification.obesity);

  setUp(() {
    fakeCreateWeight = _FakeCreateWeightUseCase();
    useCase = SaveAdjustedDryWeightCalculationUseCaseImpl(
      createWeightUseCase: fakeCreateWeight,
    );
  });

  test(
    'persists the midpoint (min+max)/2 into value, and both bounds losslessly '
    'into inputParams (dry_weight_min_kg/dry_weight_max_kg)',
    () async {
      final res = await useCase(
        patientId: 'p1',
        currentWeight: 80,
        imc: imc,
        ascitis: AscitisLevel.moderate, // subtracts 6
        oedema: OedemaLevel.moderate, // min 3, max 4
        considerForCalculations: true,
      );

      expect(res.isOk, isTrue);
      final persisted = (res as Ok<WeightEntity, String>).value;

      // min = 80 - 6 - 3 = 71, max = 80 - 6 - 4 = 70
      const expectedMin = 71.0;
      const expectedMax = 70.0;
      expect(persisted.value, closeTo((expectedMin + expectedMax) / 2, 0.001));
      expect(persisted.weightType, WeightTypeEnum.adjustedDryWeight);

      final minParam = persisted.inputParams.firstWhere(
        (p) => p.key == 'dry_weight_min_kg',
      );
      final maxParam = persisted.inputParams.firstWhere(
        (p) => p.key == 'dry_weight_max_kg',
      );
      expect(minParam.value, closeTo(expectedMin, 0.001));
      expect(maxParam.value, closeTo(expectedMax, 0.001));
    },
  );

  test('with no ascitis/oedema, min == max == currentWeight, midpoint == currentWeight', () async {
    final res = await useCase(
      patientId: 'p1',
      currentWeight: 80,
      imc: imc,
      considerForCalculations: true,
    );

    expect(res.isOk, isTrue);
    final persisted = (res as Ok<WeightEntity, String>).value;
    expect(persisted.value, closeTo(80, 0.001));
  });

  test('propagates an Error from CalculateDryWeight (negative currentWeight)', () async {
    final res = await useCase(
      patientId: 'p1',
      currentWeight: -1,
      imc: imc,
      considerForCalculations: true,
    );

    expect(res.isError, isTrue);
    expect(fakeCreateWeight.lastCall, isNull);
  });

  test('propagates an Error from CreateWeightUseCase', () async {
    fakeCreateWeight.resultToReturn = Error("db failure");

    final res = await useCase(
      patientId: 'p1',
      currentWeight: 80,
      imc: imc,
      considerForCalculations: true,
    );

    expect(res.isError, isTrue);
  });
}
