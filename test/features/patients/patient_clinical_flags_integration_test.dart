import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/features/patients/details/data/repositories/patient_details_repository_impl.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/update_patient_use_case.dart';
import 'package:nutri_calc/features/patients/new/data/repositories/new_patient_repository.dart';
import 'package:nutri_calc/features/patients/new/domain/entities/new_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/new/domain/use_cases/create_patient_use_case.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// End-to-end coverage (real sqflite-ffi backed DB, real repositories/use
/// cases wired by hand - no DI container needed for this slice) for the 4
/// new PATIENT clinical boolean fields across the full
/// Create -> Load -> Update chain. Mirrors the ffi-temp-db pattern already
/// used in `test/core/services/database/app_database_service_test.dart`.
String _newTempDbPath(String testName) {
  final dir = Directory.systemTemp.createTempSync(
    'nutri_calc_clinical_flags_test_',
  );
  return '${dir.path}${Platform.pathSeparator}$testName.db';
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late AppDatabaseService db;
  late CreatePatientUseCaseImpl createPatientUseCase;
  late LoadPatientDetailsUseCaseImpl loadPatientDetailsUseCase;
  late UpdatePatientUseCaseImpl updatePatientUseCase;

  Future<void> setUpChain(String testName) async {
    db = AppDatabaseServiceImpl();
    await db.init(dbPath: _newTempDbPath(testName));

    final newPatientRepository = NewPatientRepositoryImpl(
      appDatabaseService: db,
    );
    final detailsRepository = PatientDetailsRepositoryImpl(
      databaseService: db,
    );

    createPatientUseCase = CreatePatientUseCaseImpl(
      newPatientRepository: newPatientRepository,
    );
    loadPatientDetailsUseCase = LoadPatientDetailsUseCaseImpl(
      patientDetailsRepository: detailsRepository,
    );
    updatePatientUseCase = UpdatePatientUseCaseImpl(
      detailsRepository: detailsRepository,
    );
  }

  group('Create Patient flow - clinical boolean flags', () {
    test(
      'all 4 flags default to false when the form omits them',
      () async {
        await setUpChain('create_defaults');

        final res = await createPatientUseCase.call(
          formData: NewPatientFormEntity(firstName: 'Ana', lastName: 'Silva'),
        );

        expect(res.isOk, isTrue);
        final created = (res as dynamic).value;
        expect(created.enteralNutrition, isFalse);
        expect(created.parenteralNutrition, isFalse);
        expect(created.hospitalized, isFalse);
        expect(created.confinedToBed, isFalse);
      },
    );

    test(
      'every combination of the 4 flags is saved and reloaded correctly',
      () async {
        await setUpChain('create_combinations');

        final res = await createPatientUseCase.call(
          formData: NewPatientFormEntity(
            firstName: 'Ana',
            lastName: 'Silva',
            enteralNutrition: true,
            parenteralNutrition: false,
            hospitalized: true,
            confinedToBed: false,
          ),
        );

        expect(res.isOk, isTrue);
        final createdId = (res as dynamic).value.id as String;

        final loaded = await loadPatientDetailsUseCase.call(createdId);
        expect(loaded.isOk, isTrue);
        final form = (loaded as dynamic).value;

        expect(form.enteralNutrition, isTrue);
        expect(form.parenteralNutrition, isFalse);
        expect(form.hospitalized, isTrue);
        expect(form.confinedToBed, isFalse);
      },
    );
  });

  group(
    'Edit-overwrite regression (critical - PatientDetailsRepositoryImpl.'
    'updatePatient full-column-overwrite risk)',
    () {
      test(
        'editing only an unrelated field (lastName) while all 4 flags are '
        'true does NOT silently reset them to false',
        () async {
          await setUpChain('edit_overwrite_regression_all_true');

          final createRes = await createPatientUseCase.call(
            formData: NewPatientFormEntity(
              firstName: 'Ana',
              lastName: 'Silva',
              enteralNutrition: true,
              parenteralNutrition: true,
              hospitalized: true,
              confinedToBed: true,
            ),
          );
          expect(createRes.isOk, isTrue);
          final patientId = (createRes as dynamic).value.id as String;

          final loadedBeforeEdit = await loadPatientDetailsUseCase.call(
            patientId,
          );
          expect(loadedBeforeEdit.isOk, isTrue);
          final formBeforeEdit = (loadedBeforeEdit as dynamic).value;

          // Simulate the edit flow: only change lastName, leave the form's
          // 4 flags exactly as loaded (the cubit never touches them).
          final editedForm = formBeforeEdit.copyWith(lastName: 'Souza');

          final updateRes = await updatePatientUseCase.call(editedForm);
          expect(updateRes.isOk, isTrue);

          final reloaded = await loadPatientDetailsUseCase.call(patientId);
          expect(reloaded.isOk, isTrue);
          final finalForm = (reloaded as dynamic).value;

          expect(finalForm.lastName, 'Souza');
          expect(
            finalForm.enteralNutrition,
            isTrue,
            reason: 'enteralNutrition must survive an unrelated-field edit',
          );
          expect(
            finalForm.parenteralNutrition,
            isTrue,
            reason: 'parenteralNutrition must survive an unrelated-field edit',
          );
          expect(
            finalForm.hospitalized,
            isTrue,
            reason: 'hospitalized must survive an unrelated-field edit',
          );
          expect(
            finalForm.confinedToBed,
            isTrue,
            reason: 'confinedToBed must survive an unrelated-field edit',
          );
        },
      );

      test(
        'editing only an unrelated field while all 4 flags are false does '
        'not spuriously flip them to true',
        () async {
          await setUpChain('edit_overwrite_regression_all_false');

          final createRes = await createPatientUseCase.call(
            formData: NewPatientFormEntity(firstName: 'Ana', lastName: 'Silva'),
          );
          expect(createRes.isOk, isTrue);
          final patientId = (createRes as dynamic).value.id as String;

          final loaded = await loadPatientDetailsUseCase.call(patientId);
          final editedForm = (loaded as dynamic).value.copyWith(
            firstName: 'Mariana',
          );

          final updateRes = await updatePatientUseCase.call(editedForm);
          expect(updateRes.isOk, isTrue);

          final reloaded = await loadPatientDetailsUseCase.call(patientId);
          final finalForm = (reloaded as dynamic).value;

          expect(finalForm.firstName, 'Mariana');
          expect(finalForm.enteralNutrition, isFalse);
          expect(finalForm.parenteralNutrition, isFalse);
          expect(finalForm.hospitalized, isFalse);
          expect(finalForm.confinedToBed, isFalse);
        },
      );

      test(
        'explicitly toggling one flag during edit updates only that flag '
        'and preserves the others',
        () async {
          await setUpChain('edit_toggle_single_flag');

          final createRes = await createPatientUseCase.call(
            formData: NewPatientFormEntity(
              firstName: 'Ana',
              lastName: 'Silva',
              enteralNutrition: true,
              parenteralNutrition: false,
              hospitalized: true,
              confinedToBed: false,
            ),
          );
          final patientId = (createRes as dynamic).value.id as String;

          final loaded = await loadPatientDetailsUseCase.call(patientId);
          // Dietitian unchecks "Hospitalizado" only.
          final editedForm = (loaded as dynamic).value.copyWith(
            hospitalized: false,
          );

          final updateRes = await updatePatientUseCase.call(editedForm);
          expect(updateRes.isOk, isTrue);

          final reloaded = await loadPatientDetailsUseCase.call(patientId);
          final finalForm = (reloaded as dynamic).value;

          expect(finalForm.hospitalized, isFalse);
          expect(finalForm.enteralNutrition, isTrue);
          expect(finalForm.parenteralNutrition, isFalse);
          expect(finalForm.confinedToBed, isFalse);
        },
      );
    },
  );
}
