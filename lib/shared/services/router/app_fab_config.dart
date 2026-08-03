import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab_data.type.dart';
import 'package:nutri_calc/shared/di/di.dart';
import 'package:nutri_calc/shared/services/router/navigation_service.dart';
import 'package:nutri_calc/shared/services/router/app_routes.dart';

enum AppFabConfig {
  home(route: .home);

  final AppRoutes route;
  const AppFabConfig({required this.route});

  DsFabData get data {
    switch (this) {
      case .home:
        return DsFabData(
          onTap: () =>
              getIt.get<NavigationService>().push(AppRoutes.createPatient),
          icon: Icons.person_add,
        );
    }
  }

  static AppFabConfig? getByRoute(AppRoutes route) {
    switch (route) {
      case .home:
        return .home;
      default:
        return null;
    }
  }
}
