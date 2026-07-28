import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/patients/new/presentation/cubit/new_patient.state.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/di/di.dart';

class NewPatientPage extends StatelessWidget {
  const NewPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt.get<NewPatientCubit>(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(children: [
              Expanded(child: Text("Criar Paciente")),
            ],),
            DsTextfield(label: "ID do paciente", onChange: print),
            Row(
              children: [
                Expanded(
                  child: DsTextfield(
                    label: "Primeiro Nome*",
                    onChange: print,
                    type: .name,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DsTextfield(
                    label: "Último Nome*",
                    onChange: print,
                    type: .name,
                  ),
                ),
              ],
            ),
            DsTextfield(label: "Idade", onChange: print, type: .number),
            DsTextfield(
              label: "Data de Nascimento",
              onChange: print,
              type: .datetime,
            ),
          ],
        ),
      ),
    );
  }
}
