import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';

class PatientWeightsTab extends StatelessWidget {
  const PatientWeightsTab({super.key});

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
            Row(
              children: [
                Expanded(
                  child: DsTextfield(
                    type: .number,
                    label: "Peso",
                    hintText: "XX.X",
                    onChange: cubit.updateWeightValue,
                  ),
                ),
                DsButton(
                  label: "Salvar",
                  isLoading: state.isSavingWeight,
                  onTap: cubit.saveWeight,
                ),
              ],
            ),

            if (state.weights.isEmpty) ...[
              Text("Não encontramos pesos para esse paciente."),
            ],

            if (state.weights.isNotEmpty) ...[
              Flexible(
                child: ListView.separated(
                  itemCount: state.weights.length,
                  itemBuilder: ((context, index) {
                    final weight = state.weights[index];
                    final prevWeight = index < state.weights.length - 1
                        ? state.weights[index + 1].value
                        : null;

                    final curve = prevWeight != null
                        ? prevWeight > weight.value
                              ? "desc"
                              : prevWeight < weight.value
                              ? "asc"
                              : "nochange"
                        : "nochange";

                    return ListTile(
                      title: Text("${weight.value} kg"),
                      subtitle: Text(weight.createdAt.formattedDateTime()),
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
