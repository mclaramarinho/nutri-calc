import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/data/models/enteral_nutrition_volume_model.dart';

void main() {
  group('EnteralNutritionVolumeModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = EnteralNutritionVolumeModel(
          id: 'env-1',
          patientId: 'patient-a',
          value: 1333.333,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(
              key: 'total_daily_energy_kcal',
              label: 'Energia Diária Total (kcal)',
              value: 2000.0,
            ),
            InputParamEntity(
              key: 'caloric_density_of_diet_kcal_ml',
              label: 'Densidade Calórica da Dieta (kcal/mL)',
              value: 1.5,
            ),
          ],
        );

        final json = model.toJson();

        expect(json['inputParams'], isA<String>());

        final decoded = EnteralNutritionVolumeModel.fromJson(json);

        expect(decoded.inputParams, hasLength(2));
        expect(decoded.inputParams[0].key, 'total_daily_energy_kcal');
        expect(decoded.inputParams[0].value, 2000.0);
        expect(decoded.inputParams[1].key, 'caloric_density_of_diet_kcal_ml');
        expect(decoded.inputParams[1].value, 1.5);
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, value, '
      'createdAt)',
      () {
        final model = EnteralNutritionVolumeModel(
          id: 'env-2',
          patientId: 'patient-b',
          value: 0,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final decoded = EnteralNutritionVolumeModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.value, model.value);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
