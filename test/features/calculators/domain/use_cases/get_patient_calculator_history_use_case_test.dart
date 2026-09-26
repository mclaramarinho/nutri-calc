import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/get_bmi_history_use_case.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/get_patient_calculator_history_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/get_energy_expenditure_history_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/get_enteral_nutrition_dripping_history_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/get_enteral_nutrition_speed_history_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/get_enteral_nutrition_volume_history_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/get_glucose_infusion_rate_history_use_case.dart';
import 'package:nutri_calc/features/calculators/must/domain/use_cases/get_must_history_use_case.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/get_nitrogen_balance_history_use_case.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/use_cases/get_nrs_2002_history_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/get_protein_needs_history_use_case.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/use_cases/get_strong_kids_history_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/get_water_needs_history_use_case.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/get_weight_loss_classification_history_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weight_history_use_case.dart';

HistoryEntryEntity _entry(String id, DateTime createdAt) => HistoryEntryEntity(
  id: id,
  patientId: 'p1',
  type: CalculatorType.bmi,
  sourceType: HistorySourceType.bmi,
  label: 'IMC',
  resultSummary: 'IMC: 22.0',
  inputParams: const [],
  createdAt: createdAt,
);

class _FakeSource<T> {
  Result<List<HistoryEntryEntity>, String> resultToReturn = const Ok([]);
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId) async {
    return resultToReturn;
  }
}

class _FakeGetBmiHistory extends _FakeSource<void> implements GetBmiHistoryUseCase {}
class _FakeGetEnergyExpenditureHistory extends _FakeSource<void> implements GetEnergyExpenditureHistoryUseCase {}
class _FakeGetNitrogenBalanceHistory extends _FakeSource<void> implements GetNitrogenBalanceHistoryUseCase {}
class _FakeGetProteinNeedsHistory extends _FakeSource<void> implements GetProteinNeedsHistoryUseCase {}
class _FakeGetWaterNeedsHistory extends _FakeSource<void> implements GetWaterNeedsHistoryUseCase {}
class _FakeGetEnteralNutritionDrippingHistory extends _FakeSource<void> implements GetEnteralNutritionDrippingHistoryUseCase {}
class _FakeGetEnteralNutritionSpeedHistory extends _FakeSource<void> implements GetEnteralNutritionSpeedHistoryUseCase {}
class _FakeGetEnteralNutritionVolumeHistory extends _FakeSource<void> implements GetEnteralNutritionVolumeHistoryUseCase {}
class _FakeGetGlucoseInfusionRateHistory extends _FakeSource<void> implements GetGlucoseInfusionRateHistoryUseCase {}
class _FakeGetWeightLossClassificationHistory extends _FakeSource<void> implements GetWeightLossClassificationHistoryUseCase {}
class _FakeGetMustHistory extends _FakeSource<void> implements GetMustHistoryUseCase {}
class _FakeGetNrs2002History extends _FakeSource<void> implements GetNrs2002HistoryUseCase {}
class _FakeGetStrongKidsHistory extends _FakeSource<void> implements GetStrongKidsHistoryUseCase {}
class _FakeGetWeightHistory extends _FakeSource<void> implements GetWeightHistoryUseCase {}

void main() {
  late _FakeGetBmiHistory bmi;
  late _FakeGetEnergyExpenditureHistory energyExpenditure;
  late _FakeGetNitrogenBalanceHistory nitrogenBalance;
  late _FakeGetProteinNeedsHistory proteinNeeds;
  late _FakeGetWaterNeedsHistory waterNeeds;
  late _FakeGetEnteralNutritionDrippingHistory enteralDripping;
  late _FakeGetEnteralNutritionSpeedHistory enteralSpeed;
  late _FakeGetEnteralNutritionVolumeHistory enteralVolume;
  late _FakeGetGlucoseInfusionRateHistory glucose;
  late _FakeGetWeightLossClassificationHistory weightLoss;
  late _FakeGetMustHistory must;
  late _FakeGetNrs2002History nrs2002;
  late _FakeGetStrongKidsHistory strongKids;
  late _FakeGetWeightHistory weight;
  late GetPatientCalculatorHistoryUseCaseImpl useCase;

  setUp(() {
    bmi = _FakeGetBmiHistory();
    energyExpenditure = _FakeGetEnergyExpenditureHistory();
    nitrogenBalance = _FakeGetNitrogenBalanceHistory();
    proteinNeeds = _FakeGetProteinNeedsHistory();
    waterNeeds = _FakeGetWaterNeedsHistory();
    enteralDripping = _FakeGetEnteralNutritionDrippingHistory();
    enteralSpeed = _FakeGetEnteralNutritionSpeedHistory();
    enteralVolume = _FakeGetEnteralNutritionVolumeHistory();
    glucose = _FakeGetGlucoseInfusionRateHistory();
    weightLoss = _FakeGetWeightLossClassificationHistory();
    must = _FakeGetMustHistory();
    nrs2002 = _FakeGetNrs2002History();
    strongKids = _FakeGetStrongKidsHistory();
    weight = _FakeGetWeightHistory();

    useCase = GetPatientCalculatorHistoryUseCaseImpl(
      getBmiHistory: bmi,
      getEnergyExpenditureHistory: energyExpenditure,
      getNitrogenBalanceHistory: nitrogenBalance,
      getProteinNeedsHistory: proteinNeeds,
      getWaterNeedsHistory: waterNeeds,
      getEnteralNutritionDrippingHistory: enteralDripping,
      getEnteralNutritionSpeedHistory: enteralSpeed,
      getEnteralNutritionVolumeHistory: enteralVolume,
      getGlucoseInfusionRateHistory: glucose,
      getWeightLossClassificationHistory: weightLoss,
      getMustHistory: must,
      getNrs2002History: nrs2002,
      getStrongKidsHistory: strongKids,
      getWeightHistory: weight,
    );
  });

  test('combines all 14 sources and sorts latest-first by createdAt', () async {
    bmi.resultToReturn = Ok([_entry('bmi1', DateTime(2026, 1, 1))]);
    weight.resultToReturn = Ok([_entry('w1', DateTime(2026, 3, 1))]);
    must.resultToReturn = Ok([_entry('must1', DateTime(2026, 2, 1))]);

    final result = await useCase('p1');

    expect(result.isOk, isTrue);
    final entries = result.getOrElse(() => []);
    expect(entries.map((e) => e.id).toList(), ['w1', 'must1', 'bmi1']);
  });

  test(
    'one source erroring degrades gracefully - other sources still returned, '
    'the whole call does not become an Error (ADR 0009 partial-failure policy)',
    () async {
      bmi.resultToReturn = const Error('bmi read failure');
      weight.resultToReturn = Ok([_entry('w1', DateTime(2026, 1, 1))]);
      must.resultToReturn = Ok([_entry('must1', DateTime(2026, 1, 2))]);

      final result = await useCase('p1');

      expect(result.isOk, isTrue);
      final entries = result.getOrElse(() => []);
      expect(entries.map((e) => e.id).toSet(), {'w1', 'must1'});
      expect(entries.any((e) => e.id == 'bmi1'), isFalse);
    },
  );

  test('all sources empty -> Ok empty list (not an Error)', () async {
    final result = await useCase('p1');

    expect(result.isOk, isTrue);
    expect(result.getOrElse(() => [_entry('fallback', DateTime.now())]), isEmpty);
  });
}
