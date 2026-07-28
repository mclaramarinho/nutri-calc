part of './new_patient.state.dart';

@injectable
class NewPatientCubit extends Cubit<NewPatientState> {
  NewPatientCubit() : super(NewPatientStateInitial());
}
