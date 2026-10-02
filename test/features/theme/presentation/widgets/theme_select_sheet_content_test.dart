import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/theme/domain/use_cases/get_theme_mode.usecase.dart';
import 'package:nutri_calc/features/theme/domain/use_cases/set_theme_mode.usecase.dart';
import 'package:nutri_calc/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:nutri_calc/features/theme/presentation/widgets/theme_select_sheet_content.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';

/// Minimal fakes - no mocking package is set up in this project (see
/// `list_patients_cubit_test.dart`/`ds_bottom_sheet_test.dart`).
class _FakeGetThemeModeUseCase implements GetThemeModeUseCase {
  @override
  Future<Result<ThemeMode, String>> call() async => Ok(ThemeMode.system);
}

class _FakeSetThemeModeUseCase implements SetThemeModeUseCase {
  @override
  Future<Result<void, String>> call(ThemeMode mode) async => Ok(null);
}

/// A fake [AppRouter] that only tracks whether `pop()` was called, mirroring
/// `_FakeAppRouter` in `ds_bottom_sheet_test.dart`.
class _FakeAppRouter implements AppRouter {
  int popCallCount = 0;

  @override
  void pop<T extends Object?>([T? result]) {
    popCallCount++;
  }

  @override
  GoRouter get router => throw UnimplementedError();

  @override
  BuildContext? get context => throw UnimplementedError();

  @override
  AppRoutes? get currentRoute => throw UnimplementedError();

  @override
  Object? get params => throw UnimplementedError();

  @override
  void push(AppRoutes route, {Map<String, dynamic>? params}) =>
      throw UnimplementedError();

  @override
  void replace(AppRoutes route, {Map<String, dynamic>? params}) =>
      throw UnimplementedError();
}

Future<void> _pumpContent(
  WidgetTester tester,
  ThemeCubit cubit,
) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [DsColors.light]),
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return BlocProvider<ThemeCubit>.value(
            value: cubit,
            child: const Scaffold(body: ThemeSelectSheetContent()),
          );
        },
      ),
    ),
  );
}

void main() {
  group('ThemeSelectSheetContent', () {
    late _FakeAppRouter fakeAppRouter;

    setUp(() {
      fakeAppRouter = _FakeAppRouter();
      getIt.registerSingleton<AppRouter>(fakeAppRouter);
    });

    tearDown(() {
      getIt.unregister<AppRouter>();
    });

    testWidgets('renders a checkmark only next to the currently active mode', (
      tester,
    ) async {
      final cubit = ThemeCubit(
        getThemeModeUseCase: _FakeGetThemeModeUseCase(),
        setThemeModeUseCase: _FakeSetThemeModeUseCase(),
      );
      await cubit.setThemeMode(ThemeMode.dark);

      await _pumpContent(tester, cubit);

      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Escuro'), findsOneWidget);
      expect(find.text('Automático'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      final escuroTile = find.ancestor(
        of: find.text('Escuro'),
        matching: find.byType(InkWell),
      );
      expect(
        find.descendant(of: escuroTile, matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets(
      'tapping a different mode applies it via ThemeCubit and dismisses '
      'the sheet via AppRouter.pop',
      (tester) async {
        final cubit = ThemeCubit(
          getThemeModeUseCase: _FakeGetThemeModeUseCase(),
          setThemeModeUseCase: _FakeSetThemeModeUseCase(),
        );
        await cubit.setThemeMode(ThemeMode.light);

        await _pumpContent(tester, cubit);

        await tester.tap(find.text('Escuro'));
        await tester.pumpAndSettle();

        expect(cubit.state, ThemeMode.dark);
        expect(fakeAppRouter.popCallCount, 1);

        await cubit.close();
      },
    );
  });
}
