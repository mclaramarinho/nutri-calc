import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_measurements_tab.dart';

void main() {
  const tab = PatientMeasurementsTab(type: MeasurementType.weight);
  const heightTab = PatientMeasurementsTab(type: MeasurementType.height);

  group('castToListItem - weight rendering', () {
    test(
      'a plain measured-by-scale weight renders as "value kg" (default '
      'rendering, unaffected by the two new special cases)',
      () {
        final items = tab.castToListItem([
          WeightEntity(
            id: 'w1',
            createdAt: DateTime.now(),
            value: 70.5,
            patientId: 'p1',
            considerForCalculations: true,
            weightType: WeightTypeEnum.measuredByScale,
          ),
        ]);

        expect(items.single.value, '70.5 kg');
      },
    );

    for (final type in [
      WeightTypeEnum.ideal,
      WeightTypeEnum.adjustedObesity,
      WeightTypeEnum.estimated,
    ]) {
      test(
        'a $type weight (not adequation/adjustedDryWeight) also renders as '
        '"value kg" - the special cases must not leak into other weight types',
        () {
          final items = tab.castToListItem([
            WeightEntity(
              id: 'w1',
              createdAt: DateTime.now(),
              value: 65.0,
              patientId: 'p1',
              considerForCalculations: true,
              weightType: type,
            ),
          ]);

          expect(items.single.value, '65.0 kg');
        },
      );
    }

    test(
      'an adequation weight renders as "X.XX% (Classificação)" instead of '
      'appending kg, with the classification recomputed from the persisted '
      'percentage at display time',
      () {
        final items = tab.castToListItem([
          WeightEntity(
            id: 'w1',
            createdAt: DateTime.now(),
            value: 104.2,
            patientId: 'p1',
            considerForCalculations: true,
            weightType: WeightTypeEnum.adequation,
          ),
        ]);

        // 104.2 falls in eutrophy's (90.1, 110] band.
        expect(items.single.value, '104.20% (Eutrofia)');
      },
    );

    for (final entry in {
      50.0: 'Desnutrição grave',
      75.0: 'Desnutrição moderada',
      85.0: 'Desnutrição leve',
      100.0: 'Eutrofia',
      115.0: 'Sobrepeso',
      125.0: 'Obesidade',
    }.entries) {
      test(
        'adequation value ${entry.key} classifies as "${entry.value}"',
        () {
          final items = tab.castToListItem([
            WeightEntity(
              id: 'w1',
              createdAt: DateTime.now(),
              value: entry.key,
              patientId: 'p1',
              considerForCalculations: true,
              weightType: WeightTypeEnum.adequation,
            ),
          ]);

          expect(items.single.value, contains(entry.value));
          expect(items.single.value, endsWith(')'));
          expect(items.single.value, isNot(endsWith('kg')));
        },
      );
    }

    test(
      'an adjustedDryWeight weight renders as "min – max kg" read back out '
      'of inputParams, not "value kg" (value only holds the midpoint)',
      () {
        final items = tab.castToListItem([
          WeightEntity(
            id: 'w1',
            createdAt: DateTime.now(),
            value: 75.0, // midpoint, not directly displayed
            patientId: 'p1',
            considerForCalculations: true,
            weightType: WeightTypeEnum.adjustedDryWeight,
            inputParams: const [
              InputParamEntity(
                key: 'dry_weight_min_kg',
                label: 'Peso Seco Mínimo (kg)',
                value: 74.0,
              ),
              InputParamEntity(
                key: 'dry_weight_max_kg',
                label: 'Peso Seco Máximo (kg)',
                value: 76.0,
              ),
            ],
          ),
        ]);

        expect(items.single.value, '74.0 – 76.0 kg');
      },
    );

    test(
      'mixed list: adequation, adjustedDryWeight and a default weight each '
      'render with their own format independently in the same list',
      () {
        final items = tab.castToListItem([
          WeightEntity(
            id: 'w1',
            createdAt: DateTime.now(),
            value: 104.2,
            patientId: 'p1',
            considerForCalculations: true,
            weightType: WeightTypeEnum.adequation,
          ),
          WeightEntity(
            id: 'w2',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            value: 75.0,
            patientId: 'p1',
            considerForCalculations: true,
            weightType: WeightTypeEnum.adjustedDryWeight,
            inputParams: const [
              InputParamEntity(
                key: 'dry_weight_min_kg',
                label: 'Peso Seco Mínimo (kg)',
                value: 74.0,
              ),
              InputParamEntity(
                key: 'dry_weight_max_kg',
                label: 'Peso Seco Máximo (kg)',
                value: 76.0,
              ),
            ],
          ),
          WeightEntity(
            id: 'w3',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            value: 70.0,
            patientId: 'p1',
            considerForCalculations: true,
            weightType: WeightTypeEnum.measuredByScale,
          ),
        ]);

        expect(items[0].value, '104.20% (Eutrofia)');
        expect(items[1].value, '74.0 – 76.0 kg');
        expect(items[2].value, '70.0 kg');
      },
    );
  });

  group('castToListItem - height rendering unaffected', () {
    test('heights always render as "value cm" regardless of weight-only special cases', () {
      final items = heightTab.castToListItem([
        HeightEntity(
          id: 'h1',
          createdAt: DateTime.now(),
          value: 170.0,
          patientId: 'p1',
        ),
      ]);

      expect(items.single.value, '170.0 cm');
    });
  });
}
