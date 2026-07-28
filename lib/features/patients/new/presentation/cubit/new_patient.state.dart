import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/new/domain/entities/new_patient_form.entity.dart';
part 'new_patient.cubit.dart';

abstract class NewPatientState extends Equatable {}

class NewPatientStateInitial extends NewPatientState {
  final NewPatientForm? form;

  NewPatientStateInitial({this.form});

  @override
  List<Object?> get props => [form];
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
