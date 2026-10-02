import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/theme/data/repositories/theme_preference_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemePreferenceRepositoryImpl', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'getThemeMode() returns Ok(ThemeMode.system) when no preference has '
      'ever been persisted',
      () async {
        const repository = ThemePreferenceRepositoryImpl();

        final result = await repository.getThemeMode();

        expect(result, isA<Ok<ThemeMode, String>>());
        expect((result as Ok).value, ThemeMode.system);
      },
    );

    test(
      'setThemeMode() then getThemeMode() round-trips the persisted value',
      () async {
        const repository = ThemePreferenceRepositoryImpl();

        final setResult = await repository.setThemeMode(ThemeMode.dark);
        expect(setResult.isOk, isTrue);

        final getResult = await repository.getThemeMode();

        expect(getResult, isA<Ok<ThemeMode, String>>());
        expect((getResult as Ok).value, ThemeMode.dark);
      },
    );

    test(
      'getThemeMode() falls back to Ok(ThemeMode.system) when the stored '
      'value does not match any known ThemeMode',
      () async {
        SharedPreferences.setMockInitialValues({'theme_mode': 'not_a_mode'});
        const repository = ThemePreferenceRepositoryImpl();

        final result = await repository.getThemeMode();

        expect(result, isA<Ok<ThemeMode, String>>());
        expect((result as Ok).value, ThemeMode.system);
      },
    );
  });
}
