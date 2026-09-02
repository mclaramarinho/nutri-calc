import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_placeholder/ds_placeholder.dart';

class NoDataFoundForPatient extends StatelessWidget {
  final String message;

  const NoDataFoundForPatient({required this.message});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: DsPlaceholder(message: message));
  }
}
