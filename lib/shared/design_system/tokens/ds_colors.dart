import 'package:flutter/material.dart';

class DsColors extends ThemeExtension<DsColors> {
  final Color white;
  final Color blue;
  final Color black;
  final Color gray;
  final Color error;

  const DsColors({
    required this.white,
    required this.blue,
    required this.black,
    required this.gray,
    required this.error,
  });

  Color get textDisabled => black.withValues(alpha: 0.38);
  Color get textMuted => black.withValues(alpha: 0.54);

  static const light = DsColors(
    white: Colors.white,
    blue: Colors.blue,
    black: Colors.black,
    gray: Color(0xFFEEEEEE),
    error: Colors.red,
  );

  static const dark = DsColors(
    white: Color(0xFF1E1E1E),
    blue: Color(0xFF64B5F6),
    black: Color(0xFFECECEC),
    gray: Color(0xFF424242),
    error: Color(0xFFCF6679),
  );

  static DsColors of(BuildContext context) =>
      Theme.of(context).extension<DsColors>() ?? light;

  @override
  DsColors copyWith({
    Color? white,
    Color? blue,
    Color? black,
    Color? gray,
    Color? error,
  }) => DsColors(
    white: white ?? this.white,
    blue: blue ?? this.blue,
    black: black ?? this.black,
    gray: gray ?? this.gray,
    error: error ?? this.error,
  );

  @override
  DsColors lerp(ThemeExtension<DsColors>? other, double t) {
    if (other is! DsColors) return this;
    return DsColors(
      white: Color.lerp(white, other.white, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      black: Color.lerp(black, other.black, t)!,
      gray: Color.lerp(gray, other.gray, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
