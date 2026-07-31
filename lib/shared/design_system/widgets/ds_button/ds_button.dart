import 'package:flutter/material.dart';

class DsButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const DsButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    super.key,
  });

  // TODO - style this button
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        child: isLoading ? CircularProgressIndicator() : Text(label),
      ),
    );
  }
}
