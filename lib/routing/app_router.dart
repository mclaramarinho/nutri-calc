import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/routing/app_routes.dart';

abstract class AppRouter {
  GoRouter get router;
  BuildContext? get context;
  AppRoutes? get currentRoute;
  Object? get params;

  void push(AppRoutes route, {Map<String, dynamic>? params});
  void pop();
  void replace(AppRoutes route, {Map<String, dynamic>? params});
}

@Singleton(as: AppRouter)
class AppRouterImpl implements AppRouter {
  AppRouterImpl();

  static final _router = GoRouter(
    routes: AppRoutes.values
        .map(
          (route) => GoRoute(
            path: route.path,
            builder: (context, state) {
              return route.page;
            },
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
  Object? get params => _router.state.extra;

  @override
  AppRoutes? get currentRoute =>
      AppRoutes.getByPath(_router.state.matchedLocation);

  // METHODS =================================================================
  @override
  void push(AppRoutes route, {Map<String, dynamic>? params}) {
    router.push(route.path, extra: params);
  }

  @override
  void pop() {
    router.canPop() ? router.pop() : debugPrint("Can't pop");
  }

  @override
  void replace(AppRoutes route, {Map<String, dynamic>? params}) {
    router.replace(route.path, extra: params);
  }
}
