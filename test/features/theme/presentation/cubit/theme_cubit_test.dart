import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/theme/domain/use_cases/get_theme_mode.usecase.dart';
import 'package:nutri_calc/features/theme/domain/use_cases/set_theme_mode.usecase.dart';
import 'package:nutri_calc/features/theme/presentation/cubit/theme_cubit.dart';

/// Minimal fakes - no mocking package is set up in this project (see
/// `list_patients_cubit_test.dart`).
class _FakeGetThemeModeUseCase implements GetThemeModeUseCase {
  _FakeGetThemeModeUseCase(this._result);

  final Result<ThemeMode, String> _result;
  int callCount = 0;

  @override
  Future<Result<ThemeMode, String>> call() async {
    callCount++;
    return _result;
  }
}

class _FakeSetThemeModeUseCase implements SetThemeModeUseCase {
  final List<ThemeMode> calls = [];

  @override
  Future<Result<void, String>> call(ThemeMode mode) async {
    calls.add(mode);
    return Ok(null);
  }
}

void main() {
  group('ThemeCubit', () {
    test('initial state is ThemeMode.system before hydration', () {
      final cubit = ThemeCubit(
        getThemeModeUseCase: _FakeGetThemeModeUseCase(Ok(ThemeMode.dark)),
        setThemeModeUseCase: _FakeSetThemeModeUseCase(),
      );

      expect(cubit.state, ThemeMode.system);
    });

    test('hydrate() emits the persisted mode when the use case succeeds', () async {
      final fakeGetUseCase = _FakeGetThemeModeUseCase(Ok(ThemeMode.dark));
      final cubit = ThemeCubit(
        getThemeModeUseCase: fakeGetUseCase,
        setThemeModeUseCase: _FakeSetThemeModeUseCase(),
      );

      await cubit.hydrate();

      expect(cubit.state, ThemeMode.dark);
      expect(fakeGetUseCase.callCount, 1);
    });

    test(
      'hydrate() falls back to ThemeMode.system (keeps initial state) when '
      'the use case returns an Error',
      () async {
        final cubit = ThemeCubit(
          getThemeModeUseCase: _FakeGetThemeModeUseCase(Error('boom')),
          setThemeModeUseCase: _FakeSetThemeModeUseCase(),
        );

        await cubit.hydrate();

        expect(cubit.state, ThemeMode.system);
      },
    );

    test(
      'setThemeMode() emits the new mode immediately (optimistically, before '
      'persistence resolves) and forwards it to the use case',
      () async {
        final fakeSetUseCase = _FakeSetThemeModeUseCase();
        final cubit = ThemeCubit(
          getThemeModeUseCase: _FakeGetThemeModeUseCase(Ok(ThemeMode.system)),
          setThemeModeUseCase: fakeSetUseCase,
        );

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([ThemeMode.dark]),
        );

        await cubit.setThemeMode(ThemeMode.dark);
        await expectation;

        expect(cubit.state, ThemeMode.dark);
        expect(fakeSetUseCase.calls, [ThemeMode.dark]);
      },
    );
  });
}
