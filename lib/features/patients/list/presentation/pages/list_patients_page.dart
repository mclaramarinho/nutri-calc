import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/patients/list/presentation/cubit/list_patients_cubit.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_scaffold/ds_scaffold.dart';
import 'package:nutri_calc/di/di.dart';

class ListPatientsPage extends StatelessWidget {
  const ListPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt.get<ListPatientsCubit>()..init(),
      child: _ListPatientsPageContent(),
    );
  }
}

class _ListPatientsPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      child: BlocConsumer<ListPatientsCubit, ListPatientsState>(
        listener: (context, state) {},
        builder: (context, state) {
          switch (state) {
            case ListPatientsStateInitial():
              final patients = state.patients;
              if (patients.isEmpty) {
                return Text("No patients to display");
              }
              return ListView.builder(
                itemCount: state.patients.length,
                itemBuilder: (context, index) {
                  final patient = state.patients[index];
                  return ListTile(
                    trailing: Icon(Icons.chevron_right_outlined),
                    title: Column(
                      crossAxisAlignment: .start,
                      children: [
                        if (patient.patientId != null) ...[
                          Text(patient.patientId!),
                        ],
                        Text("${patient.firstName} ${patient.lastName}"),
                      ],
                    ),
                    subtitle: Text(
                      patient.age == null || patient.ageUnit == null
                          ? "Idade não informada"
                          : "${patient.age} ${patient.ageUnit?.value.toLowerCase()}",
                    ),
                  );
                },
              );

            case ListPatientsStateLoading():
              return CircularProgressIndicator();
            case ListPatientsStateError():
              return Text("Error loading patients");
            default:
              return Text("Error loading patients");
          }
        },
      ),
    );
  }
}
