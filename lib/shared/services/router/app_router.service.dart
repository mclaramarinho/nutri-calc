import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_scaffold/ds_scaffold.dart';
import 'package:nutri_calc/shared/services/router/app_routes.enum.dart';

@Singleton()
class AppRouter {
  AppRouter();

  static final _router = GoRouter(
    routes: AppRoutes.values
        .map(
          (route) => GoRoute(
            path: route.path,
            builder: (context, state) => DsScaffold(child: route.page),
          ),
        )
        .toList(),
  );

  GoRouter get router => _router;

  BuildContext? get context =>
      _router.routerDelegate.navigatorKey.currentContext;

  AppRoutes? get currentRoute =>
      AppRoutes.getByPath(_router.state.matchedLocation);

  // METHODS =================================================================
  void push(AppRoutes route, {Object? params}) {
    router.push(route.path, extra: params);
  }

  void pop() {
    router.canPop() ? router.pop() : print("Can't pop");
  }

  void replace(AppRoutes route, {Object? params}) {
    router.replace(route.path, extra: params);
  }
}
