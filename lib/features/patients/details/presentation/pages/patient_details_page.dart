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
                          !previous.isWaterNeedsSaved)) ||
                  (current.isEnteralNutritionDrippingSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnteralNutritionDrippingSaveError)) ||
                  (current.isEnteralNutritionDrippingSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnteralNutritionDrippingSaved)) ||
                  (current.isEnteralNutritionSpeedSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnteralNutritionSpeedSaveError)) ||
                  (current.isEnteralNutritionSpeedSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnteralNutritionSpeedSaved)) ||
                  (current.isEnteralNutritionVolumeSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnteralNutritionVolumeSaveError)) ||
                  (current.isEnteralNutritionVolumeSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isEnteralNutritionVolumeSaved)) ||
                  (current.isGlucoseInfusionRateSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isGlucoseInfusionRateSaveError)) ||
                  (current.isGlucoseInfusionRateSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isGlucoseInfusionRateSaved)) ||
                  (current.isWeightLossClassificationSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isWeightLossClassificationSaveError)) ||
                  (current.isWeightLossClassificationSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isWeightLossClassificationSaved)) ||
                  (current.isMustSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isMustSaveError)) ||
                  (current.isMustSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isMustSaved)) ||
                  (current.isNrs2002SaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isNrs2002SaveError)) ||
                  (current.isNrs2002Saved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isNrs2002Saved)) ||
                  (current.isStrongKidsSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isStrongKidsSaveError)) ||
                  (current.isStrongKidsSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isStrongKidsSaved)) ||
                  (current.isIdealWeightSaveError &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isIdealWeightSaveError)) ||
                  (current.isIdealWeightSaved &&
                      (previous is! PatientDetailsStateLoaded ||
                          !previous.isIdealWeightSaved))),
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
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnteralNutritionDrippingSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.enteralNutritionDrippingSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de gotejamento. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedEnteralNutritionDrippingErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnteralNutritionDrippingSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de gotejamento salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnteralNutritionSpeedSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.enteralNutritionSpeedSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de velocidade de infusão. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedEnteralNutritionSpeedErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnteralNutritionSpeedSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de velocidade de infusão salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnteralNutritionVolumeSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.enteralNutritionVolumeSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de volume total. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedEnteralNutritionVolumeErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isEnteralNutritionVolumeSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de volume total salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isGlucoseInfusionRateSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.glucoseInfusionRateSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de TIG. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedGlucoseInfusionRateErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isGlucoseInfusionRateSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de TIG salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isWeightLossClassificationSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.weightLossClassificationSaveErrorMessage ??
                    "Não foi possível salvar a classificação de perda de peso. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedWeightLossClassificationErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isWeightLossClassificationSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message:
                    "Cálculo de Classificação de Perda de Peso salvo com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isMustSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.mustSaveErrorMessage ??
                    "Não foi possível salvar a triagem MUST. Tente novamente.",
                showCloseButton: true,
                onClose: context.read<PatientDetailsCubit>().closedMustErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isMustSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Triagem MUST salva com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isNrs2002SaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.nrs2002SaveErrorMessage ??
                    "Não foi possível salvar a triagem NRS-2002. Tente novamente.",
                showCloseButton: true,
                onClose:
                    context.read<PatientDetailsCubit>().closedNrs2002ErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isNrs2002Saved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Triagem NRS-2002 salva com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isStrongKidsSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.strongKidsSaveErrorMessage ??
                    "Não foi possível salvar a triagem STRONG-Kids. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedStrongKidsErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isStrongKidsSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Triagem STRONG-Kids salva com sucesso.",
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isIdealWeightSaveError) {
              DsDialog.show(
                context,
                title: "Erro ao salvar",
                message:
                    state.idealWeightSaveErrorMessage ??
                    "Não foi possível salvar o cálculo de Peso Ideal. Tente novamente.",
                showCloseButton: true,
                onClose: context
                    .read<PatientDetailsCubit>()
                    .closedIdealWeightErrorModal,
              );
            } else if (state is PatientDetailsStateLoaded &&
                state.isIdealWeightSaved) {
              DsDialog.show(
                context,
                title: "Sucesso",
                message: "Cálculo de Peso Ideal salvo com sucesso.",
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
