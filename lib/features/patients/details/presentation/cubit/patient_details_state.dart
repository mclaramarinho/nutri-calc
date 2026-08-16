import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';

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
  PatientDetailsStateLoaded({required this.form});

  final EditPatientFormEntity form;

  Map<String, dynamic> get mappedBasicInfo => {
    "Nome Completo": "${form.firstName} ${form.lastName}",
    "Idade": form.age != null && form.ageUnit != null
        ? "${form.age} ${form.ageUnit!.value}"
        : null,
    "Data de nascimento": form.birthdate?.formattedDate(),
    "ID": form.patientId,
  };

  @override
  List<Object?> get props => [form];
}
