import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';

class MeasurementInputField extends StatelessWidget {
  final String label;
  final String hint;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChange;
  final bool isSaving;
  final VoidCallback saveCallback;

  final List<DropdownMenuEntry>? dropdownOptions;
  final Function(dynamic)? onDropdownSelect;

  const MeasurementInputField({
    required this.label,
    required this.hint,
    required this.isSaving,
    required this.saveCallback,
    this.inputFormatters,
    this.onChange,
    this.dropdownOptions,
    this.onDropdownSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DsSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              if (dropdownOptions != null && dropdownOptions!.isNotEmpty) ...[
                Expanded(
                  child: DsSelect(
                    dropdownOptions: dropdownOptions!,
                    label: "Tipo da medida",
                    onDropdownSelect: onDropdownSelect,
                  ),
                ),
              ],
            ],
          ),

          Row(
            children: [
              Expanded(
                child: DsTextfield(
                  type: .number,
                  label: label,
                  hintText: hint,
                  inputFormatters: inputFormatters,
                  onChange: onChange,
                ),
              ),
              DsButton(
                label: "Salvar",
                isLoading: isSaving,
                onTap: saveCallback,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
