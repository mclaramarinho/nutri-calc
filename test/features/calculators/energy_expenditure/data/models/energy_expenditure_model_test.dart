import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/data/models/energy_expenditure_model.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';

void main() {
  group('EnergyExpenditureModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (via InputParamsJsonCodec) with key/label/value '
      'intact per entry',
      () {
        final model = EnergyExpenditureModel(
          id: 'ee-1',
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.pocket,
          minValue: 1540,
          maxValue: 1750,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(key: 'weight_kg', label: 'Peso (kg)', value: 70),
            InputParamEntity(
              key: 'stress_level',
              label: 'Nível de Estresse',
              value: 'noStress',
            ),
          ],
        );

        final json = model.toJson();

        // inputParams must be stored as an encoded JSON string (TEXT
        // column), not the raw List, per the ADR 0005 convention (BMI's
        // precedent, reused here via InputParamsJsonCodec).
        expect(json['inputParams'], isA<String>());

        final decoded = EnergyExpenditureModel.fromJson(json);

        expect(decoded.inputParams, hasLength(2));
        expect(decoded.inputParams[0].key, 'weight_kg');
        expect(decoded.inputParams[0].label, 'Peso (kg)');
        expect(decoded.inputParams[0].value, 70);
        expect(decoded.inputParams[1].key, 'stress_level');
        expect(decoded.inputParams[1].label, 'Nível de Estresse');
        expect(decoded.inputParams[1].value, 'noStress');
      },
    );

    test(
      'formula round-trips via .name/byName correctly for every '
      'EnergyExpenditureFormulaEnum value',
      () {
        for (final formula in EnergyExpenditureFormulaEnum.values) {
          final model = EnergyExpenditureModel(
            id: 'ee-1',
            patientId: 'patient-a',
            formula: formula,
            minValue: 1000,
            maxValue: 1200,
            createdAt: DateTime(2026, 9, 19),
            inputParams: const [],
          );

          final json = model.toJson();
          expect(json['formula'], formula.name);

          final decoded = EnergyExpenditureModel.fromJson(json);
          expect(
            decoded.formula,
            formula,
            reason: 'round trip failed for $formula',
          );
        }
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, '
      'minValue, maxValue, createdAt)',
      () {
        final model = EnergyExpenditureModel(
          id: 'ee-2',
          patientId: 'patient-b',
          formula: EnergyExpenditureFormulaEnum.who,
          minValue: 900.5,
          maxValue: 1100.25,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [
            InputParamEntity(key: 'weight_kg', label: 'Peso (kg)', value: 20),
          ],
        );

        final decoded = EnergyExpenditureModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.minValue, model.minValue);
        expect(decoded.maxValue, model.maxValue);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
