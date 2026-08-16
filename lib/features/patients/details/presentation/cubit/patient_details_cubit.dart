part of 'patient_details_state.dart';

@injectable
class PatientDetailsCubit extends Cubit<PatientDetailsState> {
  PatientDetailsCubit({required this._loadPatientDetailsUseCase})
    : super(PatientDetailsStateInitial());

  final LoadPatientDetailsUseCase _loadPatientDetailsUseCase;
  // TODO - get patient details
  Future<void> init(String patientId) async {
    final result = await _loadPatientDetailsUseCase(patientId);
    if (result is Error) {
      emit(
        PatientDetailsStateError(
          message: "Erro ao carregar dados do paciente.",
        ),
      );
      return;
    }

    emit(PatientDetailsStateLoaded(form: (result as Ok).value));
  }

  // TODO - edit patient info

  // TODO - register measurements
  // weight, height, circumferences
}
