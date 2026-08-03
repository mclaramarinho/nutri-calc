import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.type.dart';
import 'package:nutri_calc/shared/di/di.dart';
import 'package:nutri_calc/shared/services/router/navigation_service.dart';
import 'package:nutri_calc/shared/services/router/app_routes.dart';

enum AppBarConfig {
  createPatient;

  const AppBarConfig();

  static AppBarData? getByRoute(AppRoutes route) {
    final router = getIt.get<NavigationService>();
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
