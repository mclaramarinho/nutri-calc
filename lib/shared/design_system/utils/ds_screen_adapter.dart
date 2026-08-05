import 'package:flutter/material.dart';

class DsScreenAdapter {
  static const baseWidth = 1206;
  static const baseHeight = 2622;
  static const dpi = 460;

  static late double _screenWidth;
  static late double _screenHeight;
  static late TextScaler _textScaler;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _textScaler = mediaQuery.textScaler;
  }

  static double get scaleWidth => _screenWidth / baseWidth;
  static double get scaleHeight => _screenHeight / baseHeight;
  static TextScaler get textScaler => _textScaler;
}
