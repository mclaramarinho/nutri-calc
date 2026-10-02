import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/patients/new/presentation/cubit/new_patient_state.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_typography.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_dialog/ds_dialog.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_scaffold/ds_scaffold.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';
import 'package:nutri_calc/shared/utils/validators/input_validators.dart';

class NewPatientPage extends StatelessWidget {
  const NewPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt.get<NewPatientCubit>(),
      child: _NewPatientPageContent(),
    );
  }
}

class _NewPatientPageContent extends StatelessWidget {
  final AppRouter _router = getIt.get<AppRouter>();
  @override
  Widget build(BuildContext context) {
    final NewPatientCubit cubit = context.read<NewPatientCubit>();
    return BlocConsumer<NewPatientCubit, NewPatientState>(
      listener: (context, state) {
        final l10n = AppLocalizations.of(context);
        switch (state) {
          case NewPatientStateSuccess():
            cubit.stopLoading();
            DsDialog.show(
              context,
              title: l10n.newPatientSavedSuccessTitle,
              message: l10n.newPatientSavedSuccessMessage,
              showCloseButton: false,
              onClose: () => _router.replace(.home),
              duration: Duration(seconds: 2),
              isDismissible: false,
            );
            break;
          case NewPatientStateError():
            cubit.stopLoading();
            DsDialog.show(
              context,
              title: l10n.newPatientSaveErrorTitle,
              message: state.message,
              onClose: cubit.closedErrorModal,
              showCloseButton: true,
            );
            break;
        }
      },
      buildWhen: (previous, current) => current is NewPatientStateInitial,
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return DsScaffold(
          appBar: DsAppBarData(
            title: l10n.newPatientTitle,
            onBack: _router.pop,
            onClose: _router.pop,
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(DsSpacing.md),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DsTextfield(
                      label: l10n.newPatientPatientIdLabel,
                      onChange: (val) => cubit.setValue(.patientId, val),
                      validator: (value) => InputValidators.patientId(value),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DsTextfield(
                            label: l10n.newPatientFirstNameLabel,
                            onChange: (val) => cubit.setValue(.firstName, val),
                            type: .name,
                          ),
                        ),
                        SizedBox(width: DsSpacing.md),
                        Expanded(
                          child: DsTextfield(
                            label: l10n.newPatientLastNameLabel,
                            onChange: (val) => cubit.setValue(.lastName, val),
                            type: .name,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DsTextfield(
                            label: l10n.newPatientAgeLabel,
                            customController: cubit.ageInputController,
                            onChange: (val) =>
                                cubit.setValue(.age, int.tryParse(val)),
                            type: .number,
                            disabled: (state as NewPatientStateInitial)
                                .disableAgeInput,
                          ),
                        ),

                        Expanded(
                          child: DropdownMenuFormField(
                            dropdownMenuEntries: TimeUnit.values
                                .map(
                                  (val) => DropdownMenuEntry(
                                    value: val,
                                    label: val.name,
                                  ),
                                )
                                .toList(),

                            expandedInsets: EdgeInsets.all(DsSpacing.none),
                            onSelected: (val) => cubit.setValue(.ageUnit, val),
                            enabled: !state.disableAgeInput,
                            initialSelection: state.disableAgeInput
                                ? state.form!.ageUnit
                                : "",
                          ),
                        ),
                      ],
                    ),
                    DsTextfield(
                      label: l10n.newPatientBirthdateLabel,
                      onChange: (val) =>
                          cubit.setValue(.birthdate, DateTime.tryParse(val)),
                      type: .datetime,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: DsSpacing.md,
                        bottom: DsSpacing.sm,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.newPatientClinicalInfoSectionTitle,
                          style: TextStyle(
                            fontSize: DsTypography.medium,
                            fontWeight: FontWeight.w600,
                            color: DsColors.of(context).black,
                          ),
                        ),
                      ),
                    ),
                    DsCheckbox(
                      label: l10n.newPatientEnteralNutritionLabel,
                      value: state.form?.enteralNutrition ?? false,
                      onChanged: (val) =>
                          cubit.setValue(.enteralNutrition, val),
                    ),
                    SizedBox(height: DsSpacing.sm),
                    DsCheckbox(
                      label: l10n.newPatientParenteralNutritionLabel,
                      value: state.form?.parenteralNutrition ?? false,
                      onChanged: (val) =>
                          cubit.setValue(.parenteralNutrition, val),
                    ),
                    SizedBox(height: DsSpacing.sm),
                    DsCheckbox(
                      label: l10n.newPatientHospitalizedLabel,
                      value: state.form?.hospitalized ?? false,
                      onChanged: (val) => cubit.setValue(.hospitalized, val),
                    ),
                    SizedBox(height: DsSpacing.sm),
                    DsCheckbox(
                      label: l10n.newPatientConfinedToBedLabel,
                      value: state.form?.confinedToBed ?? false,
                      onChanged: (val) => cubit.setValue(.confinedToBed, val),
                      helperText: l10n.newPatientConfinedToBedHelperText,
                    ),

                    Row(
                      children: [
                        DsButton(
                          label: l10n.newPatientSaveButton,
                          isLoading: state.isSaving,
                          onTap: cubit.onSubmit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
