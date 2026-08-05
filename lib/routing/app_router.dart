import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/routing/app_routes.dart';

abstract class AppRouter {
  GoRouter get router;
  BuildContext? get context;
  AppRoutes? get currentRoute;

  void push(AppRoutes route, {Object? params});
  void pop();
  void replace(AppRoutes route, {Object? params});
}

@Singleton(as: AppRouter)
class AppRouterImpl implements AppRouter {
  AppRouterImpl();

  static final _router = GoRouter(
    routes: AppRoutes.values
        .map(
          (route) => GoRoute(
            path: route.path,
            builder: (context, state) => route.page,
          ),
        )
        .toList(),
  );

  @override
  GoRouter get router => _router;

  @override
  BuildContext? get context =>
      _router.routerDelegate.navigatorKey.currentContext;

  @override
  AppRoutes? get currentRoute =>
      AppRoutes.getByPath(_router.state.matchedLocation);

  // METHODS =================================================================
  @override
  void push(AppRoutes route, {Object? params}) {
    router.push(route.path, extra: params);
  }

  @override
  void pop() {
    router.canPop() ? router.pop() : debugPrint("Can't pop");
  }

  @override
  void replace(AppRoutes route, {Object? params}) {
    router.replace(route.path, extra: params);
  }
}
