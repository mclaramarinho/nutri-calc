import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/data/models/enteral_nutrition_dripping_model.dart';

void main() {
  group('EnteralNutritionDrippingModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = EnteralNutritionDrippingModel(
          id: 'end-1',
          patientId: 'patient-a',
          value: 41.666,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(
              key: 'total_volume_ml',
              label: 'Volume Total (mL)',
              value: 1000.0,
            ),
            InputParamEntity(
              key: 'total_hours_for_volume_h',
              label: 'Tempo Total (h)',
              value: 8.0,
            ),
          ],
        );

        final json = model.toJson();

        expect(json['inputParams'], isA<String>());

        final decoded = EnteralNutritionDrippingModel.fromJson(json);

        expect(decoded.inputParams, hasLength(2));
        expect(decoded.inputParams[0].key, 'total_volume_ml');
        expect(decoded.inputParams[0].value, 1000.0);
        expect(decoded.inputParams[1].key, 'total_hours_for_volume_h');
        expect(decoded.inputParams[1].value, 8.0);
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, value, '
      'createdAt)',
      () {
        final model = EnteralNutritionDrippingModel(
          id: 'end-2',
          patientId: 'patient-b',
          value: 0,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final decoded = EnteralNutritionDrippingModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.value, model.value);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
