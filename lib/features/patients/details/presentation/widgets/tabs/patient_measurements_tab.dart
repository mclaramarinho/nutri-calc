import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/measurements/domain/entities/measurement_entity.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurement_input_field.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurements_list.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/no_data_found_for_patient.dart';
import 'package:nutri_calc/shared/utils/formatters/only_numbers_formatter.dart';

enum MeasurementType { weight, height }

class PatientMeasurementsTab extends StatelessWidget {
  final MeasurementType type;

  const PatientMeasurementsTab({required this.type, super.key});

  List<MeasurementsListItem> castToListItem(List<MeasurementEntity> listData) {
    List<MeasurementsListItem> itemList = [];
    for (int i = 0; i < listData.length; i++) {
      final current = listData[i];
      final prev = i == listData.length - 1 ? null : listData[i + 1].value;

      final MeasurementsListCurve curve = prev != null
          ? prev > current.value
                ? .desc
                : prev < current.value
                ? .asc
                : .nochange
          : .nochange;

      final unit = type == .weight ? 'kg' : 'cm';

      itemList.add(
        MeasurementsListItem(
          id: current.id!,
          value: '${current.value} $unit',
          createdAt: current.createdAt,
          curve: curve,
        ),
      );
    }
    return itemList;
  }

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
              MeasurementsList(dataList: castToListItem(listData)),
            ],
          ],
        );
      },
    );
  }
}
