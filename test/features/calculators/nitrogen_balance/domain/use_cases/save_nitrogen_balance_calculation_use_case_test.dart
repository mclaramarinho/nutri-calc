import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/entities/nitrogen_balance_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/repositories/nitrogen_balance_repository.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/save_nitrogen_balance_calculation_use_case.dart';

/// Fake implementing the abstract repository interface directly - no
/// mocking library, mirrors the fake pattern used throughout this codebase.
class _FakeNitrogenBalanceRepository implements NitrogenBalanceRepository {
  Result<NitrogenBalanceCalculationEntity, String>? nextResult;
  NitrogenBalanceCalculationEntity? lastReceived;

  @override
  Future<Result<NitrogenBalanceCalculationEntity, String>> createNitrogenBalance(
    NitrogenBalanceCalculationEntity nitrogenBalance,
  ) async {
    lastReceived = nitrogenBalance;
    return nextResult ?? Ok(nitrogenBalance);
  }
}

void main() {
  late _FakeNitrogenBalanceRepository fakeRepository;
  late SaveNitrogenBalanceCalculationUseCaseImpl useCase;

  setUp(() {
    fakeRepository = _FakeNitrogenBalanceRepository();
    useCase = SaveNitrogenBalanceCalculationUseCaseImpl(
      repository: fakeRepository,
    );
  });

  test(
    'success path: calculates the nitrogen balance, builds inputParams and '
    'persists via the repository, returning Ok',
    () async {
      final res = await useCase.call(
        patientId: 'patient-a',
        ingestedProtein: 90,
        urineNitrogen24h: 10,
      );

      expect(res.isOk, isTrue);
      final value = res.getOrElse(() => throw StateError('expected Ok'));

      // BN = (90 / 6.25) / (10 / 4) = 14.4 / 2.5 = 5.76
      expect(value.value, closeTo(5.76, 0.001));
      expect(value.patientId, 'patient-a');

      expect(fakeRepository.lastReceived, isNotNull);
      final received = fakeRepository.lastReceived!;
      expect(received.patientId, 'patient-a');
      expect(received.value, closeTo(5.76, 0.001));
      expect(received.inputParams, hasLength(2));
      expect(received.inputParams[0].key, 'ingested_protein');
      expect(received.inputParams[0].value, 90);
      expect(received.inputParams[1].key, 'urine_nitrogen_24h');
      expect(received.inputParams[1].value, 10);
    },
  );

  test(
    'INVALID_PARAMS: negative ingestedProtein propagates as Error, not '
    'thrown',
    () async {
      final res = await useCase.call(
        patientId: 'patient-b',
        ingestedProtein: -1,
        urineNitrogen24h: 10,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'INVALID_PARAMS'),
      );
      expect(fakeRepository.lastReceived, isNull);
    },
  );

  test(
    'error path: repository returning Error propagates as Error, not thrown',
    () async {
      fakeRepository.nextResult = const Error('DB failure');

      final res = await useCase.call(
        patientId: 'patient-c',
        ingestedProtein: 90,
        urineNitrogen24h: 10,
      );

      expect(res.isError, isTrue);
      res.when(
        ok: (_) => fail('expected Error'),
        error: (err) => expect(err, 'DB failure'),
      );
    },
  );
}
