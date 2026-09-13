import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/patients/list/domain/entities/patient_list_card_entity.dart';
import 'package:nutri_calc/features/patients/list/domain/use_cases/get_patients_list_use_case.dart';
import 'package:nutri_calc/features/patients/list/presentation/cubit/list_patients_cubit.dart';

/// Minimal fake - no mocking package is set up in this project, so a fake
/// implementing the abstract use case interface directly is the lightest
/// option that matches the project's existing (mock-free) test conventions
/// (see `new_patient_cubit_test.dart`).
class _FakeGetPatientsListUseCase implements GetPatientsListUseCase {
  _FakeGetPatientsListUseCase(this._results);

  final List<Result<List<PatientListCardEntity>, String>> _results;
  int callCount = 0;

  @override
  Future<Result<List<PatientListCardEntity>, String>> call() async {
    final result = _results[callCount.clamp(0, _results.length - 1)];
    callCount++;
    return result;
  }
}

void main() {
  group('ListPatientsCubit.init', () {
    test('emits [Loading, Initial(patients)] on success', () async {
      final fakeUseCase = _FakeGetPatientsListUseCase([
        Ok([
          const PatientListCardEntity(
            firstName: 'Ana',
            lastName: 'Silva',
            localId: '1',
          ),
        ]),
      ]);
      final cubit = ListPatientsCubit(getPatientsListUseCase: fakeUseCase);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ListPatientsStateLoading>(),
          isA<ListPatientsStateInitial>().having(
            (s) => s.patients,
            'patients',
            hasLength(1),
          ),
        ]),
      );

      await cubit.init();
      await expectation;
    });

    test('emits [Loading, Error] on failure', () async {
      final fakeUseCase = _FakeGetPatientsListUseCase([Error('boom')]);
      final cubit = ListPatientsCubit(getPatientsListUseCase: fakeUseCase);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ListPatientsStateLoading>(),
          isA<ListPatientsStateError>(),
        ]),
      );

      await cubit.init();
      await expectation;
    });

    test(
      'calling init() twice is safe (idempotent retry entrypoint): second '
      'call re-emits [Loading, Initial] after an initial failure',
      () async {
        final fakeUseCase = _FakeGetPatientsListUseCase([
          Error('boom'),
          Ok([
            const PatientListCardEntity(
              firstName: 'Ana',
              lastName: 'Silva',
              localId: '1',
            ),
          ]),
        ]);
        final cubit = ListPatientsCubit(getPatientsListUseCase: fakeUseCase);

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<ListPatientsStateLoading>(),
            isA<ListPatientsStateError>(),
            isA<ListPatientsStateLoading>(),
            isA<ListPatientsStateInitial>().having(
              (s) => s.patients,
              'patients',
              hasLength(1),
            ),
          ]),
        );

        await cubit.init();
        await cubit.init();
        await expectation;

        expect(fakeUseCase.callCount, 2);
      },
    );
  });
}
