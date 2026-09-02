import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_type_enum.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurement_input_field.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/no_data_found_for_patient.dart';
import 'package:nutri_calc/shared/utils/formatters/only_numbers_formatter.dart';

class PatientBodyMeasurementsTab extends StatelessWidget {
  const PatientBodyMeasurementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        if (state is! PatientDetailsStateLoaded) {
          return CircularProgressIndicator();
        }

        final cubit = context.read<PatientDetailsCubit>();

        return Column(
          children: [
            MeasurementInputField(
              label: 'Medida',
              hint: 'XXX',
              isSaving: state.isSavingNewBodyMeasurement,
              saveCallback: cubit.saveNewBodyMeasurement,
              inputFormatters: [OnlyNumbersFormatter()],
              onChange: (val) {
                // final doubleVal = double.tryParse(val);
                // if (doubleVal == null) return;
                cubit.updateBodyMeasurementForm(val);
              },
              dropdownOptions: BodyMeasurementTypeEnum.values
                  .map(
                    (val) =>
                        DropdownMenuEntry(value: val.name, label: val.label),
                  )
                  .toList(),
              onDropdownSelect: (val) =>
                  cubit.updateBodyMeasurementForm(val),
            ),

            if (state.measurements.isEmpty) ...[
              NoDataFoundForPatient(
                message: "Nenhuma medida encontrada para esse paciente.",
              ),
            ],
          ],
        );
      },
    );
  }
}
