import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/delete_bmi_use_case.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/delete_calculator_history_entry_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/delete_energy_expenditure_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/delete_enteral_nutrition_dripping_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/delete_enteral_nutrition_speed_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/delete_enteral_nutrition_volume_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/delete_glucose_infusion_rate_use_case.dart';
import 'package:nutri_calc/features/calculators/must/domain/use_cases/delete_must_use_case.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/delete_nitrogen_balance_use_case.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/use_cases/delete_nrs_2002_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/delete_protein_needs_use_case.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/use_cases/delete_strong_kids_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/delete_water_needs_use_case.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/delete_weight_loss_classification_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/delete_weight_use_case.dart';

class _FakeDelete {
  String? lastId;
  int callCount = 0;
  Result<void, String> resultToReturn = const Ok(null);
  Future<Result<void, String>> call(String id) async {
    lastId = id;
    callCount++;
    return resultToReturn;
  }
}

class _FakeDeleteBmi extends _FakeDelete implements DeleteBmiUseCase {}
class _FakeDeleteEnergyExpenditure extends _FakeDelete implements DeleteEnergyExpenditureUseCase {}
class _FakeDeleteNitrogenBalance extends _FakeDelete implements DeleteNitrogenBalanceUseCase {}
class _FakeDeleteProteinNeeds extends _FakeDelete implements DeleteProteinNeedsUseCase {}
class _FakeDeleteWaterNeeds extends _FakeDelete implements DeleteWaterNeedsUseCase {}
class _FakeDeleteEnteralNutritionDripping extends _FakeDelete implements DeleteEnteralNutritionDrippingUseCase {}
class _FakeDeleteEnteralNutritionSpeed extends _FakeDelete implements DeleteEnteralNutritionSpeedUseCase {}
class _FakeDeleteEnteralNutritionVolume extends _FakeDelete implements DeleteEnteralNutritionVolumeUseCase {}
class _FakeDeleteGlucoseInfusionRate extends _FakeDelete implements DeleteGlucoseInfusionRateUseCase {}
class _FakeDeleteWeightLossClassification extends _FakeDelete implements DeleteWeightLossClassificationUseCase {}
class _FakeDeleteMust extends _FakeDelete implements DeleteMustUseCase {}
class _FakeDeleteNrs2002 extends _FakeDelete implements DeleteNrs2002UseCase {}
class _FakeDeleteStrongKids extends _FakeDelete implements DeleteStrongKidsUseCase {}
class _FakeDeleteWeight extends _FakeDelete implements DeleteWeightUseCase {}

HistoryEntryEntity _entry(HistorySourceType sourceType, String id) => HistoryEntryEntity(
  id: id,
  patientId: 'p1',
  type: CalculatorType.bmi,
  sourceType: sourceType,
  label: 'label',
  resultSummary: 'summary',
  inputParams: const [],
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  late _FakeDeleteBmi deleteBmi;
  late _FakeDeleteWeight deleteWeight;
  late DeleteCalculatorHistoryEntryUseCaseImpl useCase;

  setUp(() {
    deleteBmi = _FakeDeleteBmi();
    deleteWeight = _FakeDeleteWeight();

    useCase = DeleteCalculatorHistoryEntryUseCaseImpl(
      deleteBmi: deleteBmi,
      deleteEnergyExpenditure: _FakeDeleteEnergyExpenditure(),
      deleteNitrogenBalance: _FakeDeleteNitrogenBalance(),
      deleteProteinNeeds: _FakeDeleteProteinNeeds(),
      deleteWaterNeeds: _FakeDeleteWaterNeeds(),
      deleteEnteralNutritionDripping: _FakeDeleteEnteralNutritionDripping(),
      deleteEnteralNutritionSpeed: _FakeDeleteEnteralNutritionSpeed(),
      deleteEnteralNutritionVolume: _FakeDeleteEnteralNutritionVolume(),
      deleteGlucoseInfusionRate: _FakeDeleteGlucoseInfusionRate(),
      deleteWeightLossClassification: _FakeDeleteWeightLossClassification(),
      deleteMust: _FakeDeleteMust(),
      deleteNrs2002: _FakeDeleteNrs2002(),
      deleteStrongKids: _FakeDeleteStrongKids(),
      deleteWeight: deleteWeight,
    );
  });

  test('a bmi-sourced entry dispatches to DeleteBmiUseCase only', () async {
    await useCase(_entry(HistorySourceType.bmi, 'bmi1'));

    expect(deleteBmi.callCount, 1);
    expect(deleteBmi.lastId, 'bmi1');
    expect(deleteWeight.callCount, 0);
  });

  test(
    'a weight-sourced entry dispatches to the same DeleteWeightUseCase '
    'instance PatientDetailsCubit.deleteWeight uses (ADR 0010 - no second, '
    'independently-written Weight-delete code path)',
    () async {
      await useCase(_entry(HistorySourceType.weight, 'w1'));

      expect(deleteWeight.callCount, 1);
      expect(deleteWeight.lastId, 'w1');
      expect(deleteBmi.callCount, 0);
    },
  );
}
