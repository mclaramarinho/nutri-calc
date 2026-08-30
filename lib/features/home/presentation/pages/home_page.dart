import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/home/presentation/cubit/home_state.dart';
import 'package:nutri_calc/features/patients/list/presentation/pages/list_patients_page.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_nav/ds_bottom_nav_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_placeholder/ds_placeholder.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_scaffold/ds_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter router = getIt.get<AppRouter>();

    return BlocProvider(
      create: (_) => getIt.get<HomeCubit>(),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {},
        builder: (context, state) {
          return DsScaffold(
            fabData: DsFabData(
              onTap: () => router.push(.createPatient),
              icon: Icons.person_add,
            ),
            bottomNavData: DsBottomNavData(
              onTapBottomNavbar: context
                  .read<HomeCubit>()
                  .changeBottomNavCurrent,
              bottomNavbarActiveIndex: state is HomeStateInitial
                  ? state.currentBottommNavIndex
                  : 0,
              bottomNavbarItems: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "HOME",
                  tooltip: "HOME",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_sharp),
                  label: "PACIENTES",
                  tooltip: "PACIENTES",
                ),
              ],
            ),
            children: [DsPlaceholder(), ListPatientsPage()],
          );
        },
      ),
    );
  }
}
