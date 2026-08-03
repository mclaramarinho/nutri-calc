part of 'list_patients_cubit.dart';

abstract class ListPatientsState extends Equatable {}

class ListPatientsStateInitial extends ListPatientsState {
  final List<PatientListCardEntity> patients;
  final bool isLoading;

  ListPatientsStateInitial({this.patients = const [], this.isLoading = false});

  @override
  List<Object?> get props => [patients, isLoading];
}

class ListPatientsStateLoading extends ListPatientsState {
  ListPatientsStateLoading();

  @override
  List<Object?> get props => [];
}

class ListPatientsStateError extends ListPatientsState {
  ListPatientsStateError();

  @override
  List<Object?> get props => [];
}
