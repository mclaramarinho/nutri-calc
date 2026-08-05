import 'package:flutter/material.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab_data.type.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_scaffold/ds_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter _router = getIt.get<AppRouter>();
    
    return DsScaffold(
      fabData: DsFabData(
        onTap: () => _router.push(.createPatient),
        icon: Icons.person_add,
      ),
      child: Placeholder(),
    );
  }
}
