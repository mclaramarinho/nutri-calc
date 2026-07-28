import 'package:flutter/material.dart';

extension ExtWidget on Widget {
  Widget touchEvents({VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: this,
    );
  }
}