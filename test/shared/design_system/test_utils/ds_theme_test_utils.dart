import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';

/// Pumps [widget] under a themed [MaterialApp] ancestor that registers both
/// the light and dark [DsColors] theme extensions, resolving to
/// [brightness] (defaults to [Brightness.light]).
///
/// Also initializes [DsScreenAdapter] first (`DsSizing`'s `.w` extension
/// throws `LateInitializationError` otherwise - same pattern as
/// `ds_loading_indicator_test.dart`/`ds_checkbox_test.dart`).
Future<void> pumpWidgetWithTheme(
  WidgetTester tester,
  Widget widget, {
  Brightness brightness = Brightness.light,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: const [DsColors.light],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: const [DsColors.dark],
      ),
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return Scaffold(body: widget);
        },
      ),
    ),
  );
}
