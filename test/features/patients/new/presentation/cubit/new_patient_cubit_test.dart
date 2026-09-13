import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/patients/data/models/patient_model.dart';
import 'package:nutri_calc/features/patients/new/domain/entities/new_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/new/domain/use_cases/create_patient_use_case.dart';
import 'package:nutri_calc/features/patients/new/presentation/cubit/new_patient_state.dart';

/// Minimal fake - no mocking package is set up in this project, so a fake
/// implementing the abstract use case interface directly is the lightest
/// option that matches the project's existing (mock-free) test conventions.
class _FakeCreatePatientUseCase implements CreatePatientUseCase {
  NewPatientFormEntity? lastCall;

  @override
  Future<Result<PatientModel, String>> call({
    required NewPatientFormEntity formData,
  }) async {
    lastCall = formData;
    return Ok(PatientModel(firstName: formData.firstName, lastName: formData.lastName));
  }
}

void main() {
  group('NewPatientCubit.setValue - clinical boolean flags', () {
    late _FakeCreatePatientUseCase fakeUseCase;
    late NewPatientCubit cubit;

    setUp(() {
      fakeUseCase = _FakeCreatePatientUseCase();
      cubit = NewPatientCubit(createPatientUseCase: fakeUseCase);
      // Seed first/last name so setValue starts from a known form.
      cubit.setValue(PatientPropertiesToEdit.firstName, 'Ana');
      cubit.setValue(PatientPropertiesToEdit.lastName, 'Silva');
    });

    test('all 4 flags default to false on a freshly seeded form', () {
      final state = cubit.state as NewPatientStateInitial;
      expect(state.form!.enteralNutrition, isFalse);
      expect(state.form!.parenteralNutrition, isFalse);
      expect(state.form!.hospitalized, isFalse);
      expect(state.form!.confinedToBed, isFalse);
    });

    test('setValue(enteralNutrition, true) toggles only that field', () {
      cubit.setValue(PatientPropertiesToEdit.enteralNutrition, true);

      final state = cubit.state as NewPatientStateInitial;
      expect(state.form!.enteralNutrition, isTrue);
      expect(state.form!.parenteralNutrition, isFalse);
      expect(state.form!.hospitalized, isFalse);
      expect(state.form!.confinedToBed, isFalse);
    });

    test('setValue toggles each of the 4 flags independently', () {
      cubit.setValue(PatientPropertiesToEdit.enteralNutrition, true);
      cubit.setValue(PatientPropertiesToEdit.parenteralNutrition, true);
      cubit.setValue(PatientPropertiesToEdit.hospitalized, true);
      cubit.setValue(PatientPropertiesToEdit.confinedToBed, true);

      final state = cubit.state as NewPatientStateInitial;
      expect(state.form!.enteralNutrition, isTrue);
      expect(state.form!.parenteralNutrition, isTrue);
      expect(state.form!.hospitalized, isTrue);
      expect(state.form!.confinedToBed, isTrue);
    });

    test('setValue back to false untoggles a previously-true flag', () {
      cubit.setValue(PatientPropertiesToEdit.hospitalized, true);
      cubit.setValue(PatientPropertiesToEdit.hospitalized, false);

      final state = cubit.state as NewPatientStateInitial;
      expect(state.form!.hospitalized, isFalse);
    });

    test(
      'toggling a boolean flag does not perturb unrelated identity fields',
      () {
        cubit.setValue(PatientPropertiesToEdit.confinedToBed, true);

        final state = cubit.state as NewPatientStateInitial;
        expect(state.form!.firstName, 'Ana');
        expect(state.form!.lastName, 'Silva');
      },
    );

    test('saved patient carries the toggled flags through onSubmit', () async {
      cubit.setValue(PatientPropertiesToEdit.enteralNutrition, true);
      cubit.setValue(PatientPropertiesToEdit.confinedToBed, true);

      await cubit.onSubmit();

      expect(fakeUseCase.lastCall, isNotNull);
      expect(fakeUseCase.lastCall!.enteralNutrition, isTrue);
      expect(fakeUseCase.lastCall!.parenteralNutrition, isFalse);
      expect(fakeUseCase.lastCall!.hospitalized, isFalse);
      expect(fakeUseCase.lastCall!.confinedToBed, isTrue);
    });
  });
}
