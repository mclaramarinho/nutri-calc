import 'package:flutter/material.dart';

class DsTextfield extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(),
      keyboardType: type ?? TextInputType.text,
      decoration: InputDecoration(
        label: label != null ? Text(label!) : null,
        hintText: hintText,
      ),
      onChanged: (value) => onChange?.call(value),
    );
  }
}
