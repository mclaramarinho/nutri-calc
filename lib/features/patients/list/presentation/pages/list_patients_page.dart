import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/patients/list/presentation/cubit/list_patients_cubit.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_loading_indicator/ds_loading_indicator.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_placeholder/ds_placeholder.dart';

/// Consumed by Home (feature) to render it as a tab
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
    return BlocConsumer<ListPatientsCubit, ListPatientsState>(
      listener: (context, state) {},
      builder: (context, state) {
        switch (state) {
          case ListPatientsStateInitial():
            final patients = state.patients;
            if (patients.isEmpty) {
              return DsPlaceholder(
                message: "Você ainda não tem pacientes cadastrados",
              );
            }
            return ListView.separated(
              itemCount: patients.length,
              separatorBuilder: (context, index) => SizedBox(
                height: 1,
                width: MediaQuery.sizeOf(context).width,
                child: Container(color: DsColors.of(context).gray),
              ),
              itemBuilder: (context, index) {
                final patient = patients[index];
                return DsListTile(
                  overline: patient.patientId,
                  title: "${patient.firstName} ${patient.lastName}",
                  subtitle: patient.age == null || patient.ageUnit == null
                      ? "Idade não informada"
                      : "${patient.age} ${patient.ageUnit!.value.toLowerCase()}",
                  trailing: Icon(
                    Icons.chevron_right_outlined,
                    color: DsColors.of(context).textDisabled,
                  ),
                  onTap: () => getIt.get<AppRouter>().push(
                    AppRoutes.patientDetails,
                    params: {"patientId": patient.localId},
                  ),
                );
              },
            );

          case ListPatientsStateLoading():
            return const DsLoadingIndicator();

          case ListPatientsStateError():
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DsPlaceholder(
                  message: "Não foi possível carregar seus pacientes",
                ),
                SizedBox(height: DsSpacing.md),
                DsButton(
                  label: "Tentar novamente",
                  isLoading: false,
                  onTap: () => context.read<ListPatientsCubit>().init(),
                ),
              ],
            );
        }
      },
    );
  }
}
