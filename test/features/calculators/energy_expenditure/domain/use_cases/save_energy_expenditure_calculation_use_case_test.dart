import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/repositories/energy_expenditure_repository.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/save_energy_expenditure_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors `save_bmi_calculation_use_case_test.dart`'s
/// `_FakeBmiRepository` pattern.
class _FakeEnergyExpenditureRepository implements EnergyExpenditureRepository {
  Result<EnergyExpenditureCalculationEntity, String>? nextResult;
  EnergyExpenditureCalculationEntity? lastReceived;

  @override
  Future<Result<EnergyExpenditureCalculationEntity, String>>
  createEnergyExpenditure(
    EnergyExpenditureCalculationEntity energyExpenditure,
  ) async {
    lastReceived = energyExpenditure;
    return nextResult ?? Ok(energyExpenditure);
  }
}

void main() {
  late _FakeEnergyExpenditureRepository fakeRepository;
  late SaveEnergyExpenditureCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeEnergyExpenditureRepository();
    useCase = SaveEnergyExpenditureCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  group('Harris-Benedict', () {
    test(
      'success: computes EER via CalculateEerHarrisBenedict, builds '
      'inputParams (omitting injury/temperature when null) and persists',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.harrisBenedict,
          weightKg: 70,
          heightCm: 175,
          age: 30,
          gender: Gender.male,
          activityFactor: ActivityFactor.walking,
        );

        expect(res.isOk, isTrue);
        final value = res.getOrElse(() => throw StateError('expected Ok'));

        // GEB (male, >18) = 66.47 + 13.75*70 + 5*175 - 6.76*30 = 1701.17
        // EER = GEB * activityFactor(1.3)
        expect(value.minValue, closeTo(2211.521, 0.01));
        expect(value.maxValue, closeTo(2211.521, 0.01));
        expect(value.formula, EnergyExpenditureFormulaEnum.harrisBenedict);
        expect(value.patientId, 'patient-a');

        expect(fakeRepository.lastReceived, isNotNull);
        final received = fakeRepository.lastReceived!;
        expect(received.inputParams, hasLength(5));
        expect(received.inputParams[0].key, 'weight_kg');
        expect(received.inputParams[0].value, 70);
        expect(received.inputParams[1].key, 'height_cm');
        expect(received.inputParams[1].value, 175);
        expect(received.inputParams[2].key, 'age');
        expect(received.inputParams[2].value, 30);
        expect(received.inputParams[3].key, 'gender');
        expect(received.inputParams[3].value, 'male');
        expect(received.inputParams[4].key, 'activity_factor');
        expect(received.inputParams[4].value, 'walking');
      },
    );

    test(
      'error propagation: underlying CalculateEerHarrisBenedict INVALID_PARAMS '
      '(negative age) surfaces as Error, not thrown/swallowed',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.harrisBenedict,
          weightKg: 70,
          heightCm: 175,
          age: -1,
          gender: Gender.male,
          activityFactor: ActivityFactor.walking,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
      },
    );

    test(
      'missing required field (gender null) returns Error(INVALID_PARAMS) '
      'before ever calling the underlying calculator',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.harrisBenedict,
          weightKg: 70,
          heightCm: 175,
          age: 30,
          activityFactor: ActivityFactor.walking,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
        expect(fakeRepository.lastReceived, isNull);
      },
    );
  });

  group('Mifflin', () {
    test(
      'success: computes EER via CalculateEerMifflin and persists correct '
      'inputParams',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.mifflin,
          weightKg: 70,
          heightCm: 175,
          age: 30,
          gender: Gender.female,
          activityFactor: ActivityFactor.bed,
        );

        expect(res.isOk, isTrue);
        final value = res.getOrElse(() => throw StateError('expected Ok'));

        // GET = 10*70 + 6.25*175 - 5*30 - 161 = 1482.75
        // EER = GET * activityFactor(1.2)
        expect(value.minValue, closeTo(1779.3, 0.01));
        expect(value.maxValue, closeTo(1779.3, 0.01));

        final received = fakeRepository.lastReceived!;
        expect(received.inputParams, hasLength(5));
        expect(received.inputParams.map((p) => p.key), [
          'weight_kg',
          'height_cm',
          'age',
          'gender',
          'activity_factor',
        ]);
      },
    );

    test(
      'error propagation: underlying CalculateEerMifflin INVALID_PARAMS '
      '(negative height) surfaces as Error',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.mifflin,
          weightKg: 70,
          heightCm: -1,
          age: 30,
          gender: Gender.female,
          activityFactor: ActivityFactor.bed,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
      },
    );

    test(
      'missing required field (activityFactor null) returns '
      'Error(INVALID_PARAMS)',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.mifflin,
          weightKg: 70,
          heightCm: 175,
          age: 30,
          gender: Gender.female,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
        expect(fakeRepository.lastReceived, isNull);
      },
    );
  });

  group('Schofield', () {
    test(
      'success: computes EER via CalculateEerSchofield (age <= 10) and '
      'persists correct inputParams',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.schofield,
          weightKg: 20,
          heightCm: 100,
          age: 5,
          gender: Gender.male,
          activityFactor: ActivityFactor.bedAndWalking,
        );

        expect(res.isOk, isTrue);
        final value = res.getOrElse(() => throw StateError('expected Ok'));

        // male, age >= 3: 19.6*20 + 130.3*100 + 414.9 = 13836.9
        // EER = eer * activityFactor(1.25)
        expect(value.minValue, closeTo(17296.125, 0.01));
        expect(value.maxValue, closeTo(17296.125, 0.01));

        final received = fakeRepository.lastReceived!;
        expect(received.inputParams.map((p) => p.key), [
          'weight_kg',
          'height_cm',
          'age',
          'gender',
          'activity_factor',
        ]);
      },
    );

    test(
      'error propagation: underlying CalculateEerSchofield INVALID_AGE '
      '(age > 10) surfaces as Error, not swallowed as a generic failure',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.schofield,
          weightKg: 20,
          heightCm: 100,
          age: 11,
          gender: Gender.male,
          activityFactor: ActivityFactor.bedAndWalking,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_AGE'),
        );
      },
    );

    test(
      'missing required field (heightCm null) returns Error(INVALID_PARAMS)',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.schofield,
          weightKg: 20,
          age: 5,
          gender: Gender.male,
          activityFactor: ActivityFactor.bedAndWalking,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
        expect(fakeRepository.lastReceived, isNull);
      },
    );
  });

  group('WHO', () {
    test(
      'success: computes EER via CalculateEerWho (age <= 18, no height '
      'required) and persists correct inputParams',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.who,
          weightKg: 20,
          age: 5,
          gender: Gender.female,
          activityFactor: ActivityFactor.walking,
        );

        expect(res.isOk, isTrue);
        final value = res.getOrElse(() => throw StateError('expected Ok'));

        // female, 3 <= age < 10: 22.4*20 + 499 = 947
        // EER = eer * activityFactor(1.3)
        expect(value.minValue, closeTo(1231.1, 0.01));
        expect(value.maxValue, closeTo(1231.1, 0.01));

        final received = fakeRepository.lastReceived!;
        expect(received.inputParams.map((p) => p.key), [
          'weight_kg',
          'age',
          'gender',
          'activity_factor',
        ]);
      },
    );

    test(
      'error propagation: underlying CalculateEerWho INVALID_AGE (age > 18) '
      'surfaces as Error',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.who,
          weightKg: 20,
          age: 19,
          gender: Gender.female,
          activityFactor: ActivityFactor.walking,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_AGE'),
        );
      },
    );

    test(
      'missing required field (activityFactor null) returns '
      'Error(INVALID_PARAMS)',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.who,
          weightKg: 20,
          age: 5,
          gender: Gender.female,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
        expect(fakeRepository.lastReceived, isNull);
      },
    );
  });

  group('Pocket', () {
    test(
      'success: computes EER via CalculateEerPocket using only weight and '
      'stress level, with no gender/height/age required',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.pocket,
          weightKg: 70,
          stressLevel: StressLevel.moderateStress,
        );

        expect(res.isOk, isTrue);
        final value = res.getOrElse(() => throw StateError('expected Ok'));

        // moderateStress: min=25, max=30 kcal/kg
        expect(value.minValue, closeTo(1750, 0.01));
        expect(value.maxValue, closeTo(2100, 0.01));

        final received = fakeRepository.lastReceived!;
        expect(received.inputParams.map((p) => p.key), [
          'weight_kg',
          'stress_level',
        ]);
        expect(received.inputParams[1].value, 'moderateStress');
      },
    );

    test(
      // Deviation-1 confirmation: Pocket does not require age/gender/height,
      // so calling it with age/gender/heightCm all left null must NOT hit
      // the INVALID_PARAMS null-field guard (that guard's switch only
      // applies to the other 4 formulas).
      'age/gender/heightCm all null does not trigger the INVALID_PARAMS '
      'guard for Pocket',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.pocket,
          weightKg: 70,
        );

        expect(res.isOk, isTrue);
      },
    );

    test(
      'error propagation: underlying CalculateEerPocket INVALID_PARAMS '
      '(negative weight) surfaces as Error',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.pocket,
          weightKg: -1,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
      },
    );
  });

  group('Deviation 1: age is nullable rather than defaulting to 0', () {
    test(
      'passing age: null for a formula that requires age (WHO) returns '
      'Error(INVALID_PARAMS) rather than silently treating age as 0 and '
      'passing the WHO age-ceiling guard',
      () async {
        final res = await useCase.call(
          patientId: 'patient-a',
          formula: EnergyExpenditureFormulaEnum.who,
          weightKg: 20,
          gender: Gender.female,
          activityFactor: ActivityFactor.walking,
          age: null,
        );

        expect(res.isError, isTrue);
        res.when(
          ok: (_) => fail('expected Error'),
          error: (err) => expect(err, 'INVALID_PARAMS'),
        );
      },
    );
  });
}
