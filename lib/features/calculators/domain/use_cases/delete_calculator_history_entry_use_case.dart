import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/delete_bmi_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/delete_energy_expenditure_use_case.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/delete_nitrogen_balance_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/delete_protein_needs_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/delete_water_needs_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/delete_enteral_nutrition_dripping_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/delete_enteral_nutrition_speed_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/delete_enteral_nutrition_volume_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/delete_glucose_infusion_rate_use_case.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/delete_weight_loss_classification_use_case.dart';
import 'package:nutri_calc/features/calculators/must/domain/use_cases/delete_must_use_case.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/use_cases/delete_nrs_2002_use_case.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/use_cases/delete_strong_kids_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/delete_weight_use_case.dart';

/// Thin orchestrator dispatching a delete to the right leaf `DeleteXUseCase`
/// by `HistorySourceType` (ADR 0010). `DeleteWeightUseCase` is reused
/// directly here (also injected into `PatientDetailsCubit.deleteWeight`) -
/// never duplicated, so a Weight-type row deleted from History and from the
/// Weights tab always go through the exact same leaf delete.
abstract class DeleteCalculatorHistoryEntryUseCase {
  Future<Result<void, String>> call(HistoryEntryEntity entry);
}

@Injectable(as: DeleteCalculatorHistoryEntryUseCase)
class DeleteCalculatorHistoryEntryUseCaseImpl
    implements DeleteCalculatorHistoryEntryUseCase {
  const DeleteCalculatorHistoryEntryUseCaseImpl({
    required this._deleteBmi,
    required this._deleteEnergyExpenditure,
    required this._deleteNitrogenBalance,
    required this._deleteProteinNeeds,
    required this._deleteWaterNeeds,
    required this._deleteEnteralNutritionDripping,
    required this._deleteEnteralNutritionSpeed,
    required this._deleteEnteralNutritionVolume,
    required this._deleteGlucoseInfusionRate,
    required this._deleteWeightLossClassification,
    required this._deleteMust,
    required this._deleteNrs2002,
    required this._deleteStrongKids,
    required this._deleteWeight,
  });

  final DeleteBmiUseCase _deleteBmi;
  final DeleteEnergyExpenditureUseCase _deleteEnergyExpenditure;
  final DeleteNitrogenBalanceUseCase _deleteNitrogenBalance;
  final DeleteProteinNeedsUseCase _deleteProteinNeeds;
  final DeleteWaterNeedsUseCase _deleteWaterNeeds;
  final DeleteEnteralNutritionDrippingUseCase _deleteEnteralNutritionDripping;
  final DeleteEnteralNutritionSpeedUseCase _deleteEnteralNutritionSpeed;
  final DeleteEnteralNutritionVolumeUseCase _deleteEnteralNutritionVolume;
  final DeleteGlucoseInfusionRateUseCase _deleteGlucoseInfusionRate;
  final DeleteWeightLossClassificationUseCase _deleteWeightLossClassification;
  final DeleteMustUseCase _deleteMust;
  final DeleteNrs2002UseCase _deleteNrs2002;
  final DeleteStrongKidsUseCase _deleteStrongKids;
  final DeleteWeightUseCase _deleteWeight;

  @override
  Future<Result<void, String>> call(HistoryEntryEntity entry) {
    return switch (entry.sourceType) {
      HistorySourceType.bmi => _deleteBmi(entry.id),
      HistorySourceType.energyExpenditure => _deleteEnergyExpenditure(entry.id),
      HistorySourceType.nitrogenBalance => _deleteNitrogenBalance(entry.id),
      HistorySourceType.proteinNeeds => _deleteProteinNeeds(entry.id),
      HistorySourceType.waterNeeds => _deleteWaterNeeds(entry.id),
      HistorySourceType.enteralNutritionDripping => _deleteEnteralNutritionDripping(entry.id),
      HistorySourceType.enteralNutritionSpeed => _deleteEnteralNutritionSpeed(entry.id),
      HistorySourceType.enteralNutritionVolume => _deleteEnteralNutritionVolume(entry.id),
      HistorySourceType.glucoseInfusionRate => _deleteGlucoseInfusionRate(entry.id),
      HistorySourceType.weightLossClassification => _deleteWeightLossClassification(entry.id),
      HistorySourceType.must => _deleteMust(entry.id),
      HistorySourceType.nrs2002 => _deleteNrs2002(entry.id),
      HistorySourceType.strongKids => _deleteStrongKids(entry.id),
      HistorySourceType.weight => _deleteWeight(entry.id),
    };
  }
}
