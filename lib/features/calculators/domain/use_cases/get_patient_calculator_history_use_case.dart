import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/get_bmi_history_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/get_energy_expenditure_history_use_case.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/get_nitrogen_balance_history_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/get_protein_needs_history_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/get_water_needs_history_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/get_enteral_nutrition_dripping_history_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/get_enteral_nutrition_speed_history_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/get_enteral_nutrition_volume_history_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/get_glucose_infusion_rate_history_use_case.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/get_weight_loss_classification_history_use_case.dart';
import 'package:nutri_calc/features/calculators/must/domain/use_cases/get_must_history_use_case.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/use_cases/get_nrs_2002_history_use_case.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/use_cases/get_strong_kids_history_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weight_history_use_case.dart';

/// Thin orchestrator fanning out to all 14 leaf `GetXHistoryUseCase`s (ADR
/// 0009). `PatientDetailsCubit` injects only this one use case, not 14 -
/// keeping its already-large constructor from doubling.
abstract class GetPatientCalculatorHistoryUseCase {
  Future<Result<List<HistoryEntryEntity>, String>> call(String patientId);
}

@Injectable(as: GetPatientCalculatorHistoryUseCase)
class GetPatientCalculatorHistoryUseCaseImpl
    implements GetPatientCalculatorHistoryUseCase {
  const GetPatientCalculatorHistoryUseCaseImpl({
    required this._getBmiHistory,
    required this._getEnergyExpenditureHistory,
    required this._getNitrogenBalanceHistory,
    required this._getProteinNeedsHistory,
    required this._getWaterNeedsHistory,
    required this._getEnteralNutritionDrippingHistory,
    required this._getEnteralNutritionSpeedHistory,
    required this._getEnteralNutritionVolumeHistory,
    required this._getGlucoseInfusionRateHistory,
    required this._getWeightLossClassificationHistory,
    required this._getMustHistory,
    required this._getNrs2002History,
    required this._getStrongKidsHistory,
    required this._getWeightHistory,
  });

  final GetBmiHistoryUseCase _getBmiHistory;
  final GetEnergyExpenditureHistoryUseCase _getEnergyExpenditureHistory;
  final GetNitrogenBalanceHistoryUseCase _getNitrogenBalanceHistory;
  final GetProteinNeedsHistoryUseCase _getProteinNeedsHistory;
  final GetWaterNeedsHistoryUseCase _getWaterNeedsHistory;
  final GetEnteralNutritionDrippingHistoryUseCase _getEnteralNutritionDrippingHistory;
  final GetEnteralNutritionSpeedHistoryUseCase _getEnteralNutritionSpeedHistory;
  final GetEnteralNutritionVolumeHistoryUseCase _getEnteralNutritionVolumeHistory;
  final GetGlucoseInfusionRateHistoryUseCase _getGlucoseInfusionRateHistory;
  final GetWeightLossClassificationHistoryUseCase _getWeightLossClassificationHistory;
  final GetMustHistoryUseCase _getMustHistory;
  final GetNrs2002HistoryUseCase _getNrs2002History;
  final GetStrongKidsHistoryUseCase _getStrongKidsHistory;
  final GetWeightHistoryUseCase _getWeightHistory;

  @override
  Future<Result<List<HistoryEntryEntity>, String>> call(
    String patientId,
  ) async {
    final all = <HistoryEntryEntity>[];

    // Explicitly typed as a list of tear-offs (not the leaf use case
    // instances themselves) - a list literal of heterogeneous
    // `GetXHistoryUseCase` interface types can't be inferred as callable by
    // Dart, since they share no common `call`-typed supertype.
    final fetches = <Future<Result<List<HistoryEntryEntity>, String>> Function(String)>[
      _getBmiHistory.call,
      _getEnergyExpenditureHistory.call,
      _getNitrogenBalanceHistory.call,
      _getProteinNeedsHistory.call,
      _getWaterNeedsHistory.call,
      _getEnteralNutritionDrippingHistory.call,
      _getEnteralNutritionSpeedHistory.call,
      _getEnteralNutritionVolumeHistory.call,
      _getGlucoseInfusionRateHistory.call,
      _getWeightLossClassificationHistory.call,
      _getMustHistory.call,
      _getNrs2002History.call,
      _getStrongKidsHistory.call,
      _getWeightHistory.call,
    ];

    // Graceful degradation (ADR 0009): one source failing does not blank
    // the whole tab - that group is simply empty/incomplete.
    for (final fetch in fetches) {
      final res = await fetch(patientId);
      res.when(ok: (v) => all.addAll(v), error: (_) {});
    }

    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Ok(all);
  }
}
