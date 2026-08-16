import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/new/domain/entities/new_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/new/domain/use_cases/create_patient_use_case.dart';
import 'package:nutri_calc/shared/utils/entities/age_entity.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';
import 'package:nutri_calc/shared/utils/extensions/ext_age.dart';
part 'new_patient_cubit.dart';

abstract class NewPatientState extends Equatable {}

class NewPatientStateInitial extends NewPatientState {
  final NewPatientFormEntity? form;
  final bool isSaving;
  final bool disableAgeInput;

  NewPatientStateInitial({
    this.form,
    this.isSaving = false,
    this.disableAgeInput = false,
  });

  NewPatientStateInitial copyWith({
    NewPatientFormEntity? form,
    bool? isSaving,
    bool? disableAgeInput,
  }) => NewPatientStateInitial(
    form: form ?? this.form,
    isSaving: isSaving ?? this.isSaving,
    disableAgeInput: disableAgeInput ?? this.disableAgeInput,
  );

  @override
  List<Object?> get props => [form, isSaving, disableAgeInput];
}

class NewPatientStateSuccess extends NewPatientState {
  NewPatientStateSuccess();

  @override
  List<Object?> get props => [];
}

class NewPatientStateError extends NewPatientState {
  final String message;

  NewPatientStateError({required this.message});

  @override
  List<Object?> get props => [message];
}
