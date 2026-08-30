import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/create_height_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/update_patient_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';
import 'package:nutri_calc/shared/utils/entities/age_entity.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';
import 'package:nutri_calc/shared/utils/extensions/ext_age.dart';

part 'patient_details_cubit.dart';

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
    this.isSavingWeight = false,
    this.weights = const [],
    this.newWeight,
    this.isSavingHeight = false,
    this.heights = const [],
    this.newHeight,
  });

  final EditPatientFormEntity form;
  final bool isEditing;
  final bool isSaving;
  final bool isSaved;
  final bool isSaveError;
  final double? newWeight;
  final bool isSavingWeight;
  final List<WeightEntity> weights;

  final double? newHeight;
  final bool isSavingHeight;
  final List<HeightEntity> heights;

  PatientDetailsStateLoaded copyWith({
    EditPatientFormEntity? form,
    bool? isEditing,
    bool? isSaved,
    bool? isSaving,
    bool? isSaveError,
    double? newWeight,
    bool? isSavingWeight,
    List<WeightEntity>? weights,
    double? newHeight,
    bool? isSavingHeight,
    List<HeightEntity>? heights,
  }) => PatientDetailsStateLoaded(
    form: form ?? this.form,
    isEditing: isEditing ?? this.isEditing,
    isSaved: isSaved ?? this.isSaved,
    isSaving: isSaving ?? this.isSaving,
    isSaveError: isSaveError ?? this.isSaveError,
    newWeight: newWeight ?? this.newWeight,
    isSavingWeight: isSavingWeight ?? this.isSavingWeight,
    weights: weights ?? this.weights,
    newHeight: newHeight ?? this.newHeight,
    isSavingHeight: isSavingHeight ?? this.isSavingHeight,
    heights: heights ?? this.heights,
  );

  @override
  List<Object?> get props => [
    form,
    isEditing,
    isSaved,
    isSaveError,
    newWeight,
    isSavingWeight,
    weights,
    newHeight,
    isSavingHeight,
    heights,
  ];
}
