import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';

abstract class ThemePreferenceRepository {
  Future<Result<ThemeMode, String>> getThemeMode();
  Future<Result<void, String>> setThemeMode(ThemeMode mode);
}
