import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab_data.dart';

class DsFab extends StatelessWidget {
  final DsFabData data;

  const DsFab({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: data.onTap,
      backgroundColor: DsColors.blue,
      child: Icon(data.icon, color: DsColors.white),
    );
  }
}
