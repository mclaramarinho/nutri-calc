// TODO - quick links to calculators

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/patient_details_form.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_body_measurements_tab.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_calculators_tab.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_measurements_tab.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/utils/extensions/ext_num_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_dialog/ds_dialog.dart';
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
          listenWhen: (previous, current) =>
              current is PatientDetailsStateLoaded &&
              ((current.isSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isSaveError)) ||
                  (current.isSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isSaved)) ||
                  (current.isBmiSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isBmiSaveError)) ||
                  (current.isBmiSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isBmiSaved)) ||
                  (current.isEnergyExpenditureSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnergyExpenditureSaveError)) ||
                  (current.isEnergyExpenditureSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnergyExpenditureSaved)) ||
                  (current.isNitrogenBalanceSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isNitrogenBalanceSaveError)) ||
                  (current.isNitrogenBalanceSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isNitrogenBalanceSaved)) ||
                  (current.isProteinNeedsSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isProteinNeedsSaveError)) ||
                  (current.isProteinNeedsSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isProteinNeedsSaved)) ||
                  (current.isWaterNeedsSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isWaterNeedsSaveError)) ||
                  (current.isWaterNeedsSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isWaterNeedsSaved))),
          listener: (context, state) {
            if (state is PatientDetailsStateLoaded && state.isSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.saveErrorMessage ??
                    "Não foi possível salvar as alterações. Tente novamente.",
                showCloseButton: true,
                onClose: context.read<PatientDetailsCubit>().closedErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded && state.isSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Dados do paciente atualizados com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isBmiSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.bmiSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de IMC. Tente novamente.",
                showCloseButton: true,
                onClose:
                    context.read<PatientDetailsCubit>().closedBmiErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isBmiSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de IMC salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnergyExpenditureSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.energyExpenditureSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de gasto energético. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedEnergyExpenditureErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnergyExpenditureSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de gasto energético salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isNitrogenBalanceSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.nitrogenBalanceSaveErrorMessage ??
                    "Não foi possível salvar o balanço nitrogenado. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedNitrogenBalanceErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isNitrogenBalanceSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de balanço nitrogenado salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isProteinNeedsSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.proteinNeedsSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de necessidade proteica. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedProteinNeedsErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isProteinNeedsSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de necessidade proteica salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isWaterNeedsSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.waterNeedsSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de necessidade hídrica. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedWaterNeedsErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isWaterNeedsSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de necessidade hídrica salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            }
          },
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
                  PatientCalculatorsTab(),
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
