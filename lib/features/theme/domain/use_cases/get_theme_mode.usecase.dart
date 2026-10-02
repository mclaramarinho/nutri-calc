import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/theme/domain/repositories/theme_preference_repository.dart';

abstract class GetThemeModeUseCase {
  Future<Result<ThemeMode, String>> call();
}

@Injectable(as: GetThemeModeUseCase)
class GetThemeModeUseCaseImpl implements GetThemeModeUseCase {
  final ThemePreferenceRepository _themePreferenceRepository;

  const GetThemeModeUseCaseImpl({required this._themePreferenceRepository});

  @override
  Future<Result<ThemeMode, String>> call() {
    return _themePreferenceRepository.getThemeMode();
  }
}
