import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_type_enum.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/create_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/get_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/create_height_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/update_patient_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/bmi/calculate_bmi.usecase.dart';
import 'package:nutri_calc/shared/utils/entities/age_entity.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';
import 'package:nutri_calc/shared/utils/extensions/ext_age.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/save_bmi_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/entities/energy_expenditure_formula.enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/use_cases/save_energy_expenditure_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_dripping/domain/use_cases/save_enteral_nutrition_dripping_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_speed/domain/use_cases/save_enteral_nutrition_speed_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/enteral_nutrition_volume/domain/use_cases/save_enteral_nutrition_volume_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/glucose_infusion_rate/domain/use_cases/save_glucose_infusion_rate_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/ideal_weight/domain/use_cases/save_ideal_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/must/domain/use_cases/save_must_calculation_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/resolve_weight_for_calculations.dart';
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/save_nitrogen_balance_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/nrs_2002/domain/use_cases/save_nrs_2002_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/save_protein_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/strong_kids/domain/use_cases/save_strong_kids_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/save_water_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/weight_loss_classification/domain/use_cases/save_weight_loss_classification_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_step_2_classification.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';

part 'patient_details_cubit.dart';

// Sentinel used by [PatientDetailsStateLoaded.copyWith] to distinguish
// "argument omitted" (keep current value) from "argument explicitly passed
// as null" (force the field back to null) for nullable fields, since a
// plain `param ?? this.field` pattern can never set a field back to null.
const Object _unset = Object();

enum PatientDetailsFormOptions { weights, heights, bodyMeasurements }

abstract class PatientDetailsState extends Equatable {}

class PatientDetailsStateInitial extends PatientDetailsState {
  PatientDetailsStateInitial();

  @override
  List<Object?> get props => [];
}

class PatientDetailsStateError extends PatientDetailsState {
  PatientDetailsStateError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class PatientDetailsStateLoaded extends PatientDetailsState {
  PatientDetailsStateLoaded({
    required this.form,
    this.isEditing = false,
    this.isSaving = false,
    this.isSaved = false,
    this.isSaveError = false,
    this.saveErrorMessage,
    this.isSavingWeight = false,
    this.weights = const [],
    this.newWeight,
    this.isSavingHeight = false,
    this.heights = const [],
    this.newHeight,
    this.newBodyMeasurementType,
    this.newBodyMeasurementValue,
    this.isSavingNewBodyMeasurement = false,
    this.measurements = const [],
    this.bmi,
    this.isSavingBmi = false,
    this.isBmiSaveError = false,
    this.bmiSaveErrorMessage,
    this.isBmiSaved = false,
    this.isSavingEnergyExpenditure = false,
    this.isEnergyExpenditureSaveError = false,
    this.energyExpenditureSaveErrorMessage,
    this.isEnergyExpenditureSaved = false,
    this.isSavingNitrogenBalance = false,
    this.isNitrogenBalanceSaveError = false,
    this.nitrogenBalanceSaveErrorMessage,
    this.isNitrogenBalanceSaved = false,
    this.isSavingProteinNeeds = false,
    this.isProteinNeedsSaveError = false,
    this.proteinNeedsSaveErrorMessage,
    this.isProteinNeedsSaved = false,
    this.isSavingWaterNeeds = false,
    this.isWaterNeedsSaveError = false,
    this.waterNeedsSaveErrorMessage,
    this.isWaterNeedsSaved = false,
    this.isSavingEnteralNutritionDripping = false,
    this.isEnteralNutritionDrippingSaveError = false,
    this.enteralNutritionDrippingSaveErrorMessage,
    this.isEnteralNutritionDrippingSaved = false,
    this.isSavingEnteralNutritionSpeed = false,
    this.isEnteralNutritionSpeedSaveError = false,
    this.enteralNutritionSpeedSaveErrorMessage,
    this.isEnteralNutritionSpeedSaved = false,
    this.isSavingEnteralNutritionVolume = false,
    this.isEnteralNutritionVolumeSaveError = false,
    this.enteralNutritionVolumeSaveErrorMessage,
    this.isEnteralNutritionVolumeSaved = false,
    this.isSavingGlucoseInfusionRate = false,
    this.isGlucoseInfusionRateSaveError = false,
    this.glucoseInfusionRateSaveErrorMessage,
    this.isGlucoseInfusionRateSaved = false,
    this.isSavingWeightLossClassification = false,
    this.isWeightLossClassificationSaveError = false,
    this.weightLossClassificationSaveErrorMessage,
    this.isWeightLossClassificationSaved = false,
    this.isSavingMust = false,
    this.isMustSaveError = false,
    this.mustSaveErrorMessage,
    this.isMustSaved = false,
    this.isSavingNrs2002 = false,
    this.isNrs2002SaveError = false,
    this.nrs2002SaveErrorMessage,
    this.isNrs2002Saved = false,
    this.isSavingStrongKids = false,
    this.isStrongKidsSaveError = false,
    this.strongKidsSaveErrorMessage,
    this.isStrongKidsSaved = false,
    this.isSavingIdealWeight = false,
    this.isIdealWeightSaveError = false,
    this.idealWeightSaveErrorMessage,
    this.isIdealWeightSaved = false,
  });

  final EditPatientFormEntity form;
  final bool isEditing;
  final bool isSaving;
  final bool isSaved;
  final bool isSaveError;
  final String? saveErrorMessage;
  final Bmi? bmi;
  final double? newWeight;
  final bool isSavingWeight;
  final List<WeightEntity> weights;

  final double? newHeight;
  final bool isSavingHeight;
  final List<HeightEntity> heights;

  final BodyMeasurementTypeEnum? newBodyMeasurementType;
  final double? newBodyMeasurementValue;
  final bool isSavingNewBodyMeasurement;
  final List<BodyMeasurementEntity> measurements;

  final bool isSavingBmi;
  final bool isBmiSaveError;
  final String? bmiSaveErrorMessage;
  final bool isBmiSaved;

  final bool isSavingEnergyExpenditure;
  final bool isEnergyExpenditureSaveError;
  final String? energyExpenditureSaveErrorMessage;
  final bool isEnergyExpenditureSaved;

  final bool isSavingNitrogenBalance;
  final bool isNitrogenBalanceSaveError;
  final String? nitrogenBalanceSaveErrorMessage;
  final bool isNitrogenBalanceSaved;

  final bool isSavingProteinNeeds;
  final bool isProteinNeedsSaveError;
  final String? proteinNeedsSaveErrorMessage;
  final bool isProteinNeedsSaved;

  final bool isSavingWaterNeeds;
  final bool isWaterNeedsSaveError;
  final String? waterNeedsSaveErrorMessage;
  final bool isWaterNeedsSaved;

  final bool isSavingEnteralNutritionDripping;
  final bool isEnteralNutritionDrippingSaveError;
  final String? enteralNutritionDrippingSaveErrorMessage;
  final bool isEnteralNutritionDrippingSaved;

  final bool isSavingEnteralNutritionSpeed;
  final bool isEnteralNutritionSpeedSaveError;
  final String? enteralNutritionSpeedSaveErrorMessage;
  final bool isEnteralNutritionSpeedSaved;

  final bool isSavingEnteralNutritionVolume;
  final bool isEnteralNutritionVolumeSaveError;
  final String? enteralNutritionVolumeSaveErrorMessage;
  final bool isEnteralNutritionVolumeSaved;

  final bool isSavingGlucoseInfusionRate;
  final bool isGlucoseInfusionRateSaveError;
  final String? glucoseInfusionRateSaveErrorMessage;
  final bool isGlucoseInfusionRateSaved;

  final bool isSavingWeightLossClassification;
  final bool isWeightLossClassificationSaveError;
  final String? weightLossClassificationSaveErrorMessage;
  final bool isWeightLossClassificationSaved;

  final bool isSavingMust;
  final bool isMustSaveError;
  final String? mustSaveErrorMessage;
  final bool isMustSaved;

  final bool isSavingNrs2002;
  final bool isNrs2002SaveError;
  final String? nrs2002SaveErrorMessage;
  final bool isNrs2002Saved;

  final bool isSavingStrongKids;
  final bool isStrongKidsSaveError;
  final String? strongKidsSaveErrorMessage;
  final bool isStrongKidsSaved;

  final bool isSavingIdealWeight;
  final bool isIdealWeightSaveError;
  final String? idealWeightSaveErrorMessage;
  final bool isIdealWeightSaved;

  PatientDetailsStateLoaded copyWith({
    EditPatientFormEntity? form,
    bool? isEditing,
    bool? isSaved,
    bool? isSaving,
    bool? isSaveError,
    Object? saveErrorMessage = _unset,
    Bmi? bmi,
    double? newWeight,
    bool? isSavingWeight,
    List<WeightEntity>? weights,
    double? newHeight,
    bool? isSavingHeight,
    List<HeightEntity>? heights,
    BodyMeasurementTypeEnum? newBodyMeasurementType,
    double? newBodyMeasurementValue,
    bool? isSavingNewBodyMeasurement,
    List<BodyMeasurementEntity>? measurements,
    bool? isSavingBmi,
    bool? isBmiSaveError,
    Object? bmiSaveErrorMessage = _unset,
    bool? isBmiSaved,
    bool? isSavingEnergyExpenditure,
    bool? isEnergyExpenditureSaveError,
    Object? energyExpenditureSaveErrorMessage = _unset,
    bool? isEnergyExpenditureSaved,
    bool? isSavingNitrogenBalance,
    bool? isNitrogenBalanceSaveError,
    Object? nitrogenBalanceSaveErrorMessage = _unset,
    bool? isNitrogenBalanceSaved,
    bool? isSavingProteinNeeds,
    bool? isProteinNeedsSaveError,
    Object? proteinNeedsSaveErrorMessage = _unset,
    bool? isProteinNeedsSaved,
    bool? isSavingWaterNeeds,
    bool? isWaterNeedsSaveError,
    Object? waterNeedsSaveErrorMessage = _unset,
    bool? isWaterNeedsSaved,
    bool? isSavingEnteralNutritionDripping,
    bool? isEnteralNutritionDrippingSaveError,
    Object? enteralNutritionDrippingSaveErrorMessage = _unset,
    bool? isEnteralNutritionDrippingSaved,
    bool? isSavingEnteralNutritionSpeed,
    bool? isEnteralNutritionSpeedSaveError,
    Object? enteralNutritionSpeedSaveErrorMessage = _unset,
    bool? isEnteralNutritionSpeedSaved,
    bool? isSavingEnteralNutritionVolume,
    bool? isEnteralNutritionVolumeSaveError,
    Object? enteralNutritionVolumeSaveErrorMessage = _unset,
    bool? isEnteralNutritionVolumeSaved,
    bool? isSavingGlucoseInfusionRate,
    bool? isGlucoseInfusionRateSaveError,
    Object? glucoseInfusionRateSaveErrorMessage = _unset,
    bool? isGlucoseInfusionRateSaved,
    bool? isSavingWeightLossClassification,
    bool? isWeightLossClassificationSaveError,
    Object? weightLossClassificationSaveErrorMessage = _unset,
    bool? isWeightLossClassificationSaved,
    bool? isSavingMust,
    bool? isMustSaveError,
    Object? mustSaveErrorMessage = _unset,
    bool? isMustSaved,
    bool? isSavingNrs2002,
    bool? isNrs2002SaveError,
    Object? nrs2002SaveErrorMessage = _unset,
    bool? isNrs2002Saved,
    bool? isSavingStrongKids,
    bool? isStrongKidsSaveError,
    Object? strongKidsSaveErrorMessage = _unset,
    bool? isStrongKidsSaved,
    bool? isSavingIdealWeight,
    bool? isIdealWeightSaveError,
    Object? idealWeightSaveErrorMessage = _unset,
    bool? isIdealWeightSaved,
  }) => PatientDetailsStateLoaded(
    form: form ?? this.form,
    isEditing: isEditing ?? this.isEditing,
    isSaved: isSaved ?? this.isSaved,
    isSaving: isSaving ?? this.isSaving,
    isSaveError: isSaveError ?? this.isSaveError,
    saveErrorMessage: identical(saveErrorMessage, _unset)
        ? this.saveErrorMessage
        : saveErrorMessage as String?,
    bmi: bmi ?? this.bmi,
    newWeight: newWeight ?? this.newWeight,
    isSavingWeight: isSavingWeight ?? this.isSavingWeight,
    weights: weights ?? this.weights,
    newHeight: newHeight ?? this.newHeight,
    isSavingHeight: isSavingHeight ?? this.isSavingHeight,
    heights: heights ?? this.heights,
    newBodyMeasurementType: newBodyMeasurementType ?? this.newBodyMeasurementType,
    newBodyMeasurementValue: newBodyMeasurementValue ?? this.newBodyMeasurementValue,
    isSavingNewBodyMeasurement:
        isSavingNewBodyMeasurement ?? this.isSavingNewBodyMeasurement,
    measurements: measurements ?? this.measurements,
    isSavingBmi: isSavingBmi ?? this.isSavingBmi,
    isBmiSaveError: isBmiSaveError ?? this.isBmiSaveError,
    bmiSaveErrorMessage: identical(bmiSaveErrorMessage, _unset)
        ? this.bmiSaveErrorMessage
        : bmiSaveErrorMessage as String?,
    isBmiSaved: isBmiSaved ?? this.isBmiSaved,
    isSavingEnergyExpenditure:
        isSavingEnergyExpenditure ?? this.isSavingEnergyExpenditure,
    isEnergyExpenditureSaveError:
        isEnergyExpenditureSaveError ?? this.isEnergyExpenditureSaveError,
    energyExpenditureSaveErrorMessage:
        identical(energyExpenditureSaveErrorMessage, _unset)
        ? this.energyExpenditureSaveErrorMessage
        : energyExpenditureSaveErrorMessage as String?,
    isEnergyExpenditureSaved:
        isEnergyExpenditureSaved ?? this.isEnergyExpenditureSaved,
    isSavingNitrogenBalance:
        isSavingNitrogenBalance ?? this.isSavingNitrogenBalance,
    isNitrogenBalanceSaveError:
        isNitrogenBalanceSaveError ?? this.isNitrogenBalanceSaveError,
    nitrogenBalanceSaveErrorMessage:
        identical(nitrogenBalanceSaveErrorMessage, _unset)
        ? this.nitrogenBalanceSaveErrorMessage
        : nitrogenBalanceSaveErrorMessage as String?,
    isNitrogenBalanceSaved:
        isNitrogenBalanceSaved ?? this.isNitrogenBalanceSaved,
    isSavingProteinNeeds: isSavingProteinNeeds ?? this.isSavingProteinNeeds,
    isProteinNeedsSaveError:
        isProteinNeedsSaveError ?? this.isProteinNeedsSaveError,
    proteinNeedsSaveErrorMessage: identical(proteinNeedsSaveErrorMessage, _unset)
        ? this.proteinNeedsSaveErrorMessage
        : proteinNeedsSaveErrorMessage as String?,
    isProteinNeedsSaved: isProteinNeedsSaved ?? this.isProteinNeedsSaved,
    isSavingWaterNeeds: isSavingWaterNeeds ?? this.isSavingWaterNeeds,
    isWaterNeedsSaveError: isWaterNeedsSaveError ?? this.isWaterNeedsSaveError,
    waterNeedsSaveErrorMessage: identical(waterNeedsSaveErrorMessage, _unset)
        ? this.waterNeedsSaveErrorMessage
        : waterNeedsSaveErrorMessage as String?,
    isWaterNeedsSaved: isWaterNeedsSaved ?? this.isWaterNeedsSaved,
    isSavingEnteralNutritionDripping:
        isSavingEnteralNutritionDripping ??
        this.isSavingEnteralNutritionDripping,
    isEnteralNutritionDrippingSaveError:
        isEnteralNutritionDrippingSaveError ??
        this.isEnteralNutritionDrippingSaveError,
    enteralNutritionDrippingSaveErrorMessage:
        identical(enteralNutritionDrippingSaveErrorMessage, _unset)
        ? this.enteralNutritionDrippingSaveErrorMessage
        : enteralNutritionDrippingSaveErrorMessage as String?,
    isEnteralNutritionDrippingSaved:
        isEnteralNutritionDrippingSaved ??
        this.isEnteralNutritionDrippingSaved,
    isSavingEnteralNutritionSpeed:
        isSavingEnteralNutritionSpeed ?? this.isSavingEnteralNutritionSpeed,
    isEnteralNutritionSpeedSaveError:
        isEnteralNutritionSpeedSaveError ??
        this.isEnteralNutritionSpeedSaveError,
    enteralNutritionSpeedSaveErrorMessage:
        identical(enteralNutritionSpeedSaveErrorMessage, _unset)
        ? this.enteralNutritionSpeedSaveErrorMessage
        : enteralNutritionSpeedSaveErrorMessage as String?,
    isEnteralNutritionSpeedSaved:
        isEnteralNutritionSpeedSaved ?? this.isEnteralNutritionSpeedSaved,
    isSavingEnteralNutritionVolume:
        isSavingEnteralNutritionVolume ?? this.isSavingEnteralNutritionVolume,
    isEnteralNutritionVolumeSaveError:
        isEnteralNutritionVolumeSaveError ??
        this.isEnteralNutritionVolumeSaveError,
    enteralNutritionVolumeSaveErrorMessage:
        identical(enteralNutritionVolumeSaveErrorMessage, _unset)
        ? this.enteralNutritionVolumeSaveErrorMessage
        : enteralNutritionVolumeSaveErrorMessage as String?,
    isEnteralNutritionVolumeSaved:
        isEnteralNutritionVolumeSaved ?? this.isEnteralNutritionVolumeSaved,
    isSavingGlucoseInfusionRate:
        isSavingGlucoseInfusionRate ?? this.isSavingGlucoseInfusionRate,
    isGlucoseInfusionRateSaveError:
        isGlucoseInfusionRateSaveError ??
        this.isGlucoseInfusionRateSaveError,
    glucoseInfusionRateSaveErrorMessage:
        identical(glucoseInfusionRateSaveErrorMessage, _unset)
        ? this.glucoseInfusionRateSaveErrorMessage
        : glucoseInfusionRateSaveErrorMessage as String?,
    isGlucoseInfusionRateSaved:
        isGlucoseInfusionRateSaved ?? this.isGlucoseInfusionRateSaved,
    isSavingWeightLossClassification:
        isSavingWeightLossClassification ??
        this.isSavingWeightLossClassification,
    isWeightLossClassificationSaveError:
        isWeightLossClassificationSaveError ??
        this.isWeightLossClassificationSaveError,
    weightLossClassificationSaveErrorMessage:
        identical(weightLossClassificationSaveErrorMessage, _unset)
        ? this.weightLossClassificationSaveErrorMessage
        : weightLossClassificationSaveErrorMessage as String?,
    isWeightLossClassificationSaved:
        isWeightLossClassificationSaved ?? this.isWeightLossClassificationSaved,
    isSavingMust: isSavingMust ?? this.isSavingMust,
    isMustSaveError: isMustSaveError ?? this.isMustSaveError,
    mustSaveErrorMessage: identical(mustSaveErrorMessage, _unset)
        ? this.mustSaveErrorMessage
        : mustSaveErrorMessage as String?,
    isMustSaved: isMustSaved ?? this.isMustSaved,
    isSavingNrs2002: isSavingNrs2002 ?? this.isSavingNrs2002,
    isNrs2002SaveError: isNrs2002SaveError ?? this.isNrs2002SaveError,
    nrs2002SaveErrorMessage: identical(nrs2002SaveErrorMessage, _unset)
        ? this.nrs2002SaveErrorMessage
        : nrs2002SaveErrorMessage as String?,
    isNrs2002Saved: isNrs2002Saved ?? this.isNrs2002Saved,
    isSavingStrongKids: isSavingStrongKids ?? this.isSavingStrongKids,
    isStrongKidsSaveError: isStrongKidsSaveError ?? this.isStrongKidsSaveError,
    strongKidsSaveErrorMessage: identical(strongKidsSaveErrorMessage, _unset)
        ? this.strongKidsSaveErrorMessage
        : strongKidsSaveErrorMessage as String?,
    isStrongKidsSaved: isStrongKidsSaved ?? this.isStrongKidsSaved,
    isSavingIdealWeight: isSavingIdealWeight ?? this.isSavingIdealWeight,
    isIdealWeightSaveError:
        isIdealWeightSaveError ?? this.isIdealWeightSaveError,
    idealWeightSaveErrorMessage: identical(idealWeightSaveErrorMessage, _unset)
        ? this.idealWeightSaveErrorMessage
        : idealWeightSaveErrorMessage as String?,
    isIdealWeightSaved: isIdealWeightSaved ?? this.isIdealWeightSaved,
  );

  PatientDetailsStateLoaded clearForm(PatientDetailsFormOptions formOption) {
    return PatientDetailsStateLoaded(
      form: form,
      isEditing: isEditing,
      isSaved: isSaved,
      isSaving: isSaving,
      isSaveError: isSaveError,
      saveErrorMessage: saveErrorMessage,
      bmi: bmi,
      newWeight: formOption == .weights ? null : newWeight,
      isSavingWeight: formOption == .weights ? false : isSavingWeight,
      weights: weights,
      newHeight: formOption == .heights ? null : newHeight,
      isSavingHeight: formOption == .heights ? false : isSavingHeight,
      heights: heights,
      newBodyMeasurementType: formOption == .bodyMeasurements
          ? null
          : newBodyMeasurementType,
      newBodyMeasurementValue: formOption == .bodyMeasurements
          ? null
          : newBodyMeasurementValue,
      isSavingNewBodyMeasurement: formOption == .bodyMeasurements
          ? false
          : isSavingNewBodyMeasurement,
      measurements: measurements,
      isSavingBmi: isSavingBmi,
      isBmiSaveError: isBmiSaveError,
      bmiSaveErrorMessage: bmiSaveErrorMessage,
      isBmiSaved: isBmiSaved,
      isSavingEnergyExpenditure: isSavingEnergyExpenditure,
      isEnergyExpenditureSaveError: isEnergyExpenditureSaveError,
      energyExpenditureSaveErrorMessage: energyExpenditureSaveErrorMessage,
      isEnergyExpenditureSaved: isEnergyExpenditureSaved,
      isSavingNitrogenBalance: isSavingNitrogenBalance,
      isNitrogenBalanceSaveError: isNitrogenBalanceSaveError,
      nitrogenBalanceSaveErrorMessage: nitrogenBalanceSaveErrorMessage,
      isNitrogenBalanceSaved: isNitrogenBalanceSaved,
      isSavingProteinNeeds: isSavingProteinNeeds,
      isProteinNeedsSaveError: isProteinNeedsSaveError,
      proteinNeedsSaveErrorMessage: proteinNeedsSaveErrorMessage,
      isProteinNeedsSaved: isProteinNeedsSaved,
      isSavingWaterNeeds: isSavingWaterNeeds,
      isWaterNeedsSaveError: isWaterNeedsSaveError,
      waterNeedsSaveErrorMessage: waterNeedsSaveErrorMessage,
      isWaterNeedsSaved: isWaterNeedsSaved,
      isSavingEnteralNutritionDripping: isSavingEnteralNutritionDripping,
      isEnteralNutritionDrippingSaveError:
          isEnteralNutritionDrippingSaveError,
      enteralNutritionDrippingSaveErrorMessage:
          enteralNutritionDrippingSaveErrorMessage,
      isEnteralNutritionDrippingSaved: isEnteralNutritionDrippingSaved,
      isSavingEnteralNutritionSpeed: isSavingEnteralNutritionSpeed,
      isEnteralNutritionSpeedSaveError: isEnteralNutritionSpeedSaveError,
      enteralNutritionSpeedSaveErrorMessage:
          enteralNutritionSpeedSaveErrorMessage,
      isEnteralNutritionSpeedSaved: isEnteralNutritionSpeedSaved,
      isSavingEnteralNutritionVolume: isSavingEnteralNutritionVolume,
      isEnteralNutritionVolumeSaveError: isEnteralNutritionVolumeSaveError,
      enteralNutritionVolumeSaveErrorMessage:
          enteralNutritionVolumeSaveErrorMessage,
      isEnteralNutritionVolumeSaved: isEnteralNutritionVolumeSaved,
      isSavingGlucoseInfusionRate: isSavingGlucoseInfusionRate,
      isGlucoseInfusionRateSaveError: isGlucoseInfusionRateSaveError,
      glucoseInfusionRateSaveErrorMessage: glucoseInfusionRateSaveErrorMessage,
      isGlucoseInfusionRateSaved: isGlucoseInfusionRateSaved,
      isSavingWeightLossClassification: isSavingWeightLossClassification,
      isWeightLossClassificationSaveError: isWeightLossClassificationSaveError,
      weightLossClassificationSaveErrorMessage:
          weightLossClassificationSaveErrorMessage,
      isWeightLossClassificationSaved: isWeightLossClassificationSaved,
      isSavingMust: isSavingMust,
      isMustSaveError: isMustSaveError,
      mustSaveErrorMessage: mustSaveErrorMessage,
      isMustSaved: isMustSaved,
      isSavingNrs2002: isSavingNrs2002,
      isNrs2002SaveError: isNrs2002SaveError,
      nrs2002SaveErrorMessage: nrs2002SaveErrorMessage,
      isNrs2002Saved: isNrs2002Saved,
      isSavingStrongKids: isSavingStrongKids,
      isStrongKidsSaveError: isStrongKidsSaveError,
      strongKidsSaveErrorMessage: strongKidsSaveErrorMessage,
      isStrongKidsSaved: isStrongKidsSaved,
      isSavingIdealWeight: isSavingIdealWeight,
      isIdealWeightSaveError: isIdealWeightSaveError,
      idealWeightSaveErrorMessage: idealWeightSaveErrorMessage,
      isIdealWeightSaved: isIdealWeightSaved,
    );
  }

  @override
  List<Object?> get props => [
    form,
    isEditing,
    isSaved,
    isSaveError,
    saveErrorMessage,
    bmi,
    newWeight,
    isSavingWeight,
    weights,
    newHeight,
    isSavingHeight,
    heights,
    newBodyMeasurementType,
    newBodyMeasurementValue,
    isSavingNewBodyMeasurement,
    isSavingBmi,
    isBmiSaveError,
    bmiSaveErrorMessage,
    isBmiSaved,
    isSavingEnergyExpenditure,
    isEnergyExpenditureSaveError,
    energyExpenditureSaveErrorMessage,
    isEnergyExpenditureSaved,
    isSavingNitrogenBalance,
    isNitrogenBalanceSaveError,
    nitrogenBalanceSaveErrorMessage,
    isNitrogenBalanceSaved,
    isSavingProteinNeeds,
    isProteinNeedsSaveError,
    proteinNeedsSaveErrorMessage,
    isProteinNeedsSaved,
    isSavingWaterNeeds,
    isWaterNeedsSaveError,
    waterNeedsSaveErrorMessage,
    isWaterNeedsSaved,
    isSavingEnteralNutritionDripping,
    isEnteralNutritionDrippingSaveError,
    enteralNutritionDrippingSaveErrorMessage,
    isEnteralNutritionDrippingSaved,
    isSavingEnteralNutritionSpeed,
    isEnteralNutritionSpeedSaveError,
    enteralNutritionSpeedSaveErrorMessage,
    isEnteralNutritionSpeedSaved,
    isSavingEnteralNutritionVolume,
    isEnteralNutritionVolumeSaveError,
    enteralNutritionVolumeSaveErrorMessage,
    isEnteralNutritionVolumeSaved,
    isSavingGlucoseInfusionRate,
    isGlucoseInfusionRateSaveError,
    glucoseInfusionRateSaveErrorMessage,
    isGlucoseInfusionRateSaved,
    isSavingWeightLossClassification,
    isWeightLossClassificationSaveError,
    weightLossClassificationSaveErrorMessage,
    isWeightLossClassificationSaved,
    isSavingMust,
    isMustSaveError,
    mustSaveErrorMessage,
    isMustSaved,
    isSavingNrs2002,
    isNrs2002SaveError,
    nrs2002SaveErrorMessage,
    isNrs2002Saved,
    isSavingStrongKids,
    isStrongKidsSaveError,
    strongKidsSaveErrorMessage,
    isStrongKidsSaved,
    isSavingIdealWeight,
    isIdealWeightSaveError,
    idealWeightSaveErrorMessage,
    isIdealWeightSaved,
    measurements,
  ];
}
