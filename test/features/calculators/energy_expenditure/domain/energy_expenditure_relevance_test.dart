import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/energy_expenditure_relevance.dart';

void main() {
  group('isEnergyExpenditureRelevant', () {
    test('age null returns false regardless of hospitalized/confinedToBed', () {
      expect(
        isEnergyExpenditureRelevant(
          const CalculatorRelevanceContext(
            age: null,
            hospitalized: true,
            confinedToBed: true,
          ),
        ),
        isFalse,
      );
      expect(
        isEnergyExpenditureRelevant(const CalculatorRelevanceContext(age: null)),
        isFalse,
      );
    });

    test('age known, neither hospitalized nor confinedToBed returns false', () {
      expect(
        isEnergyExpenditureRelevant(
          const CalculatorRelevanceContext(
            age: 40,
            hospitalized: false,
            confinedToBed: false,
          ),
        ),
        isFalse,
      );
    });

    test('age known and hospitalized returns true', () {
      expect(
        isEnergyExpenditureRelevant(
          const CalculatorRelevanceContext(
            age: 40,
            hospitalized: true,
            confinedToBed: false,
          ),
        ),
        isTrue,
      );
    });

    test('age known and confinedToBed returns true', () {
      expect(
        isEnergyExpenditureRelevant(
          const CalculatorRelevanceContext(
            age: 40,
            hospitalized: false,
            confinedToBed: true,
          ),
        ),
        isTrue,
      );
    });

    test('age known and both hospitalized and confinedToBed returns true', () {
      expect(
        isEnergyExpenditureRelevant(
          const CalculatorRelevanceContext(
            age: 5,
            hospitalized: true,
            confinedToBed: true,
          ),
        ),
        isTrue,
      );
    });
  });
}
