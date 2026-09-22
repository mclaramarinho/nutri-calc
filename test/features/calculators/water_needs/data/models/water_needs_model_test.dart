import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/water_needs/data/models/water_needs_model.dart';

void main() {
  group('WaterNeedsModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = WaterNeedsModel(
          id: 'wn-1',
          patientId: 'patient-a',
          value: 2100,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(
              key: 'weight_kg',
              label: 'Peso (kg)',
              value: 70.0,
            ),
            InputParamEntity(key: 'age', label: 'Idade', value: 30),
          ],
        );

        final json = model.toJson();

        expect(json['inputParams'], isA<String>());

        final decoded = WaterNeedsModel.fromJson(json);

        expect(decoded.inputParams, hasLength(2));
        expect(decoded.inputParams[0].key, 'weight_kg');
        expect(decoded.inputParams[0].value, 70.0);
        expect(decoded.inputParams[1].key, 'age');
        expect(decoded.inputParams[1].value, 30);
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, value, '
      'createdAt)',
      () {
        final model = WaterNeedsModel(
          id: 'wn-2',
          patientId: 'patient-b',
          value: 1750,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final decoded = WaterNeedsModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.value, model.value);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
