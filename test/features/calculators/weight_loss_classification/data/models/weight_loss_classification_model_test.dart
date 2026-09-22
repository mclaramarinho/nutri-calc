import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/data/models/weight_loss_classification_model.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';

void main() {
  group('WeightLossClassificationModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = WeightLossClassificationModel(
          id: 'wlc-1',
          patientId: 'patient-a',
          percentage: 10,
          timeReference: 7,
          classification: WeightLossClassification.severe,
          createdAt: DateTime(2026, 9, 20, 10, 30),
          inputParams: const [
            InputParamEntity(
              key: 'current_weight_kg',
              label: 'Peso Atual (kg)',
              value: 63.0,
            ),
            InputParamEntity(
              key: 'current_weight_date',
              label: 'Data do Peso Atual',
              value: '2026-09-20T00:00:00.000',
            ),
            InputParamEntity(
              key: 'last_weight_kg',
              label: 'Peso Anterior (kg)',
              value: 70.0,
            ),
            InputParamEntity(
              key: 'last_weight_date',
              label: 'Data do Peso Anterior',
              value: '2026-09-13T00:00:00.000',
            ),
          ],
        );

        final json = model.toJson();

        expect(json['inputParams'], isA<String>());

        final decoded = WeightLossClassificationModel.fromJson(json);

        expect(decoded.inputParams, hasLength(4));
        expect(decoded.inputParams[0].key, 'current_weight_kg');
        expect(decoded.inputParams[0].value, 63.0);
        expect(decoded.inputParams[1].key, 'current_weight_date');
        expect(decoded.inputParams[1].value, '2026-09-20T00:00:00.000');
      },
    );

    test(
      'the classification enum column survives the TEXT round trip via '
      'name-based (de)serialization, mirroring BmiModel\'s convention',
      () {
        final model = WeightLossClassificationModel(
          id: 'wlc-2',
          patientId: 'patient-b',
          percentage: 3,
          timeReference: 30,
          classification: WeightLossClassification.significant,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final json = model.toJson();
        expect(json['classification'], 'significant');

        final decoded = WeightLossClassificationModel.fromJson(json);
        expect(decoded.classification, WeightLossClassification.significant);
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, '
      'percentage, timeReference, createdAt)',
      () {
        final model = WeightLossClassificationModel(
          id: 'wlc-3',
          patientId: 'patient-c',
          percentage: 1.5,
          timeReference: 7,
          classification: WeightLossClassification.ok,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final decoded = WeightLossClassificationModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.percentage, model.percentage);
        expect(decoded.timeReference, model.timeReference);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
