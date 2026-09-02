import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurement_input_field.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/no_data_found_for_patient.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/utils/formatters/only_numbers_formatter.dart';

enum MeasurementType { weight, height }

class PatientMeasurementsTab extends StatelessWidget {
  final MeasurementType type;

  const PatientMeasurementsTab({required this.type, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        if (state is! PatientDetailsStateLoaded) {
          return CircularProgressIndicator();
        }

        final cubit = context.read<PatientDetailsCubit>();

        final isWeight = type == .weight;

        final listData = isWeight ? state.weights : state.heights;

        return Column(
          children: [
            MeasurementInputField(
              label: isWeight ? "Peso" : "Altura",
              hint: isWeight ? "XX.X" : "XXX",
              isSaving: isWeight ? state.isSavingWeight : state.isSavingHeight,
              saveCallback: isWeight ? cubit.saveWeight : cubit.saveHeight,
              onChange: isWeight
                  ? cubit.updateWeightValue
                  : cubit.updateHeightValue,
              inputFormatters: isWeight ? null : [OnlyNumbersFormatter()],
            ),

            if (listData.isEmpty) ...[
              NoDataFoundForPatient(
                message:
                    "Não encontramos ${isWeight ? 'pesos' : 'alturas'} para esse paciente.",
              ),
            ],

            if (listData.isNotEmpty) ...[
              Flexible(
                child: ListView.separated(
                  itemCount: listData.length,
                  itemBuilder: ((context, index) {
                    final measurement = listData[index];
                    final prevMeasurement = index < listData.length - 1
                        ? listData[index + 1].value
                        : null;

                    final curve = prevMeasurement != null
                        ? prevMeasurement > measurement.value
                              ? "desc"
                              : prevMeasurement < measurement.value
                              ? "asc"
                              : "nochange"
                        : "nochange";

                    final unit = isWeight ? 'kg' : 'cm';

                    return ListTile(
                      title: Text("${measurement.value} $unit"),
                      subtitle: Text(measurement.createdAt.formattedDateTime()),
                      trailing: curve == "desc"
                          ? Icon(Icons.trending_down_sharp)
                          : curve == "asc"
                          ? Icon(Icons.trending_up_sharp)
                          : null,
                    );
                    // TODO - use when delete weight record is available
                    // return Dismissible(
                    //   key: Key(weight.id!),
                    //   behavior: .opaque,
                    //   child: ListTile(
                    //     title: Text("${weight.value} kg"),
                    //     subtitle: Text(weight.createdAt.formattedDateTime()),
                    //   ),
                    // );
                  }),
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 1,
                      width: MediaQuery.sizeOf(context).width,
                      child: Container(color: DsColors.gray),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
