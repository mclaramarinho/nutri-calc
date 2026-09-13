import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';

void main() {
  group('PatientModel clinical boolean flags - int<->bool JsonKey conversion', () {
    test('toJson emits 0/1 (sqlite-insertable ints), not Dart true/false', () {
      final model = PatientModel(
        firstName: 'Ana',
        lastName: 'Silva',
        enteralNutrition: true,
        parenteralNutrition: false,
        hospitalized: true,
        confinedToBed: false,
      );

      final json = model.toJson();

      expect(json['enteralNutrition'], 1);
      expect(json['parenteralNutrition'], 0);
      expect(json['hospitalized'], 1);
      expect(json['confinedToBed'], 0);
      // Explicitly not Dart booleans - sqflite's insert/update channel
      // rejects bool for an INTEGER column.
      expect(json['enteralNutrition'], isNot(isA<bool>()));
    });

    test('fromJson decodes raw int column values (0/1) back to bool', () {
      final json = {
        'id': 'p1',
        'firstName': 'Ana',
        'lastName': 'Silva',
        'patientId': null,
        'birthdate': null,
        'age': null,
        'ageUnit': null,
        'enteralNutrition': 1,
        'parenteralNutrition': 0,
        'hospitalized': 1,
        'confinedToBed': 0,
      };

      final model = PatientModel.fromJson(json);

      expect(model.enteralNutrition, isTrue);
      expect(model.parenteralNutrition, isFalse);
      expect(model.hospitalized, isTrue);
      expect(model.confinedToBed, isFalse);
    });

    test('toJson -> fromJson round-trip preserves all 4 flag combinations', () {
      for (final enteral in [true, false]) {
        for (final parenteral in [true, false]) {
          final model = PatientModel(
            firstName: 'Ana',
            lastName: 'Silva',
            enteralNutrition: enteral,
            parenteralNutrition: parenteral,
            hospitalized: enteral,
            confinedToBed: parenteral,
          );

          final roundTripped = PatientModel.fromJson(model.toJson());

          expect(roundTripped.enteralNutrition, enteral);
          expect(roundTripped.parenteralNutrition, parenteral);
          expect(roundTripped.hospitalized, enteral);
          expect(roundTripped.confinedToBed, parenteral);
        }
      }
    });

    test('constructor defaults all 4 flags to false when omitted', () {
      final model = PatientModel(firstName: 'Ana', lastName: 'Silva');

      expect(model.enteralNutrition, isFalse);
      expect(model.parenteralNutrition, isFalse);
      expect(model.hospitalized, isFalse);
      expect(model.confinedToBed, isFalse);
    });

    test('copyWithId preserves all 4 flags while assigning a new id', () {
      final model = PatientModel(
        firstName: 'Ana',
        lastName: 'Silva',
        enteralNutrition: true,
        parenteralNutrition: true,
        hospitalized: true,
        confinedToBed: true,
      );

      final withId = model.copyWithId();

      expect(withId.id, isNotNull);
      expect(withId.enteralNutrition, isTrue);
      expect(withId.parenteralNutrition, isTrue);
      expect(withId.hospitalized, isTrue);
      expect(withId.confinedToBed, isTrue);
    });
  });
}
