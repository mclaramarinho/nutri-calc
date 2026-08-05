import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.type.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';

enum AppBarConfig {
  createPatient;

  const AppBarConfig();

  static AppBarData? getByRoute(AppRoutes route) {
    final router = getIt.get<AppRouter>();
    switch (route) {
      case .createPatient:
        return AppBarData(
          title: "Criar Paciente",
          onBack: router.pop,
          onClose: router.pop,
        );
      default:
        return null;
    }
  }
}
