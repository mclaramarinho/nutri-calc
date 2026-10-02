import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/bmi_calculator_relevance.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_definition.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_ids.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/energy_expenditure_relevance.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/presentation/widgets/energy_expenditure_sheet_body.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/enteral_nutrition_dripping_relevance.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/presentation/widgets/enteral_nutrition_dripping_sheet_body.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/enteral_nutrition_speed_relevance.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/presentation/widgets/enteral_nutrition_speed_sheet_body.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/enteral_nutrition_volume_relevance.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/presentation/widgets/enteral_nutrition_volume_sheet_body.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/glucose_infusion_rate_relevance.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/presentation/widgets/glucose_infusion_rate_sheet_body.dart';
import 'package:nutri_calc/features/calculators/ideal_weight/domain/ideal_weight_relevance.dart';
import 'package:nutri_calc/features/calculators/ideal_weight/presentation/widgets/ideal_weight_sheet_body.dart';
import 'package:nutri_calc/features/calculators/adequation/domain/adequation_relevance.dart';
import 'package:nutri_calc/features/calculators/adequation/presentation/widgets/adequation_sheet_body.dart';
import 'package:nutri_calc/features/calculators/adjusted_obesity/domain/adjusted_obesity_relevance.dart';
import 'package:nutri_calc/features/calculators/adjusted_obesity/presentation/widgets/adjusted_obesity_sheet_body.dart';
import 'package:nutri_calc/features/calculators/adjusted_dry_weight/domain/adjusted_dry_weight_relevance.dart';
import 'package:nutri_calc/features/calculators/adjusted_dry_weight/presentation/widgets/adjusted_dry_weight_sheet_body.dart';
import 'package:nutri_calc/features/calculators/estimated_weight/domain/estimated_weight_relevance.dart';
import 'package:nutri_calc/features/calculators/estimated_weight/presentation/widgets/estimated_weight_sheet_body.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/calculators/must/domain/must_relevance.dart';
import 'package:nutri_calc/features/calculators/must/presentation/widgets/must_sheet_body.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/nitrogen_balance_relevance.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/presentation/widgets/nitrogen_balance_sheet_body.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/nrs_2002_relevance.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/presentation/widgets/nrs_2002_sheet_body.dart';
import 'package:nutri_calc/features/calculators/presentation/widgets/calculator_list.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/protein_needs_relevance.dart';
import 'package:nutri_calc/features/calculators/protein_needs/presentation/widgets/protein_needs_sheet_body.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/strong_kids_relevance.dart';
import 'package:nutri_calc/features/calculators/strong_kids/presentation/widgets/strong_kids_sheet_body.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/water_needs_relevance.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/weight_loss_classification_relevance.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/resolve_weight_for_calculations.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_text_styles.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_loss_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/loss/classify_weigh_loss.usecase.dart';

// Slice 2 scope (roadmap 2.1.4, ADR 0006): a relevance-filtered/See All
// calculator list, backed by a plain, non-injected CalculatorDefinition
// registry assembled here. Only BMI registers this slice; the remaining
// calculator types are deferred to later slices.
class PatientCalculatorsTab extends StatelessWidget {
  const PatientCalculatorsTab({super.key});

  String _classificationLabel(
    BuildContext context,
    BmiClassification classification,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (classification) {
      case .low:
        return l10n.patientCalculatorsTabBmiClassificationLow;
      case .eutrophy:
        return l10n.patientCalculatorsTabBmiClassificationEutrophy;
      case .overweight:
        return l10n.patientCalculatorsTabBmiClassificationOverweight;
      case .obesity:
        return l10n.patientCalculatorsTabBmiClassificationObesity;
      case .obesityGrade2:
        return l10n.patientCalculatorsTabBmiClassificationObesityGrade2;
      case .obesityGrade3:
        return l10n.patientCalculatorsTabBmiClassificationObesityGrade3;
    }
  }

  String _weightLossClassificationLabel(
    BuildContext context,
    WeightLossClassification classification,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (classification) {
      case .ok:
        return l10n.patientCalculatorsTabWeightLossClassificationOk;
      case .significant:
        return l10n.patientCalculatorsTabWeightLossClassificationSignificant;
      case .severe:
        return l10n.patientCalculatorsTabWeightLossClassificationSevere;
    }
  }

  Future<void> _openBmiBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bmi = state.bmi;

    if (bmi == null) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabImcName,
        body: Text(l10n.patientCalculatorsTabImcInsufficientDataMessage),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final weight = state.weights.first;
    final height = state.heights.first;
    final age = state.form.age;

    final confirmed = await DsBottomSheet.show<bool>(
      context,
      title: l10n.patientCalculatorsTabImcName,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsSpacing.sm,
        children: [
          Text(l10n.patientCalculatorsTabWeightLabel("${weight.value}")),
          Text(l10n.patientCalculatorsTabHeightLabel("${height.value}")),
          Text(l10n.patientCalculatorsTabAgeLabel("${age ?? '-'}")),
          SizedBox(height: DsSpacing.sm),
          Text(
            l10n.patientCalculatorsTabImcResultLabel(
              bmi.value.toStringAsFixed(2),
              _classificationLabel(context, bmi.classification),
            ),
            style: DsTextStyles.resultBold(context),
          ),
        ],
      ),
      actions: [
        Expanded(
          child: DsButton(
            label: l10n.patientCalculatorsTabCancelButton,
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(false),
          ),
        ),
        Expanded(
          child: DsButton(
            label: l10n.patientCalculatorsTabConfirmButton,
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(true),
          ),
        ),
      ],
    );

    if (confirmed == true) {
      await cubit.saveBmiCalculation();
    }
  }

  Future<void> _openEnergyExpenditureBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (state.weights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabEnergyExpenditureName,
        body: Text(
          l10n.patientCalculatorsTabEnergyExpenditureInsufficientDataMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final weight = state.weights.first;
    final height = state.heights.isNotEmpty ? state.heights.first : null;
    final age = state.form.age;

    final gathered = await DsBottomSheet.show<GatheredEnergyExpenditureInputs?>(
      context,
      title: l10n.patientCalculatorsTabEnergyExpenditureName,
      body: EnergyExpenditureSheetBody(
        weightKg: weight.value,
        heightCm: height?.value,
        age: age,
      ),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveEnergyExpenditureCalculation(
        formula: gathered.formula,
        gender: gathered.gender,
        activityFactor: gathered.activityFactor,
        injuryFactor: gathered.injuryFactor,
        temperatureFactor: gathered.temperatureFactor,
        stressLevel: gathered.stressLevel,
      );
    }
  }

  Future<void> _openNitrogenBalanceBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    // Both inputs are fully manual - nothing derived from patient data, so
    // there's no insufficient-data pre-gate.
    final gathered = await DsBottomSheet.show<GatheredNitrogenBalanceInputs?>(
      context,
      title: AppLocalizations.of(context).patientCalculatorsTabNitrogenBalanceName,
      body: const NitrogenBalanceSheetBody(),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveNitrogenBalanceCalculation(
        ingestedProtein: gathered.ingestedProtein,
        urineNitrogen24h: gathered.urineNitrogen24h,
      );
    }
  }

  Future<void> _openProteinNeedsBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (state.weights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabProteinNeedsName,
        body: Text(
          l10n.patientCalculatorsTabProteinNeedsInsufficientDataMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final weight = state.weights.first;

    final gathered = await DsBottomSheet.show<GatheredProteinNeedsInputs?>(
      context,
      title: l10n.patientCalculatorsTabProteinNeedsName,
      body: ProteinNeedsSheetBody(weightKg: weight.value),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveProteinNeedsCalculation(
        patientState: gathered.patientState,
      );
    }
  }

  Future<void> _openWaterNeedsBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final age = state.form.age;

    if (state.weights.isEmpty || age == null) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabWaterNeedsName,
        body: Text(l10n.patientCalculatorsTabWaterNeedsInsufficientDataMessage),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final weight = state.weights.first;

    final confirmed = await DsBottomSheet.show<bool>(
      context,
      title: l10n.patientCalculatorsTabWaterNeedsName,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsSpacing.sm,
        children: [
          Text(l10n.patientCalculatorsTabWeightLabel("${weight.value}")),
          Text(l10n.patientCalculatorsTabAgeLabel("$age")),
        ],
      ),
      actions: [
        Expanded(
          child: DsButton(
            label: l10n.patientCalculatorsTabCancelButton,
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(false),
          ),
        ),
        Expanded(
          child: DsButton(
            label: l10n.patientCalculatorsTabConfirmButton,
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(true),
          ),
        ),
      ],
    );

    if (confirmed == true) {
      await cubit.saveWaterNeedsCalculation();
    }
  }

  Future<void> _openWeightLossClassificationBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (state.weights.length < 2) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabWeightLossClassificationName,
        body: Text(
          l10n
              .patientCalculatorsTabWeightLossClassificationInsufficientDataMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final currentWeight = state.weights[0]; // newest, per §0's sort
    final lastWeight = state.weights[1];

    final result = ClassifyWeighLoss().call(
      currentWeight: currentWeight.value,
      lastWeight: lastWeight.value,
      lastWeightDate: lastWeight.createdAt,
      currentWeightDate: currentWeight.createdAt,
    );

    final confirmed = await DsBottomSheet.show<bool>(
      context,
      title: l10n.patientCalculatorsTabWeightLossClassificationName,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsSpacing.sm,
        children: [
          Text(
            l10n.patientCalculatorsTabCurrentWeightLabel(
              "${currentWeight.value}",
              currentWeight.createdAt.formattedDate(),
            ),
          ),
          Text(
            l10n.patientCalculatorsTabLastWeightLabel(
              "${lastWeight.value}",
              lastWeight.createdAt.formattedDate(),
            ),
          ),
          if (result.isOk) ...[
            SizedBox(height: DsSpacing.sm),
            Text(
              l10n.patientCalculatorsTabWeightLossResultLabel(
                _weightLossClassificationLabel(
                  context,
                  (result as Ok<WeightLoss, String>).value.classification,
                ),
              ),
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
      actions: [
        Expanded(
          child: DsButton(
            label: l10n.patientCalculatorsTabCancelButton,
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(false),
          ),
        ),
        Expanded(
          child: DsButton(
            label: l10n.patientCalculatorsTabConfirmButton,
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(true),
          ),
        ),
      ],
    );

    if (confirmed == true) {
      await cubit.saveWeightLossClassificationCalculation();
    }
  }

  Future<void> _openEnteralNutritionDrippingBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    // Both inputs are fully manual - nothing derived from patient data, so
    // there's no insufficient-data pre-gate.
    final gathered =
        await DsBottomSheet.show<GatheredEnteralNutritionDrippingInputs?>(
          context,
          title: AppLocalizations.of(
            context,
          ).patientCalculatorsTabEnteralDrippingName,
          body: const EnteralNutritionDrippingSheetBody(),
          actions: null,
        );

    if (gathered != null) {
      await cubit.saveEnteralNutritionDrippingCalculation(
        totalVolume: gathered.totalVolume,
        totalHoursForVolume: gathered.totalHoursForVolume,
      );
    }
  }

  Future<void> _openEnteralNutritionSpeedBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    // The single input is fully manual - nothing derived from patient data,
    // so there's no insufficient-data pre-gate.
    final gathered =
        await DsBottomSheet.show<GatheredEnteralNutritionSpeedInputs?>(
          context,
          title: AppLocalizations.of(
            context,
          ).patientCalculatorsTabEnteralSpeedName,
          body: const EnteralNutritionSpeedSheetBody(),
          actions: null,
        );

    if (gathered != null) {
      await cubit.saveEnteralNutritionSpeedCalculation(
        totalDailyVolume: gathered.totalDailyVolume,
      );
    }
  }

  Future<void> _openEnteralNutritionVolumeBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    // Both inputs are fully manual - nothing derived from patient data, so
    // there's no insufficient-data pre-gate.
    final gathered =
        await DsBottomSheet.show<GatheredEnteralNutritionVolumeInputs?>(
          context,
          title: AppLocalizations.of(
            context,
          ).patientCalculatorsTabEnteralVolumeName,
          body: const EnteralNutritionVolumeSheetBody(),
          actions: null,
        );

    if (gathered != null) {
      await cubit.saveEnteralNutritionVolumeCalculation(
        totalDailyEnergy: gathered.totalDailyEnergy,
        caloricDensityOfDiet: gathered.caloricDensityOfDiet,
      );
    }
  }

  Future<void> _openGlucoseInfusionRateBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (state.weights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabGlucoseInfusionRateName,
        body: Text(
          l10n.patientCalculatorsTabGlucoseInfusionRateInsufficientDataMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final weight = state.weights.first;

    final gathered =
        await DsBottomSheet.show<GatheredGlucoseInfusionRateInputs?>(
          context,
          title: l10n.patientCalculatorsTabGlucoseInfusionRateName,
          body: GlucoseInfusionRateSheetBody(weightKg: weight.value),
          actions: null,
        );

    if (gathered != null) {
      await cubit.saveGlucoseInfusionRateCalculation(
        totalGlucose: gathered.totalGlucose,
      );
    }
  }

  Future<void> _openIdealWeightBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    // Only height gates per design's own copy - gender is never a
    // pre-gate condition, it's a fillable control (same precedent as
    // Energy Expenditure). `weight`, though invisible in the UI, IS
    // required by `CalculateIdealWeight`'s signature (its `weight < 0`
    // validation guard), so this calculator is also insufficient-data-gated
    // when there is no weight at all - a deliberate addition beyond
    // design's original copy, which only anticipated the height gate.
    final l10n = AppLocalizations.of(context);
    if (state.heights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabIdealWeightName,
        body: Text(
          l10n.patientCalculatorsTabIdealWeightInsufficientHeightMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    if (state.weights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabIdealWeightName,
        body: Text(
          l10n.patientCalculatorsTabIdealWeightInsufficientWeightMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final height = state.heights.first; // newest, per §0's sort
    // Preview-only resolution (mirrors the cubit's own independent
    // resolution on save) - not one of ADR 0007's deferred sites since this
    // is a brand-new call site introduced this slice.
    final weight =
        const ResolveWeightForCalculations()(state.weights) ??
        state.weights.first;

    final gathered = await DsBottomSheet.show<GatheredIdealWeightInputs?>(
      context,
      title: l10n.patientCalculatorsTabIdealWeightName,
      body: IdealWeightSheetBody(
        heightCm: height.value,
        weightKg: weight.value,
      ),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveIdealWeightCalculation(
        gender: gathered.gender,
        considerForCalculations: gathered.considerForCalculations,
      );
    }
  }

  // Adequation and Adjusted Obesity share the same soft dependency on an
  // existing Ideal Weight row (Slice 10 po decision, 2026-09-26) - resolved
  // here as the most recent WEIGHTS row with `weightType == .ideal`.
  WeightEntity? _resolveLatestIdealWeight(PatientDetailsStateLoaded state) {
    for (final w in state.weights) {
      if (w.weightType == WeightTypeEnum.ideal) return w;
    }
    return null;
  }

  Future<void> _openAdequationBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (state.weights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabAdequationName,
        body: Text(l10n.patientCalculatorsTabAdequationInsufficientDataMessage),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final idealWeight = _resolveLatestIdealWeight(state);
    if (idealWeight == null) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabAdequationName,
        body: Text(l10n.patientCalculatorsTabIdealWeightRequiredMessage),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final currentWeight =
        const ResolveWeightForCalculations()(state.weights) ??
        state.weights.first;

    final gathered = await DsBottomSheet.show<GatheredAdequationInputs?>(
      context,
      title: l10n.patientCalculatorsTabAdequationName,
      body: AdequationSheetBody(
        currentWeight: currentWeight.value,
        idealWeight: idealWeight.value,
      ),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveAdequationCalculation(
        considerForCalculations: gathered.considerForCalculations,
      );
    }
  }

  Future<void> _openAdjustedObesityBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (state.weights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabAdjustedObesityName,
        body: Text(
          l10n.patientCalculatorsTabAdjustedObesityInsufficientDataMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final idealWeight = _resolveLatestIdealWeight(state);
    if (idealWeight == null) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabAdjustedObesityName,
        body: Text(l10n.patientCalculatorsTabIdealWeightRequiredMessage),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final currentWeight =
        const ResolveWeightForCalculations()(state.weights) ??
        state.weights.first;

    final gathered = await DsBottomSheet.show<GatheredAdjustedObesityInputs?>(
      context,
      title: l10n.patientCalculatorsTabAdjustedObesityName,
      body: AdjustedObesitySheetBody(
        currentWeight: currentWeight.value,
        idealWeight: idealWeight.value,
      ),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveAdjustedObesityCalculation(
        considerForCalculations: gathered.considerForCalculations,
      );
    }
  }

  Future<void> _openAdjustedDryWeightBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (state.weights.isEmpty || state.bmi == null) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabAdjustedDryWeightName,
        body: Text(
          l10n.patientCalculatorsTabAdjustedDryWeightInsufficientDataMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final currentWeight =
        const ResolveWeightForCalculations()(state.weights) ??
        state.weights.first;

    final gathered = await DsBottomSheet.show<GatheredAdjustedDryWeightInputs?>(
      context,
      title: l10n.patientCalculatorsTabAdjustedDryWeightName,
      body: AdjustedDryWeightSheetBody(
        currentWeight: currentWeight.value,
        imc: state.bmi!,
      ),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveAdjustedDryWeightCalculation(
        ascitis: gathered.ascitis,
        oedema: gathered.oedema,
        considerForCalculations: gathered.considerForCalculations,
      );
    }
  }

  Future<void> _openEstimatedWeightBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final age = state.form.age;

    if (age == null) {
      await DsBottomSheet.show<void>(
        context,
        title: l10n.patientCalculatorsTabEstimatedWeightName,
        body: Text(
          l10n.patientCalculatorsTabEstimatedWeightInsufficientAgeMessage,
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: l10n.patientCalculatorsTabCloseButton,
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final gathered = await DsBottomSheet.show<GatheredEstimatedWeightInputs?>(
      context,
      title: l10n.patientCalculatorsTabEstimatedWeightName,
      body: EstimatedWeightSheetBody(age: age),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveEstimatedWeightCalculation(
        kneeHeight: gathered.kneeHeight,
        armCircumference: gathered.armCircumference,
        gender: gathered.gender,
        ethnicity: gathered.ethnicity,
        considerForCalculations: gathered.considerForCalculations,
      );
    }
  }

  Future<void> _openMustBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    // The BMI field is only a convenience prefill from patient data — the
    // tool remains fully usable (and its Calcular gate fully manual) with
    // no BMI on file, so there is no insufficient-data pre-gate here.
    final gathered = await DsBottomSheet.show<GatheredMustInputs?>(
      context,
      title: AppLocalizations.of(context).patientCalculatorsTabMustName,
      body: MustSheetBody(currentBmi: state.bmi?.value),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveMustCalculation(
        bmi: gathered.bmi,
        avgWeightLossIn3To6Months: gathered.avgWeightLossIn3To6Months,
        severeIllnessPresent: gathered.severeIllnessPresent,
        reducedFoodIntakeForMoreThan5Days:
            gathered.reducedFoodIntakeForMoreThan5Days,
        willReduceFoodIntakeForMoreThan5Days:
            gathered.willReduceFoodIntakeForMoreThan5Days,
      );
    }
  }

  Future<void> _openNrs2002BottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final age = state.form.age;

    final gathered = await DsBottomSheet.show<GatheredNrs2002Inputs?>(
      context,
      title: AppLocalizations.of(context).patientCalculatorsTabNrs2002Name,
      body: Nrs2002SheetBody(age: age),
      actions: null,
    );

    if (gathered != null && age != null) {
      await cubit.saveNrs2002Calculation(
        isSeverelyIll: gathered.isSeverelyIll,
        weightLossLast3Months: gathered.weightLossLast3Months,
        reducedFoodIntakeLastWeek: gathered.reducedFoodIntakeLastWeek,
        lowBmi: gathered.lowBmi,
        nutritionalStatusClassification:
            gathered.nutritionalStatusClassification,
        illnessSeverityClassification: gathered.illnessSeverityClassification,
      );
    }
  }

  Future<void> _openStrongKidsBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    // All 4 questions are fully manual - nothing derived from patient data,
    // so there's no insufficient-data pre-gate.
    final gathered = await DsBottomSheet.show<GatheredStrongKidsInputs?>(
      context,
      title: AppLocalizations.of(context).patientCalculatorsTabStrongKidsName,
      body: const StrongKidsSheetBody(),
      actions: null,
    );

    if (gathered != null) {
      await cubit.saveStrongKidsCalculation(
        clinicalAppearanceOfMalnutrition:
            gathered.clinicalAppearanceOfMalnutrition,
        highRiskDiseasePresent: gathered.highRiskDiseasePresent,
        reducedIntakeOrLosses: gathered.reducedIntakeOrLosses,
        weightLossOrGrowthDeficit: gathered.weightLossOrGrowthDeficit,
      );
    }
  }

  List<CalculatorDefinition> _buildDefinitions(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) {
    final l10n = AppLocalizations.of(context);
    return [
      CalculatorDefinition(
        id: CalculatorIds.bmi,
        type: CalculatorType.bmi,
        name: l10n.patientCalculatorsTabImcName,
        isRelevant: isBmiRelevant,
        onTap: (ctx) => _openBmiBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.energyExpenditure,
        type: CalculatorType.energyExpenditure,
        name: l10n.patientCalculatorsTabEnergyExpenditureName,
        isRelevant: isEnergyExpenditureRelevant,
        onTap: (ctx) => _openEnergyExpenditureBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.nitrogenBalance,
        type: CalculatorType.nitrogenBalance,
        name: l10n.patientCalculatorsTabNitrogenBalanceName,
        isRelevant: isNitrogenBalanceRelevant,
        onTap: (ctx) => _openNitrogenBalanceBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.proteinNeeds,
        type: CalculatorType.proteinNeeds,
        name: l10n.patientCalculatorsTabProteinNeedsName,
        isRelevant: isProteinNeedsRelevant,
        onTap: (ctx) => _openProteinNeedsBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.waterNeeds,
        type: CalculatorType.waterNeeds,
        name: l10n.patientCalculatorsTabWaterNeedsName,
        isRelevant: isWaterNeedsRelevant,
        onTap: (ctx) => _openWaterNeedsBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.enteralNutritionDripping,
        type: CalculatorType.enteralNutrition,
        name: l10n.patientCalculatorsTabEnteralDrippingName,
        isRelevant: isEnteralNutritionDrippingRelevant,
        onTap: (ctx) =>
            _openEnteralNutritionDrippingBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.enteralNutritionSpeed,
        type: CalculatorType.enteralNutrition,
        name: l10n.patientCalculatorsTabEnteralSpeedName,
        isRelevant: isEnteralNutritionSpeedRelevant,
        onTap: (ctx) =>
            _openEnteralNutritionSpeedBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.enteralNutritionVolume,
        type: CalculatorType.enteralNutrition,
        name: l10n.patientCalculatorsTabEnteralVolumeName,
        isRelevant: isEnteralNutritionVolumeRelevant,
        onTap: (ctx) =>
            _openEnteralNutritionVolumeBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.glucoseInfusionRate,
        type: CalculatorType.parenteralNutrition,
        name: l10n.patientCalculatorsTabGlucoseInfusionRateName,
        isRelevant: isGlucoseInfusionRateRelevant,
        onTap: (ctx) => _openGlucoseInfusionRateBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.weightLossClassification,
        type: CalculatorType.weightLossClassification,
        name: l10n.patientCalculatorsTabWeightLossClassificationName,
        isRelevant: isWeightLossClassificationRelevant,
        onTap: (ctx) =>
            _openWeightLossClassificationBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.must,
        type: CalculatorType.screening,
        name: l10n.patientCalculatorsTabMustName,
        isRelevant: isMustRelevant,
        onTap: (ctx) => _openMustBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.nrs2002,
        type: CalculatorType.screening,
        name: l10n.patientCalculatorsTabNrs2002Name,
        isRelevant: isNrs2002Relevant,
        onTap: (ctx) => _openNrs2002BottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.strongKids,
        type: CalculatorType.screening,
        name: l10n.patientCalculatorsTabStrongKidsName,
        isRelevant: isStrongKidsRelevant,
        onTap: (ctx) => _openStrongKidsBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.idealWeight,
        type: CalculatorType.weight,
        name: l10n.patientCalculatorsTabIdealWeightName,
        isRelevant: isIdealWeightRelevant,
        onTap: (ctx) => _openIdealWeightBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.adequation,
        type: CalculatorType.weight,
        name: WeightTypeEnum.adequation.label,
        isRelevant: isAdequationRelevant,
        onTap: (ctx) => _openAdequationBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.adjustedObesity,
        type: CalculatorType.weight,
        name: WeightTypeEnum.adjustedObesity.label,
        isRelevant: isAdjustedObesityRelevant,
        onTap: (ctx) => _openAdjustedObesityBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.adjustedDryWeight,
        type: CalculatorType.weight,
        name: WeightTypeEnum.adjustedDryWeight.label,
        isRelevant: isAdjustedDryWeightRelevant,
        onTap: (ctx) => _openAdjustedDryWeightBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: CalculatorIds.estimatedWeight,
        type: CalculatorType.weight,
        name: WeightTypeEnum.estimated.label,
        isRelevant: isEstimatedWeightRelevant,
        onTap: (ctx) => _openEstimatedWeightBottomSheet(ctx, cubit, state),
      ),
    ];
  }

  CalculatorRelevanceContext _buildRelevanceContext(
    PatientDetailsStateLoaded state,
  ) {
    return CalculatorRelevanceContext(
      age: state.form.age,
      ageUnit: state.form.ageUnit,
      enteralNutrition: state.form.enteralNutrition,
      parenteralNutrition: state.form.parenteralNutrition,
      hospitalized: state.form.hospitalized,
      confinedToBed: state.form.confinedToBed,
      weights: state.weights,
      bmi: state.bmi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        if (state is! PatientDetailsStateLoaded) {
          return CircularProgressIndicator();
        }

        final cubit = context.read<PatientDetailsCubit>();

        return CalculatorList(
          definitions: _buildDefinitions(context, cubit, state),
          relevanceContext: _buildRelevanceContext(state),
        );
      },
    );
  }
}
