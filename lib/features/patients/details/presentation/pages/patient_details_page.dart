// TODO - edit patient
// TODO - view patient data
// TODO - quick links to calculators

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_scaffold/ds_scaffold.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_tab_view/ds_tab_view.dart';

class PatientDetailsPage extends StatelessWidget {
  const PatientDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt.get<PatientDetailsCubit>()
        ..init(
          (getIt.get<AppRouter>().params as Map<String, dynamic>)["patientId"],
        ),
      child: _PatientDetailsPage(),
    );
  }
}

class _PatientDetailsPage extends StatefulWidget {
  const _PatientDetailsPage();

  @override
  State<StatefulWidget> createState() => _PatientDetailsPageContent();
}

class _PatientDetailsPageContent extends State<_PatientDetailsPage> {
  List<RichText> getFields(PatientDetailsStateLoaded loadedState) {
    List<RichText> widgets = [];

    for (final entry in loadedState.mappedBasicInfo.entries) {
      widgets.add(
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "${entry.key}: ",
                style: TextStyle(fontWeight: .w900),
              ),
              TextSpan(text: entry.value ?? "Desconhecido"),
            ],
            style: TextStyle(color: DsColors.black),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      appBar: DsAppBarData(
        onBack: getIt.get<AppRouter>().pop,
        onClose: getIt.get<AppRouter>().pop,
        title: "Informações do Paciente",
      ),
      children: [
        BlocConsumer<PatientDetailsCubit, PatientDetailsState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is PatientDetailsStateInitial) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: .center,
                  children: [CircularProgressIndicator()],
                ),
              );
            }
            if (state is PatientDetailsStateLoaded) {
              return DsTabView(
                tabs: [Text("Tab 1"), Text("Tab 2")],
                tabsContents: [Placeholder(), Placeholder()],
                header: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [...getFields(state)],
                ),
              );
            }
            return Placeholder();
          },
        ),
      ],
    );
  }
}
