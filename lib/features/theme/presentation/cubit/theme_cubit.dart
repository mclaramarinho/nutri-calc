import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/theme/domain/use_cases/get_theme_mode.usecase.dart';
import 'package:nutri_calc/features/theme/domain/use_cases/set_theme_mode.usecase.dart';

@injectable
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({
    required this._getThemeModeUseCase,
    required this._setThemeModeUseCase,
  }) : super(ThemeMode.system);

  final GetThemeModeUseCase _getThemeModeUseCase;
  final SetThemeModeUseCase _setThemeModeUseCase;

  Future<void> hydrate() async {
    final res = await _getThemeModeUseCase();
    if (res.isOk) {
      emit((res as Ok).value);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _setThemeModeUseCase(mode);
  }
}
