import 'dart:ui';

class DsAppBarData {
  final String? title;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final VoidCallback? onThemeToggle;

  const DsAppBarData({
    this.title,
    this.onBack,
    this.onClose,
    this.onThemeToggle,
  });
}
