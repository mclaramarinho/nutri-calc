import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/protein_needs/data/models/protein_needs_model.dart';

void main() {
  group('ProteinNeedsModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = ProteinNeedsModel(
          id: 'pn-1',
          patientId: 'patient-a',
          minValue: 56,
          maxValue: 70,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(
              key: 'weight_kg',
              label: 'Peso (kg)',
              value: 70.0,
            ),
            InputParamEntity(
              key: 'patient_state',
              label: 'Estado do paciente',
              value: 'healthy',
            ),
          ],
        );

        final json = model.toJson();

        expect(json['inputParams'], isA<String>());

        final decoded = ProteinNeedsModel.fromJson(json);

        expect(decoded.inputParams, hasLength(2));
        expect(decoded.inputParams[0].key, 'weight_kg');
        expect(decoded.inputParams[0].value, 70.0);
        expect(decoded.inputParams[1].key, 'patient_state');
        expect(decoded.inputParams[1].value, 'healthy');
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, '
      'minValue, maxValue, createdAt)',
      () {
        final model = ProteinNeedsModel(
          id: 'pn-2',
          patientId: 'patient-b',
          minValue: 105,
          maxValue: 140,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final decoded = ProteinNeedsModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.minValue, model.minValue);
        expect(decoded.maxValue, model.maxValue);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
