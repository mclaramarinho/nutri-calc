import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_sizing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

class PatientDetailsForm extends StatefulWidget {
  const PatientDetailsForm({super.key});

  @override
  State<PatientDetailsForm> createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  late final TextEditingController idController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController ageController;
  late final TextEditingController birthdateController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    ageController = TextEditingController();
    birthdateController = TextEditingController();
  }

  void _syncController(TextEditingController controller, String? value) {
    final newValue = value ?? '';
    if (controller.text != newValue) {
      controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  @override
  void dispose() {
    idController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    birthdateController.dispose();
    super.dispose();
  }

  IconData getButtonIcon(PatientDetailsStateLoaded state) {
    if (state.isEditing) return Icons.save;

    if (state.isSaved) return Icons.check;

    if (state.isSaveError) return Icons.close;

    return Icons.edit;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        final cubit = context.read<PatientDetailsCubit>();

        if (state is! PatientDetailsStateLoaded) {
          throw StateError(
            "This widget should only be called under Loaded state",
          );
        }

        _syncController(idController, state.form.patientId ?? "Não informado");
        _syncController(firstNameController, state.form.firstName);
        _syncController(lastNameController, state.form.lastName);
        _syncController(ageController, state.form.age?.toString());
        _syncController(
          birthdateController,
          state.form.birthdate?.formattedDate(),
        );

        return Column(
          children: [
            Row(
              children: [
                state.isSaving
                    ? SizedBox(
                        width: DsSizing.iconButton,
                        height: DsSizing.iconButton,
                        child: CircularProgressIndicator(strokeWidth: 1),
                      )
                    : IconButton(
                        onPressed: cubit.toggleEditing,
                        icon: Icon(getButtonIcon(state)),
                      ),
              ],
            ),

            Column(
              children: [
                DsTextfield(
                  label: "ID",
                  customController: idController,
                  disabled: !state.isEditing,
                  onChange: cubit.updateId,
                  type: .name,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DsTextfield(
                        label: "Primeiro Nome",
                        customController: firstNameController,
                        disabled: !state.isEditing,
                        onChange: cubit.updateFirstName,
                        type: .name,
                      ),
                    ),
                    Expanded(
                      child: DsTextfield(
                        label: "Ultimo Nome",
                        customController: lastNameController,
                        disabled: !state.isEditing,
                        onChange: cubit.updateLastName,
                        type: .text,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: DsTextfield(
                        label: "Idade",
                        customController: ageController,
                        disabled: !state.isEditing,
                        onChange: cubit.updateAge,
                        type: .number,
                      ),
                    ),
                    Expanded(
                      child: DropdownMenuFormField(
                        dropdownMenuEntries: TimeUnit.values
                            .map(
                              (val) => DropdownMenuEntry(
                                value: val,
                                label: val.value,
                              ),
                            )
                            .toList(),

                        expandedInsets: EdgeInsets.all(DsSpacing.none),
                        onSelected: cubit.updateAgeUnit,
                        enabled: state.isEditing,
                        initialSelection: state.form.ageUnit,
                      ),
                    ),
                  ],
                ),
                DsTextfield(
                  label: "Data de Nascimento",
                  type: .datetime,
                  customController: birthdateController,
                  disabled: !state.isEditing,
                  onChange: (val) =>
                      cubit.updateBirthdate(DateTime.tryParse(val)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
