import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/data/models/enteral_nutrition_speed_model.dart';

void main() {
  group('EnteralNutritionSpeedModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = EnteralNutritionSpeedModel(
          id: 'ens-1',
          patientId: 'patient-a',
          value: 100,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(
              key: 'total_daily_volume_ml',
              label: 'Volume Diário Total (mL)',
              value: 2400.0,
            ),
          ],
        );

        final json = model.toJson();

        expect(json['inputParams'], isA<String>());

        final decoded = EnteralNutritionSpeedModel.fromJson(json);

        expect(decoded.inputParams, hasLength(1));
        expect(decoded.inputParams[0].key, 'total_daily_volume_ml');
        expect(decoded.inputParams[0].value, 2400.0);
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, value, '
      'createdAt)',
      () {
        final model = EnteralNutritionSpeedModel(
          id: 'ens-2',
          patientId: 'patient-b',
          value: 0,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final decoded = EnteralNutritionSpeedModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.value, model.value);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
