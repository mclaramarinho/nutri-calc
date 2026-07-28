import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/utils/extensions/datetime.ext.dart';
import 'package:nutri_calc/shared/utils/extensions/widget.ext.dart';
import 'package:nutri_calc/shared/utils/formatters/datetime_formatter.dart';

class DsTextfield extends StatefulWidget {
  final String? label;
  final String? hintText;
  final void Function(String text)? onChange;
  final TextInputType? type;

  const DsTextfield({
    this.label,
    this.hintText,
    this.onChange,
    this.type,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DsTextFieldState();
}

class _DsTextFieldState extends State<DsTextfield> {
  late DateTime? selectedDate;
  TextEditingController controller = TextEditingController();

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
    });
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
      decoration: InputDecoration(
        label: widget.label != null ? Text(widget.label!) : null,
        hintText: widget.hintText,
        suffixIcon: widget.type == .datetime
            ? Icon(
                Icons.calendar_month_outlined,
              ).touchEvents(onTap: () => openDatePicker(context))
            : null,
      ),
      onChanged: (value) => widget.onChange?.call(
        widget.type == .datetime
            ? (selectedDate?.toIso8601String() ?? "")
            : value,
      ),
    );
  }
}
