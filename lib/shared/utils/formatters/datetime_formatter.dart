import 'package:flutter/services.dart';

class DatetimeFormatter extends TextInputFormatter {
  const DatetimeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    String formatted;
    if (digits.length <= 2) {
      if (!_validateDay(digits)) return oldValue;

      formatted = digits;
    } else if (digits.length <= 4) {
      final part1 = digits.substring(0, 2);

      if (!_validateDay(part1)) return oldValue;

      final part2 = digits.substring(2, digits.length);

      if (!_validateMonth(part2)) return oldValue;

      formatted = "$part1/$part2";
    } else {
      final part1 = digits.substring(0, 2);

      if (!_validateDay(part1)) return oldValue;

      final part2 = digits.substring(2, 4);

      if (!_validateMonth(part2)) return oldValue;

      formatted = "$part1/$part2/${digits.substring(4)}";
    }

    if (digits.length == 8) {
      final fullDateRegex = RegExp(
        r'^(0[1-9]|[12]\d|3[01])/(0[1-9]|1[0-2])/\d{4}$',
      );
      if (!fullDateRegex.hasMatch(formatted)) return oldValue;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  bool _validateDay(String day) {
    final parsed = int.tryParse(day);
    return parsed != null && parsed <= 31;
  }

  bool _validateMonth(String month) {
    final parsed = int.tryParse(month);
    return parsed != null && parsed <= 12;
  }
}
