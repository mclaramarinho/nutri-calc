import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/patients/new/presentation/cubit/new_patient.state.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_dialog/ds_dialog.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/di/di.dart';
import 'package:nutri_calc/shared/services/router/app_router.service.dart';
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
  @override
  Widget build(BuildContext context) {
    final NewPatientCubit cubit = context.read<NewPatientCubit>();
    return BlocConsumer<NewPatientCubit, NewPatientState>(
      listener: (context, state) {
        switch (state) {
          case NewPatientStateSuccess():
            cubit.stopLoading();
            DsDialog.show(
              context,
              title: "Salvo com sucesso",
              message: "Esse paciente ficará visível na home.",
              showCloseButton: false,
              onClose: () => getIt.get<AppRouter>().replace(.home),
              duration: Duration(seconds: 2),
              isDismissible: false,
            );
            break;
          case NewPatientStateError():
            cubit.stopLoading();
            DsDialog.show(
              context,
              title: "Erro ao salvar",
              message: state.message,
              onClose: cubit.closedErrorModal,
              showCloseButton: true,
            );
            break;
        }
      },
      buildWhen: (previous, current) => current is NewPatientStateInitial,
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              DsTextfield(
                label: "ID do paciente",
                onChange: (val) => cubit.setValue(.patientId, val),
                validator: (value) => InputValidators.patientId(value),
              ),
              Row(
                children: [
                  Expanded(
                    child: DsTextfield(
                      label: "Primeiro Nome*",
                      onChange: (val) => cubit.setValue(.firstName, val),
                      type: .name,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DsTextfield(
                      label: "Último Nome*",
                      onChange: (val) => cubit.setValue(.lastName, val),
                      type: .name,
                    ),
                  ),
                ],
              ),
              DsTextfield(
                label: "Idade",
                onChange: (val) => cubit.setValue(.age, int.tryParse(val)),
                type: .number,
              ),
              DsTextfield(
                label: "Data de Nascimento",
                onChange: (val) =>
                    cubit.setValue(.birthdate, DateTime.tryParse(val)),
                type: .datetime,
              ),

              Row(
                children: [
                  DsButton(
                    label: "Salvar",
                    isLoading: (state as NewPatientStateInitial).isSaving,
                    onTap: cubit.onSubmit,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
