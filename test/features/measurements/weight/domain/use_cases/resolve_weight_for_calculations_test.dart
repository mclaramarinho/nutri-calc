import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/resolve_weight_for_calculations.dart';

WeightEntity _weight({
  required String id,
  required double value,
  required bool considerForCalculations,
}) => WeightEntity(
  id: id,
  createdAt: DateTime(2026, 1, 1),
  value: value,
  patientId: 'p1',
  considerForCalculations: considerForCalculations,
  weightType: WeightTypeEnum.measuredByScale,
);

void main() {
  const resolve = ResolveWeightForCalculations();

  test('empty list returns null', () {
    expect(resolve(const []), isNull);
  });

  test('single entry, considerForCalculations true, returns that entry', () {
    final w = _weight(id: 'w1', value: 70, considerForCalculations: true);
    expect(resolve([w]), same(w));
  });

  test('single entry, considerForCalculations false, returns null', () {
    final w = _weight(id: 'w1', value: 70, considerForCalculations: false);
    expect(resolve([w]), isNull);
  });

  test(
    'newest entry false, an older entry true, returns that older true entry',
    () {
      final newest = _weight(id: 'newest', value: 80, considerForCalculations: false);
      final older = _weight(id: 'older', value: 70, considerForCalculations: true);
      expect(resolve([newest, older]), same(older));
    },
  );

  test('all entries false returns null', () {
    final a = _weight(id: 'a', value: 80, considerForCalculations: false);
    final b = _weight(id: 'b', value: 70, considerForCalculations: false);
    expect(resolve([a, b]), isNull);
  });

  test('all entries true returns the newest (first) entry', () {
    final newest = _weight(id: 'newest', value: 80, considerForCalculations: true);
    final older = _weight(id: 'older', value: 70, considerForCalculations: true);
    expect(resolve([newest, older]), same(newest));
  });

  test(
    'garbage-in/garbage-out: returns the first true match in whatever order '
    'given, even if the precondition (newest-first) is violated by the '
    "caller - not this function's job to guard against",
    () {
      final older = _weight(id: 'older', value: 70, considerForCalculations: true);
      final newest = _weight(id: 'newest', value: 80, considerForCalculations: true);
      // Caller passes oldest-first here (violates the precondition).
      expect(resolve([older, newest]), same(older));
    },
  );
}
