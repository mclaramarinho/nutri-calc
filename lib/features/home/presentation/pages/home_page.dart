import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/home/presentation/cubit/home_state.dart';
import 'package:nutri_calc/features/patients/list/presentation/pages/list_patients_page.dart';
import 'package:nutri_calc/features/theme/presentation/widgets/theme_select_sheet_content.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_nav/ds_bottom_nav_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart';
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
          final l10n = AppLocalizations.of(context);
          return DsScaffold(
            appBar: DsAppBarData(onThemeToggle: () => _openThemeSheet(context)),
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
                  label: l10n.homeBottomNavHomeLabel,
                  tooltip: l10n.homeBottomNavHomeLabel,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_sharp),
                  label: l10n.homeBottomNavPatientsLabel,
                  tooltip: l10n.homeBottomNavPatientsLabel,
                ),
              ],
            ),
            children: [DsPlaceholder(), ListPatientsPage()],
          );
        },
      ),
    );
  }

  void _openThemeSheet(BuildContext context) {
    DsBottomSheet.show<void>(
      context,
      title: AppLocalizations.of(context).homeThemeSheetTitle,
      body: const ThemeSelectSheetContent(),
    );
  }
}
