import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_ids.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_save_status.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_source_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/get_patient_calculator_history_use_case.dart';
import 'package:nutri_calc/features/calculators/domain/use_cases/delete_calculator_history_entry_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/delete_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/delete_height_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/delete_body_measurement_use_case.dart';
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
import 'package:nutri_calc/features/calculators/adequation/domain/use_cases/save_adequation_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/adjusted_obesity/domain/use_cases/save_adjusted_obesity_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/adjusted_dry_weight/domain/use_cases/save_adjusted_dry_weight_calculation_use_case.dart';
import 'package:nutri_calc/features/calculators/estimated_weight/domain/use_cases/save_estimated_weight_calculation_use_case.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/ascitis_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/oedema_level.enum.dart';
import 'package:nutri_calc/shared/utils/enums/ethnicity.dart';
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
    this.calculatorStatuses = const {},
    this.historyEntries = const [],
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

  final Map<String, CalculatorSaveStatus> calculatorStatuses;
  final List<HistoryEntryEntity> historyEntries;

  CalculatorSaveStatus calculatorStatus(String id) =>
      calculatorStatuses[id] ?? const CalculatorSaveStatusIdle();

  PatientDetailsStateLoaded copyWithCalculatorStatus(
    String id,
    CalculatorSaveStatus status,
  ) => copyWith(calculatorStatuses: {...calculatorStatuses, id: status});

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
    Map<String, CalculatorSaveStatus>? calculatorStatuses,
    List<HistoryEntryEntity>? historyEntries,
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
    calculatorStatuses: calculatorStatuses ?? this.calculatorStatuses,
    historyEntries: historyEntries ?? this.historyEntries,
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
      calculatorStatuses: calculatorStatuses,
      historyEntries: historyEntries,
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
    calculatorStatuses,
    measurements,
    historyEntries,
  ];
}
