import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/theme/domain/repositories/theme_preference_repository.dart';

abstract class SetThemeModeUseCase {
  Future<Result<void, String>> call(ThemeMode mode);
}

@Injectable(as: SetThemeModeUseCase)
class SetThemeModeUseCaseImpl implements SetThemeModeUseCase {
  final ThemePreferenceRepository _themePreferenceRepository;

  const SetThemeModeUseCaseImpl({required this._themePreferenceRepository});

  @override
  Future<Result<void, String>> call(ThemeMode mode) {
    return _themePreferenceRepository.setThemeMode(mode);
  }
}
