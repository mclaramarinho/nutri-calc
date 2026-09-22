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
import 'package:nutri_calc/features/calculators/nitrogen_balance/domain/use_cases/save_nitrogen_balance_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/protein_needs/domain/use_cases/save_protein_needs_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/water_needs/domain/use_cases/save_water_needs_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/activity_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/injury_factor.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/stress_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/energy_expenditure/temperature_factor.enum.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';

part 'patient_details_cubit.dart';

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

  PatientDetailsStateLoaded copyWith({
    EditPatientFormEntity? form,
    bool? isEditing,
    bool? isSaved,
    bool? isSaving,
    bool? isSaveError,
    String? saveErrorMessage,
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
    String? bmiSaveErrorMessage,
    bool? isBmiSaved,
    bool? isSavingEnergyExpenditure,
    bool? isEnergyExpenditureSaveError,
    String? energyExpenditureSaveErrorMessage,
    bool? isEnergyExpenditureSaved,
    bool? isSavingNitrogenBalance,
    bool? isNitrogenBalanceSaveError,
    String? nitrogenBalanceSaveErrorMessage,
    bool? isNitrogenBalanceSaved,
    bool? isSavingProteinNeeds,
    bool? isProteinNeedsSaveError,
    String? proteinNeedsSaveErrorMessage,
    bool? isProteinNeedsSaved,
    bool? isSavingWaterNeeds,
    bool? isWaterNeedsSaveError,
    String? waterNeedsSaveErrorMessage,
    bool? isWaterNeedsSaved,
  }) => PatientDetailsStateLoaded(
    form: form ?? this.form,
    isEditing: isEditing ?? this.isEditing,
    isSaved: isSaved ?? this.isSaved,
    isSaving: isSaving ?? this.isSaving,
    isSaveError: isSaveError ?? this.isSaveError,
    saveErrorMessage: saveErrorMessage ?? this.saveErrorMessage,
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
    bmiSaveErrorMessage: bmiSaveErrorMessage ?? this.bmiSaveErrorMessage,
    isBmiSaved: isBmiSaved ?? this.isBmiSaved,
    isSavingEnergyExpenditure:
        isSavingEnergyExpenditure ?? this.isSavingEnergyExpenditure,
    isEnergyExpenditureSaveError:
        isEnergyExpenditureSaveError ?? this.isEnergyExpenditureSaveError,
    energyExpenditureSaveErrorMessage:
        energyExpenditureSaveErrorMessage ??
        this.energyExpenditureSaveErrorMessage,
    isEnergyExpenditureSaved:
        isEnergyExpenditureSaved ?? this.isEnergyExpenditureSaved,
    isSavingNitrogenBalance:
        isSavingNitrogenBalance ?? this.isSavingNitrogenBalance,
    isNitrogenBalanceSaveError:
        isNitrogenBalanceSaveError ?? this.isNitrogenBalanceSaveError,
    nitrogenBalanceSaveErrorMessage:
        nitrogenBalanceSaveErrorMessage ??
        this.nitrogenBalanceSaveErrorMessage,
    isNitrogenBalanceSaved:
        isNitrogenBalanceSaved ?? this.isNitrogenBalanceSaved,
    isSavingProteinNeeds: isSavingProteinNeeds ?? this.isSavingProteinNeeds,
    isProteinNeedsSaveError:
        isProteinNeedsSaveError ?? this.isProteinNeedsSaveError,
    proteinNeedsSaveErrorMessage:
        proteinNeedsSaveErrorMessage ?? this.proteinNeedsSaveErrorMessage,
    isProteinNeedsSaved: isProteinNeedsSaved ?? this.isProteinNeedsSaved,
    isSavingWaterNeeds: isSavingWaterNeeds ?? this.isSavingWaterNeeds,
    isWaterNeedsSaveError: isWaterNeedsSaveError ?? this.isWaterNeedsSaveError,
    waterNeedsSaveErrorMessage:
        waterNeedsSaveErrorMessage ?? this.waterNeedsSaveErrorMessage,
    isWaterNeedsSaved: isWaterNeedsSaved ?? this.isWaterNeedsSaved,
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
    measurements,
  ];
}
