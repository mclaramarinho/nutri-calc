import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab.dart';
import 'package:nutri_calc/shared/di/di.dart';
import 'package:nutri_calc/shared/services/router/app_fab_config.enum.dart';
import 'package:nutri_calc/shared/services/router/app_router.service.dart';

class DsScaffold extends StatelessWidget {
  final Widget child;

  const DsScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt.get<AppRouter>();
    final currentRoute = router.currentRoute;
    final fab = currentRoute != null
        ? AppFabConfig.getByRoute(currentRoute)
        : null;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: fab != null ? DsFab(data: fab.data) : null,
        body: child,
      ),
    );
  }
}
