import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/utils/extensions/datetime.ext.dart';
import 'package:nutri_calc/shared/utils/extensions/widget.ext.dart';
import 'package:nutri_calc/shared/utils/formatters/datetime_formatter.dart';

class DsTextfield extends StatefulWidget {
  final String? label;
  final String? hintText;
  final void Function(String text)? onChange;
  final TextInputType? type;
  final String? Function(String? value)? validator;

  const DsTextfield({
    this.label,
    this.hintText,
    this.onChange,
    this.type,
    this.validator,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DsTextFieldState();
}

class _DsTextFieldState extends State<DsTextfield> {
  DateTime? selectedDate;
  TextEditingController controller = TextEditingController();
  String? errorMessage;

  void openDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    ).then((val) {
      setState(() {
        selectedDate = val;
      });
      controller.text = selectedDate?.formattedDate() ?? "";
      onChangedDate();
    });
  }

  void onChangedDate() {
    widget.onChange?.call(selectedDate?.toIso8601String() ?? "");
  }

  String? validate(String? value) {
    if (widget.validator == null) {
      setState(() => errorMessage = null);
      return null;
    }

    final res = widget.validator!.call(value);
    setState(() => errorMessage = res);

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(),
      keyboardType: widget.type ?? TextInputType.text,
      controller: widget.type == .datetime ? controller : null,
      inputFormatters: [
        if (widget.type == .datetime) ...[DatetimeFormatter()],
      ],
      readOnly: widget.type == .datetime,
      decoration: InputDecoration(
        label: widget.label != null ? Text(widget.label!) : null,
        hintText: widget.hintText,
        errorText: errorMessage,
        suffixIcon: widget.type == .datetime
            ? Icon(
                Icons.calendar_month_outlined,
              ).touchEvents(onTap: () => openDatePicker(context))
            : null,
      ),
      onTap: () => widget.type == .datetime ? openDatePicker(context) : {},
      onChanged: (value) {
        final isDate = widget.type == .datetime;
        if (!isDate) {
          validate(value);
          widget.onChange?.call(value);
        } else {
          onChangedDate();
        }
      },
    );
  }
}
