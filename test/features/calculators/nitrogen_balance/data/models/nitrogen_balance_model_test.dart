import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/input_param_entity.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/data/models/nitrogen_balance_model.dart';

void main() {
  group('NitrogenBalanceModel.toJson()/fromJson() round trip', () {
    test(
      'inputParams (List<InputParamEntity>) survives the JSON-encoded TEXT '
      'column round trip (ADR 0005) with key/label/value intact per entry',
      () {
        final model = NitrogenBalanceModel(
          id: 'nb-1',
          patientId: 'patient-a',
          value: 2.5,
          createdAt: DateTime(2026, 9, 19, 10, 30),
          inputParams: const [
            InputParamEntity(
              key: 'ingested_protein',
              label: 'Proteína Ingerida (g)',
              value: 90.0,
            ),
            InputParamEntity(
              key: 'urine_nitrogen_24h',
              label: 'Nitrogênio Urinário 24h (g)',
              value: 10.0,
            ),
          ],
        );

        final json = model.toJson();

        expect(json['inputParams'], isA<String>());

        final decoded = NitrogenBalanceModel.fromJson(json);

        expect(decoded.inputParams, hasLength(2));
        expect(decoded.inputParams[0].key, 'ingested_protein');
        expect(decoded.inputParams[0].value, 90.0);
        expect(decoded.inputParams[1].key, 'urine_nitrogen_24h');
        expect(decoded.inputParams[1].value, 10.0);
      },
    );

    test(
      'full round trip preserves every scalar field (id, patientId, value, '
      'createdAt)',
      () {
        final model = NitrogenBalanceModel(
          id: 'nb-2',
          patientId: 'patient-b',
          value: -1.2,
          createdAt: DateTime(2025, 1, 2, 3, 4, 5),
          inputParams: const [],
        );

        final decoded = NitrogenBalanceModel.fromJson(model.toJson());

        expect(decoded.id, model.id);
        expect(decoded.patientId, model.patientId);
        expect(decoded.value, model.value);
        expect(decoded.createdAt, model.createdAt);
      },
    );
  });
}
