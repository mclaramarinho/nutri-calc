import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/bmi/data/models/bmi_model.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

void main() {
  group('BmiModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = BmiModel(
          id: 'bmi-1',
          patientId: 'patient-a',
          value: 22.86,
          classification: BmiClassification.eutrophy,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(key: 'weight_kg', label: 'Peso (kg)', value: 70),
            InputParamEntity(
              key: 'height_m',
              label: 'Altura (m)',
              value: 1.75,
            ),
            InputParamEntity(key: 'age', label: 'Idade', value: 30),
          ],
        );

        final json = model.toJson();

        // inputParams must be stored as an encoded JSON string (TEXT column),
        // not the raw List, per the ADR 0005 convention.
        expect(json['inputParams'], isA<String>());

        final decoded = BmiModel.fromJson(json);

        expect(decoded.inputParams, hasLength(3));

        expect(decoded.inputParams[0].key, 'weight_kg');
        expect(decoded.inputParams[0].label, 'Peso (kg)');
        expect(decoded.inputParams[0].value, 70);

        expect(decoded.inputParams[1].key, 'height_m');
        expect(decoded.inputParams[1].label, 'Altura (m)');
        expect(decoded.inputParams[1].value, 1.75);

        expect(decoded.inputParams[2].key, 'age');
        expect(decoded.inputParams[2].label, 'Idade');
        expect(decoded.inputParams[2].value, 30);
      },
    );

    test(
      'classification round-trips via .name/byName correctly for every '
      'BmiClassification value',
      () {
        for (final classification in BmiClassification.values) {
          final model = BmiModel(
            id: 'bmi-1',
            patientId: 'patient-a',
            value: 20,
            classification: classification,
            createdAt: DateTime(2026, 9, 19),
            inputParams: const [],
          );

          final json = model.toJson();
          expect(json['classification'], classification.name);

          final decoded = BmiModel.fromJson(json);
          expect(
            decoded.classification,
            classification,
            reason: 'round trip failed for $classification',
          );
        }
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, value, '
      'createdAt)',
      () {
        final model = BmiModel(
          id: 'bmi-2',
          patientId: 'patient-b',
          value: 31.1,
          classification: BmiClassification.obesity,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [
            InputParamEntity(key: 'weight_kg', label: 'Peso (kg)', value: 90),
          ],
        );

        final decoded = BmiModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.value, model.value);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
