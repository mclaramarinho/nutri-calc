import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_date_time_picker/ds_date_time_picker.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';

class MeasurementInputField extends StatefulWidget {
  final String label;
  final String hint;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChange;
  final bool isSaving;
  final bool disabled;
  final VoidCallback saveCallback;

  final List<DropdownMenuEntry>? dropdownOptions;
  final Function(dynamic)? onDropdownSelect;

  final DateTime? dateTime;
  final ValueChanged<DateTime?>? onDateTimeChange;

  const MeasurementInputField({
    required this.label,
    required this.hint,
    required this.isSaving,
    required this.disabled,
    required this.saveCallback,
    this.inputFormatters,
    this.onChange,
    this.dropdownOptions,
    this.onDropdownSelect,
    this.dateTime,
    this.onDateTimeChange,
    super.key,
  });

  @override
  State<MeasurementInputField> createState() => _MeasurementInputFieldState();
}

class _MeasurementInputFieldState extends State<MeasurementInputField> {
  bool _dateTimeInvalid = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(DsSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              if (widget.dropdownOptions != null &&
                  widget.dropdownOptions!.isNotEmpty) ...[
                Expanded(
                  child: DsSelect(
                    dropdownOptions: widget.dropdownOptions!,
                    label: "Tipo da medida",
                    onDropdownSelect: widget.onDropdownSelect,
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
                  label: widget.label,
                  hintText: widget.hint,
                  inputFormatters: widget.inputFormatters,
                  onChange: widget.onChange,
                ),
              ),
              DsButton(
                label: "Salvar",
                isLoading: widget.isSaving,
                disabled: widget.disabled || _dateTimeInvalid,
                onTap: widget.saveCallback,
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.only(top: DsSpacing.sm),
            child: DsDateTimePicker(
              label: "Data e hora",
              value: widget.dateTime,
              onChanged: widget.onDateTimeChange ?? (_) {},
              onValidityChanged: (invalid) {
                setState(() => _dateTimeInvalid = invalid);
              },
            ),
          ),
        ],
      ),
    );
  }
}
