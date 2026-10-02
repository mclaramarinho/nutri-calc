import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_sizing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_typography.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

class PatientDetailsForm extends StatefulWidget {
  const PatientDetailsForm({super.key});

  @override
  State<PatientDetailsForm> createState() => _PatientDetailsFormState();
}

class _PatientDetailsFormState extends State<PatientDetailsForm> {
  late final TextEditingController bmiController;
  late final TextEditingController idController;
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController ageController;
  late final TextEditingController birthdateController;

  @override
  void initState() {
    super.initState();
    bmiController = TextEditingController();
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
    bmiController.dispose();
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

        _syncController(
          bmiController,
          state.bmi != null ? state.bmi!.value.toStringAsFixed(1) : "-",
        );
        final l10n = AppLocalizations.of(context);
        _syncController(
          idController,
          state.form.patientId ?? l10n.patientDetailsFormIdNotInformed,
        );
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
                  label: l10n.patientDetailsFormImcLabel,
                  customController: bmiController,
                  disabled: true,
                  type: .text,
                ),
                DsTextfield(
                  label: l10n.patientDetailsFormIdLabel,
                  customController: idController,
                  disabled: !state.isEditing,
                  onChange: cubit.updateId,
                  type: .name,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DsTextfield(
                        label: l10n.patientDetailsFormFirstNameLabel,
                        customController: firstNameController,
                        disabled: !state.isEditing,
                        onChange: cubit.updateFirstName,
                        type: .name,
                      ),
                    ),
                    Expanded(
                      child: DsTextfield(
                        label: l10n.patientDetailsFormLastNameLabel,
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
                        label: l10n.patientDetailsFormAgeLabel,
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
                  label: l10n.patientDetailsFormBirthdateLabel,
                  type: .datetime,
                  customController: birthdateController,
                  disabled: !state.isEditing,
                  onChange: (val) =>
                      cubit.updateBirthdate(DateTime.tryParse(val)),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: DsSpacing.md,
                    bottom: DsSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.patientDetailsFormClinicalInfoSectionTitle,
                      style: TextStyle(
                        fontSize: DsTypography.medium,
                        fontWeight: FontWeight.w600,
                        color: DsColors.of(context).black,
                      ),
                    ),
                  ),
                ),
                DsCheckbox(
                  label: l10n.patientDetailsFormEnteralNutritionLabel,
                  value: state.form.enteralNutrition,
                  disabled: !state.isEditing,
                  onChanged: cubit.updateEnteralNutrition,
                ),
                SizedBox(height: DsSpacing.sm),
                DsCheckbox(
                  label: l10n.patientDetailsFormParenteralNutritionLabel,
                  value: state.form.parenteralNutrition,
                  disabled: !state.isEditing,
                  onChanged: cubit.updateParenteralNutrition,
                ),
                SizedBox(height: DsSpacing.sm),
                DsCheckbox(
                  label: l10n.patientDetailsFormHospitalizedLabel,
                  value: state.form.hospitalized,
                  disabled: !state.isEditing,
                  onChanged: cubit.updateHospitalized,
                ),
                SizedBox(height: DsSpacing.sm),
                DsCheckbox(
                  label: l10n.patientDetailsFormConfinedToBedLabel,
                  value: state.form.confinedToBed,
                  disabled: !state.isEditing,
                  onChanged: cubit.updateConfinedToBed,
                  helperText: l10n.patientDetailsFormConfinedToBedHelperText,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
