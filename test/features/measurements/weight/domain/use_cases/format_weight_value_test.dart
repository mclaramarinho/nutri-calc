import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/format_weight_value.dart';

/// Regression coverage for `FormatWeightValue` (extracted from
/// `patient_measurements_tab.dart`'s private `_formatWeightValue`, ADR 0009)
/// - existing coverage for this formatting logic was effectively zero
/// (`test/patient_measurements_tab_test.dart` only asserts a ListView-layout
/// lint, never the Adequation/Adjusted Dry Weight/plain-kg branches), so this
/// locks in the pre-refactor behavior for both the Weights tab and the new
/// History tab's `GetWeightHistoryUseCase`, which both depend on it.
void main() {
  const format = FormatWeightValue();

  test('plain weight types (e.g. manual scale weight) render as "X kg"', () {
    final weight = WeightEntity(
      id: 'w1',
      value: 70.5,
      patientId: 'p1',
      createdAt: DateTime(2026, 1, 1),
      considerForCalculations: true,
      weightType: WeightTypeEnum.measuredByScale,
    );

    expect(format(weight), '70.5 kg');
  });

  test('adequation renders as a percentage with its classification label', () {
    // Adequation classification thresholds (see
    // WeightAdequationClassification.getByValue): >= 90 && <110 is eutrophy.
    final weight = WeightEntity(
      id: 'w2',
      value: 95.123,
      patientId: 'p1',
      createdAt: DateTime(2026, 1, 1),
      considerForCalculations: false,
      weightType: WeightTypeEnum.adequation,
    );

    expect(format(weight), '95.12% (Eutrofia)');
  });

  test(
    'adjusted dry weight renders as a min-max kg range read back from inputParams, not the persisted midpoint value',
    () {
      final weight = WeightEntity(
        id: 'w3',
        value: 65.0, // the persisted midpoint - must NOT be shown directly
        patientId: 'p1',
        createdAt: DateTime(2026, 1, 1),
        considerForCalculations: false,
        weightType: WeightTypeEnum.adjustedDryWeight,
        inputParams: const [
          InputParamEntity(
            key: 'dry_weight_min_kg',
            label: 'Peso seco mínimo',
            value: '60.0',
          ),
          InputParamEntity(
            key: 'dry_weight_max_kg',
            label: 'Peso seco máximo',
            value: '70.0',
          ),
        ],
      );

      expect(format(weight), '60.0 – 70.0 kg');
    },
  );
}
