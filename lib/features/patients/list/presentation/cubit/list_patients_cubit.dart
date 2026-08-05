import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/features/patients/list/domain/entities/patient_list_card_entity.dart';
import 'package:nutri_calc/features/patients/list/domain/use_cases/get_patients_list_use_case.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

part 'list_patients_state.dart';

@injectable
class ListPatientsCubit extends Cubit<ListPatientsState> {
  ListPatientsCubit({required this._getPatientsListUseCase})
    : super(ListPatientsStateInitial());

  final GetPatientsListUseCase _getPatientsListUseCase;

  Future<void> init() async {
    emit(ListPatientsStateLoading());

    final patients = await _getPatientsListUseCase.call();

    if (patients.isOk) {
      emit(ListPatientsStateInitial(patients: (patients as Ok).value));
    } else {
      emit(ListPatientsStateError());
    }
  }
}
