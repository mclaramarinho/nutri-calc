import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';

/// A read-only text-input-styled field that opens the native date picker
/// followed by the native time picker (chained) and combines the result
/// into a single [DateTime], per ADR 0011. Mirrors
/// [lib.shared.design_system.widgets.ds_textfield.DsTextfield]'s visual
/// styling, but adds a clear ("x") action and a future-time rejection rule
/// that `DsTextfield` has no slot for.
class DsDateTimePicker extends StatefulWidget {
  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? maxDateTime;
  final DateTime? minDateTime;
  final bool disabled;
  final String? helperText;
  final ValueChanged<bool>? onValidityChanged;

  const DsDateTimePicker({
    this.label,
    this.value,
    required this.onChanged,
    this.maxDateTime,
    this.minDateTime,
    this.disabled = false,
    this.helperText,
    this.onValidityChanged,
    super.key,
  });

  @override
  State<DsDateTimePicker> createState() => _DsDateTimePickerState();

  /// Combines [date] and [time] into a single [DateTime] and decides
  /// whether it should be accepted given [maxDateTime]. Returns the combined
  /// [DateTime] when accepted, or `null` when rejected (combined moment is
  /// later than [maxDateTime] on the same day).
  ///
  /// Extracted as a pure, directly-testable function, since driving real
  /// `showDatePicker`/`showTimePicker` dialogs in a widget test is
  /// impractical.
  static DateTime? combineAndValidate({
    required DateTime date,
    required TimeOfDay time,
    required DateTime maxDateTime,
  }) {
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final isSameDay =
        combined.year == maxDateTime.year &&
        combined.month == maxDateTime.month &&
        combined.day == maxDateTime.day;

    if (isSameDay) {
      final combinedMinutes = combined.hour * 60 + combined.minute;
      final maxMinutes = maxDateTime.hour * 60 + maxDateTime.minute;
      if (combinedMinutes > maxMinutes) {
        return null;
      }
    }

    return combined;
  }
}

class _DsDateTimePickerState extends State<DsDateTimePicker> {
  String? _errorText;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue);
  }

  @override
  void didUpdateWidget(covariant DsDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = _formattedValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _formattedValue =>
      widget.value != null ? widget.value!.formattedDateTime() : '';

  Future<void> _openPickers() async {
    if (widget.disabled) return;

    final maxDateTime = widget.maxDateTime ?? DateTime.now();
    final minDateTime = widget.minDateTime ?? DateTime(1900);

    final pickedDate = await showDatePicker(
      context: context,
      firstDate: minDateTime,
      lastDate: maxDateTime,
      initialDate: widget.value ?? DateTime.now(),
    );
    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: widget.value != null
          ? TimeOfDay.fromDateTime(widget.value!)
          : TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final combined = DsDateTimePicker.combineAndValidate(
      date: pickedDate,
      time: pickedTime,
      maxDateTime: maxDateTime,
    );

    if (combined == null) {
      setState(() {
        _errorText = "Não é possível selecionar um horário futuro.";
      });
      widget.onValidityChanged?.call(true);
      return;
    }

    setState(() {
      _errorText = null;
    });
    widget.onValidityChanged?.call(false);
    widget.onChanged(combined);
  }

  void _clear() {
    setState(() {
      _errorText = null;
    });
    widget.onValidityChanged?.call(false);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value != null;

    return TextFormField(
      readOnly: true,
      enabled: !widget.disabled,
      controller: _controller,
      onTap: _openPickers,
      decoration: InputDecoration(
        label: widget.label != null ? Text(widget.label!) : null,
        hintText: hasValue ? null : "Selecionar data e hora",
        helperText: hasValue
            ? widget.helperText
            : (widget.helperText ??
                  "Se não selecionado, será usado o momento do registro."),
        errorText: _errorText,
        errorStyle: TextStyle(color: DsColors.error),
        suffixIcon: hasValue
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.disabled ? null : _clear,
              )
            : const Icon(Icons.calendar_month_outlined),
      ),
    );
  }
}
