import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_scaffold/ds_scaffold.dart';
import 'package:nutri_calc/shared/services/router/app_routes.enum.dart';

@Singleton()
class AppRouter {
  final navigator = GlobalKey<NavigatorState>();

  AppRouter();

  final router = GoRouter(
    routes: AppRoutes.values
        .map(
          (route) => GoRoute(
            path: route.path,
            builder: (context, state) => DsScaffold(child: route.page),
          ),
        )
        .toList(),
  );

  // METHODS =================================================================
  AppRoutes? get currentRoute => AppRoutes.getByPath(router.state.path ?? "");

  void push(AppRoutes route, {Object? params}) {
    router.go(route.path, extra: params);
  }

  void pop() {
    router.canPop() ? router.pop() : null;
  }

  void replace(AppRoutes route, {Object? params}) {
    router.replace(route.path, extra: params);
  }
}
