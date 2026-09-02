// TODO - quick links to calculators

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/patient_details_form.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_body_measurements_tab.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_measurements_tab.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/utils/extensions/ext_num_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_placeholder/ds_placeholder.dart';
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
                tabs: [
                  Text("Calculadoras"),
                  Text("Pesos"),
                  Text("Alturas"),
                  Text("Medidas Corporais"),
                  Text("Histórico"),
                ],
                tabsContents: [
                  DsPlaceholder(),
                  PatientMeasurementsTab(type: .weight),
                  PatientMeasurementsTab(type: .height),
                  PatientBodyMeasurementsTab(),
                  DsPlaceholder(),
                ],
                header: Column(
                  spacing: 10.h,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [PatientDetailsForm()],
                ),
              );
            }
            return DsPlaceholder();
          },
        ),
      ],
    );
  }
}
