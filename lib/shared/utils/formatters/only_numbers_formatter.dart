import 'package:flutter/services.dart';

class OnlyNumbersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final sanitized = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = sanitized.substring(0, sanitized.length > 3 ? 3 : sanitized.length);
    return TextEditingValue(
      text: trimmed,
      selection: .collapsed(offset: -1)
    );
  }
}