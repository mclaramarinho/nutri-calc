import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';

class DsSelect<T> extends StatelessWidget {
  final List<DropdownMenuEntry<T>> dropdownOptions;
  final String label;
  final void Function(T?)? onDropdownSelect;

  const DsSelect({
    required this.dropdownOptions,
    required this.label,
    required this.onDropdownSelect,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenuFormField(
      dropdownMenuEntries: dropdownOptions,
      label: Text(label),
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(),
      ),
      expandedInsets: EdgeInsets.all(DsSpacing.none),
      onSelected: onDropdownSelect,
      enabled: true,
    );
  }
}
