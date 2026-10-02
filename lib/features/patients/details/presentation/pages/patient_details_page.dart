// TODO - quick links to calculators

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_save_status.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/patient_details_form.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_body_measurements_tab.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_calculators_tab.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_history_tab.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_measurements_tab.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return DsScaffold(
      appBar: DsAppBarData(
        onBack: getIt.get<AppRouter>().pop,
        onClose: getIt.get<AppRouter>().pop,
        title: l10n.patientDetailsPageTitle,
      ),
      children: [
        BlocConsumer<PatientDetailsCubit, PatientDetailsState>(
          listenWhen: (previous, current) {
            if (current is! PatientDetailsStateLoaded) return false;
            final previousStatuses = previous is PatientDetailsStateLoaded
                ? previous.calculatorStatuses
                : const <String, CalculatorSaveStatus>{};
            return (current.isSaveError &&
                    (previous is! PatientDetailsStateLoaded ||
                        !previous.isSaveError)) ||
                (current.isSaved &&
                    (previous is! PatientDetailsStateLoaded ||
                        !previous.isSaved)) ||
                current.calculatorStatuses.entries.any((entry) {
                  final previousStatus =
                      previousStatuses[entry.key] ??
                      const CalculatorSaveStatusIdle();
                  return (entry.value.isError && !previousStatus.isError) ||
                      (entry.value.isSaved && !previousStatus.isSaved);
                });
          },
          listener: (context, state) {
            if (state is! PatientDetailsStateLoaded) return;

            final l10n = AppLocalizations.of(context);

            if (state.isSaveError) {
              DsDialog.show(
                context,
                title: l10n.patientDetailsSaveErrorTitle,
                message:
                    state.saveErrorMessage ??
                    l10n.patientDetailsSaveErrorFallbackMessage,
                showCloseButton: true,
                onClose: context.read<PatientDetailsCubit>().closedErrorModal,
              );
              return;
            }

            if (state.isSaved) {
              DsDialog.show(
                context,
                title: l10n.patientDetailsSaveSuccessTitle,
                message: l10n.patientDetailsSaveSuccessMessage,
                showCloseButton: false,
                isDismissible: false,
                duration: Duration(seconds: 2),
              );
              return;
            }

            for (final entry in state.calculatorStatuses.entries) {
              final status = entry.value;

              if (status.isError) {
                DsDialog.show(
                  context,
                  title: l10n.patientDetailsSaveErrorTitle,
                  message: status.errorMessage!,
                  showCloseButton: true,
                  onClose: () => context
                      .read<PatientDetailsCubit>()
                      .closedCalculatorErrorModal(entry.key),
                );
                return;
              }

              if (status.isSaved) {
                DsDialog.show(
                  context,
                  title: l10n.patientDetailsSaveSuccessTitle,
                  message: status.savedMessage!,
                  showCloseButton: false,
                  isDismissible: false,
                  duration: Duration(seconds: 2),
                );
                return;
              }
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
                  Text(l10n.patientDetailsTabCalculators),
                  Text(l10n.patientDetailsTabWeights),
                  Text(l10n.patientDetailsTabHeights),
                  Text(l10n.patientDetailsTabBodyMeasurements),
                  Text(l10n.patientDetailsTabHistory),
                ],
                tabsContents: [
                  PatientCalculatorsTab(),
                  PatientMeasurementsTab(type: .weight),
                  PatientMeasurementsTab(type: .height),
                  PatientBodyMeasurementsTab(),
                  PatientHistoryTab(),
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
