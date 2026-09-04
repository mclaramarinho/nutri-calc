import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_type_enum.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurement_input_field.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurements_list.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/no_data_found_for_patient.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/utils/formatters/only_numbers_formatter.dart';

class PatientBodyMeasurementsTab extends StatelessWidget {
  const PatientBodyMeasurementsTab({super.key});

  List<MeasurementsListItem> castToListItem(
    List<BodyMeasurementEntity> listData,
  ) {
    List<MeasurementsListItem> items = [];

    for (int i = 0; i < listData.length; i++) {
      final curr = listData[i];
      final prev = i == listData.length - 1 ? null : listData[i + 1].value;

      final MeasurementsListCurve curve = prev != null
          ? prev > curr.value
                ? .desc
                : prev < curr.value
                ? .asc
                : .nochange
          : .nochange;

      items.add(
        MeasurementsListItem(
          id: curr.id ?? "",
          value: '${curr.value} cm',
          createdAt: curr.createdAt,
          curve: curve,
        ),
      );
    }
    return items;
  }

  Map<String, List<BodyMeasurementEntity>> groupByMeasurementType(
    List<BodyMeasurementEntity> listData,
  ) {
    Map<String, List<BodyMeasurementEntity>> items = {};
    for (final item in listData) {
      if (items.containsKey(item.measurementType.name)) {
        items[item.measurementType.name]!.add(item);
      } else {
        items[item.measurementType.name] = [item];
      }
    }
    return items;
  }

  List<Widget> getLists(List<BodyMeasurementEntity> listData) {
    final grouped = groupByMeasurementType(listData);
    List<Widget> widgets = [];
    for (final key in grouped.keys) {
      final data = castToListItem(grouped[key]!);
      widgets.add(
        MeasurementsList(
          dataList: data,
          displayAccordion: true,
          accordionHeader: BodyMeasurementTypeEnum.fromJson(key).label,
        ),
      );
      widgets.add(SizedBox(height: DsSpacing.vLg));
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        if (state is! PatientDetailsStateLoaded) {
          return CircularProgressIndicator();
        }

        final cubit = context.read<PatientDetailsCubit>();

        return SingleChildScrollView(
          child: Column(
            children: [
              MeasurementInputField(
                label: 'Medida',
                hint: 'XXX',
                isSaving: state.isSavingNewBodyMeasurement,
                saveCallback: cubit.saveNewBodyMeasurement,
                inputFormatters: [OnlyNumbersFormatter()],
                onChange: cubit.updateBodyMeasurementForm,
                dropdownOptions: BodyMeasurementTypeEnum.values
                    .map(
                      (val) =>
                          DropdownMenuEntry(value: val.name, label: val.label),
                    )
                    .toList(),
                onDropdownSelect: (val) => cubit.updateBodyMeasurementForm(val),
              ),

              if (state.measurements.isEmpty) ...[
                NoDataFoundForPatient(
                  message: "Nenhuma medida encontrada para esse paciente.",
                ),
              ],

              if (state.measurements.isNotEmpty)
                ...getLists(state.measurements),
            ],
          ),
        );
      },
    );
  }
}
