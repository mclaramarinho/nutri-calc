import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/core/services/database/app_database_service.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  // Initialize database
  await getIt.get<AppDatabaseService>().init();

  final themeCubit = getIt.get<ThemeCubit>();
  await themeCubit.hydrate();

  runApp(MainApp(themeCubit: themeCubit));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.themeCubit, super.key});

  final ThemeCubit themeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: themeCubit,
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            routerConfig: getIt.get<AppRouter>().router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(
              brightness: Brightness.light,
              extensions: const [DsColors.light],
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              extensions: const [DsColors.dark],
            ),
            themeMode: themeMode,
          );
        },
      ),
    );
  }
}
