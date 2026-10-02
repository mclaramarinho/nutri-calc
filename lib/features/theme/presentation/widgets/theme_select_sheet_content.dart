import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';

class ThemeSelectSheetContent extends StatelessWidget {
  const ThemeSelectSheetContent({super.key});

  static const _options = [
    (mode: ThemeMode.light, label: "Claro"),
    (mode: ThemeMode.dark, label: "Escuro"),
    (mode: ThemeMode.system, label: "Automático"),
  ];

  @override
  Widget build(BuildContext context) {
    final activeMode = context.watch<ThemeCubit>().state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _options.map((option) {
        final isActive = option.mode == activeMode;

        return DsListTile(
          title: option.label,
          trailing: isActive
              ? Icon(Icons.check, color: DsColors.of(context).blue)
              : null,
          onTap: () {
            context.read<ThemeCubit>().setThemeMode(option.mode);
            getIt.get<AppRouter>().pop();
          },
        );
      }).toList(),
    );
  }
}
