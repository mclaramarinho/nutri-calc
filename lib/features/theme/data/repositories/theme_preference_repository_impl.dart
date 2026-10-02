import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/theme/domain/repositories/theme_preference_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';

@Injectable(as: ThemePreferenceRepository)
class ThemePreferenceRepositoryImpl implements ThemePreferenceRepository {
  const ThemePreferenceRepositoryImpl();

  @override
  Future<Result<ThemeMode, String>> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_themeModeKey);

      if (stored == null) {
        return Ok(ThemeMode.system);
      }

      final mode = ThemeMode.values.firstWhere(
        (value) => value.name == stored,
        orElse: () => ThemeMode.system,
      );

      return Ok(mode);
    } catch (err) {
      return Error(err.toString());
    }
  }

  @override
  Future<Result<void, String>> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
      return Ok(null);
    } catch (err) {
      return Error(err.toString());
    }
  }
}
