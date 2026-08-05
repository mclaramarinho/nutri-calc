import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab_data.type.dart';
import 'package:nutri_calc/shared/services/router/app_fab_config.dart';
import 'package:nutri_calc/routing/app_router.dart';

class DsScaffold extends StatelessWidget {
  final Widget child;
  final DsAppBarData? appBar;
  final DsFabData? fabData;

  const DsScaffold({required this.child, this.appBar, this.fabData, super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt.get<AppRouter>();
    final currentRoute = router.currentRoute;
    final fab = currentRoute != null
        ? AppFabConfig.getByRoute(currentRoute)
        : null;
    DsScreenAdapter.init(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: appBar != null ? DsAppBar.build(data: appBar!) : null,
          floatingActionButton: fab != null ? DsFab(data: fab.data) : null,
          body: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: Padding(padding: EdgeInsetsGeometry.all(16), child: child),
          ),
        ),
      ),
    );
  }
}
